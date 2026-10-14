"""Exercise the production images with disposable PostgreSQL and real HTTP.

Run after building both images:
  python3 deploy/smoke_test.py --laya-image feedback-laya:render-test

No local app/database is started or modified. No external emails are sent.
Only this test's randomly named containers, volumes, and network are removed.
"""
import argparse
import json
import os
from pathlib import Path
import secrets
import socket
import subprocess
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request


def docker(*args, check=True):
    return subprocess.run(['docker', *args], check=check, text=True, capture_output=True).stdout.strip()


def http(url, data=None, token=None):
    headers = {'Content-Type': 'application/json'}
    if token:
        headers['Authorization'] = 'Bearer ' + token
    request = urllib.request.Request(url, data=None if data is None else json.dumps(data).encode(), headers=headers)
    try:
        with urllib.request.urlopen(request, timeout=120) as response:
            return response.status, response.read().decode()
    except urllib.error.HTTPError as error:
        return error.code, error.read().decode()


def unused_port():
    with socket.socket() as sock:
        sock.bind(('127.0.0.1', 0))
        return sock.getsockname()[1]


def wait_for(url, timeout=180):
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        try:
            if http(url)[0] == 200:
                return
        except (OSError, TimeoutError):
            pass
        time.sleep(1)
    raise RuntimeError('Service did not become ready: ' + url)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--image', default='feedback-aggregator:render-test')
    parser.add_argument('--laya-image')
    parser.add_argument('--laya-cpus', type=int, default=1, help='Use 4 for slow AMD64 emulation on Apple Silicon; Render is verified separately.')
    parser.add_argument('--output', default='/tmp/feedback-docker-verification.json')
    args = parser.parse_args()
    tag = 'feedback-smoke-' + secrets.token_hex(4)
    names = []
    checks = []
    report = {'platform': 'linux/amd64', 'checks': checks, 'laya': None}
    env = {
        'SERVERPOD_DATABASE_HOST': tag + '-db', 'SERVERPOD_DATABASE_PORT': '5432',
        'SERVERPOD_DATABASE_NAME': 'feedback_smoke', 'SERVERPOD_DATABASE_USER': 'postgres',
        'SERVERPOD_DATABASE_REQUIRE_SSL': 'false',
        **{'SERVERPOD_PASSWORD_' + key: secrets.token_urlsafe(64) for key in [
            'database', 'serviceSecret', 'jwtRefreshTokenHashPepper', 'jwtHmacSha512PrivateKey', 'emailSecretHashPepper',
        ]},
    }
    def passed(label):
        checks.append(label)
        print('PASS:', label, flush=True)
    try:
        docker('network', 'create', tag)
        with tempfile.TemporaryDirectory(prefix=tag) as directory:
            def envfile(name, values):
                path = Path(directory) / name
                path.write_text(''.join(k + '=' + v + '\n' for k, v in values.items()))
                path.chmod(0o600)
                return str(path)
            names.append(tag + '-db')
            docker('run', '-d', '--platform', 'linux/amd64', '--name', names[-1], '--network', tag,
                   '--env-file', envfile('postgres.env', {'POSTGRES_PASSWORD': env['SERVERPOD_PASSWORD_database'],
                   'POSTGRES_DB': 'feedback_smoke'}), 'postgres:16-bookworm')
            for _ in range(90):
                status = subprocess.run(['docker', 'exec', names[-1], 'pg_isready', '-U', 'postgres'], capture_output=True)
                if status.returncode == 0:
                    break
                time.sleep(1)
            else:
                raise RuntimeError('Disposable PostgreSQL did not start')
            if args.laya_image:
                laya_port = unused_port()
                token = secrets.token_urlsafe(40)
                names.append(tag + '-laya')
                docker('run', '-d', '--platform', 'linux/amd64', '--name', names[-1], '--network', tag,
                       '--memory', '2g', '--cpus', str(args.laya_cpus), '-p', f'127.0.0.1:{laya_port}:8093',
                       '--env-file', envfile('laya.env', {'LAYA_API_KEY': token, 'LAYA_THREADS': str(args.laya_cpus)}), args.laya_image)
                laya_base = f'http://127.0.0.1:{laya_port}'
                wait_for(laya_base + '/health')
                health = json.loads(http(laya_base + '/health', token=token)[1])
                assert health['device'] == 'cpu'
                env['LAYA_URL'] = f'http://{names[-1]}:8093/v1/systemone'
                env['SERVERPOD_PASSWORD_layaApiKey'] = token
                status, _ = http(laya_base + '/v1/systemone', {})
                assert status in (401, 403), 'Laya must reject unauthenticated inference'
                report['laya'] = {'device': health['device'], 'memoryLimit': '2 GiB', 'cpuLimit': args.laya_cpus}
                passed('Laya CPU startup and bearer-token enforcement')
            port = unused_port()
            base = f'http://127.0.0.1:{port}'
            env['APP_PUBLIC_URL'] = base
            names.append(tag + '-app')
            docker('run', '-d', '--platform', 'linux/amd64', '--name', names[-1], '--network', tag,
                   '--cap-drop', 'ALL', '--security-opt', 'no-new-privileges',
                   '--memory', '512m', '--cpus', '0.5', '-p', f'127.0.0.1:{port}:10000',
                   '--env-file', envfile('app.env', env), args.image)
            wait_for(base + '/healthz')
            passed('Production startup without Linux capabilities, migrations, and database readiness')
            for path, contains in [('/', 'flutter_bootstrap.js'), ('/auth/callback', 'html')]:
                code, body = http(base + path)
                assert code == 200 and contains in body.lower(), path
            config = json.loads(http(base + '/assets/assets/config.json')[1])
            assert config['apiUrl'] == base + '/api/'
            assert http(base + '/api/readyz')[0] == 200
            assert http(base + '/websocket')[0] != 101
            passed('Flutter assets, runtime API URL, API proxy, and OAuth callback route')

            def rpc(endpoint, method, data, token=None, expected=200):
                status, body = http(base + '/api/' + endpoint + '/' + method, data, token)
                if status != expected:
                    try:
                        def messages(value):
                            if isinstance(value, dict):
                                for key, child in value.items():
                                    if key.lower() in ('message', 'error', 'reason') and isinstance(child, str):
                                        yield child
                                    else:
                                        yield from messages(child)
                            elif isinstance(value, list):
                                for child in value:
                                    yield from messages(child)
                        parsed = json.loads(body)
                        message = '; '.join(messages(parsed)) or ('Error keys: ' + ', '.join(parsed))
                    except (ValueError, AttributeError):
                        message = 'Non-JSON error response'
                    raise RuntimeError(f'{endpoint}/{method}: expected HTTP {expected}, got {status}: {message}')
                return json.loads(body) if body else None
            password = secrets.token_urlsafe(20)
            accounts = []
            for role in ('admin', 'viewer'):
                email = role + '-' + tag + '@example.com'
                auth = rpc('emailIdp', 'register', {'email': email, 'password': password})
                login = rpc('emailIdp', 'login', {'email': email, 'password': password})
                assert auth['authUserId'] == login['authUserId']
                accounts.append((email, login['token']))
            admin, viewer = accounts[0][1], accounts[1][1]
            passed('Email/password signup and login without OTP')
            org = rpc('workspace', 'create', {'name': 'Docker smoke workspace'}, admin)
            wid = org['id']
            ticket_data = {'workspaceId': wid, 'title': 'Docker smoke ticket', 'description': 'Synthetic deployment check', 'source': 'Forms', 'priority': 'High'}
            ticket = rpc('workspace', 'createTicket', ticket_data, admin)
            assert len(rpc('workspace', 'tickets', {'workspaceId': wid}, admin)) == 1
            outsider_status, _ = http(base + '/api/workspace/tickets', {'workspaceId': wid}, viewer)
            assert outsider_status in (400, 401, 403)
            unauth_status, _ = http(base + '/api/workspace/list', {})
            assert unauth_status in (401, 403)
            passed('Ticket creation, login gate, and tenant isolation')
            invitation = rpc('workspace', 'createInvitationLink', {'workspaceId': wid, 'email': accounts[1][0], 'role': 'viewer'}, admin)
            assert invitation['url'].startswith(base + '/') and not invitation['emailSent']
            invite_token = urllib.parse.parse_qs(urllib.parse.urlsplit(invitation['url']).fragment.split('?', 1)[1])['token'][0]
            rpc('workspace', 'acceptInvitation', {'token': invite_token}, viewer)
            assert len(rpc('workspace', 'tickets', {'workspaceId': wid}, viewer)) == 1
            write_status, _ = http(base + '/api/workspace/createTicket', ticket_data, viewer)
            assert write_status in (400, 401, 403)
            passed('Public-origin invite links and Viewer read-only permissions')
            for source in ('Email', 'Slack'):
                result = rpc('sources', 'connect', {'workspaceId': wid, 'source': source}, admin)
                assert result['addedCount'] == 5 and result['connection']['connected']
                assert rpc('sources', 'connect', {'workspaceId': wid, 'source': source}, admin)['addedCount'] == 0
                for expected in (3, 3, 1, 0):
                    result = rpc('sources', 'sync', {'workspaceId': wid, 'source': source}, admin)
                    assert result['addedCount'] == expected
                assert result['connection']['syncedCount'] == 12
                for method in ('connect', 'sync', 'disconnect'):
                    assert http(base + '/api/sources/' + method, {'workspaceId': wid, 'source': source}, viewer)[0] in (400, 401, 403)
            imported = rpc('workspace', 'tickets', {'workspaceId': wid}, admin)
            mock_rows = [row for row in imported if row['isMock']]
            assert len(imported) == 25 and len(mock_rows) == 24
            assert len({(row['source'], row['externalId']) for row in mock_rows}) == 24
            assert len(rpc('sources', 'list', {'workspaceId': wid}, viewer)) == 2
            rpc('sources', 'disconnect', {'workspaceId': wid, 'source': 'Email'}, admin)
            assert http(base + '/api/sources/sync', {'workspaceId': wid, 'source': 'Email'}, admin)[0] in (400, 401, 403)
            assert rpc('sources', 'connect', {'workspaceId': wid, 'source': 'Email'}, admin)['addedCount'] == 0
            beta = rpc('workspace', 'create', {'name': 'Separate source workspace'}, admin)
            assert rpc('sources', 'list', {'workspaceId': beta['id']}, admin) == []
            assert rpc('workspace', 'tickets', {'workspaceId': beta['id']}, admin) == []
            report['mockSources'] = {'sources': ['Email', 'Slack'], 'importedReports': 24, 'duplicateFree': True, 'tenantIsolation': True, 'viewerRestrictions': True}
            passed('Email/Slack source connections, delta sync, deduplication, roles, and tenant isolation')
            if args.laya_image:
                snapshot = json.loads(rpc('layaPoc', 'start', {'workspaceId': wid, 'sources': ['Discord', 'Slack', 'Email', 'Forms', 'Support']}, admin))
                run = snapshot['run']
                latencies = []
                for index in range(34):
                    started = time.monotonic()
                    snapshot = json.loads(rpc('layaPoc', 'step', {'workspaceId': wid, 'runId': run['id'], 'expectedIndex': index}, admin))
                    latencies.append(round(time.monotonic() - started, 2))
                    run = snapshot['run']
                    assert run['processed'] == index + 1
                    if (index + 1) % 6 == 0:
                        print('Laya reports processed:', index + 1, flush=True)
                report['laya']['metrics'] = run['metrics']
                report['laya']['reportLatencySeconds'] = latencies
                report['laya']['containerStats'] = docker('stats', '--no-stream', '--format', '{{.MemUsage}} / {{.CPUPerc}}', tag + '-laya')
                report['laya']['peakMemoryBytes'] = int(docker('exec', tag + '-laya', 'cat', '/sys/fs/cgroup/memory.peak'))
                report['laya']['swapMemoryBytes'] = int(docker('exec', tag + '-laya', 'cat', '/sys/fs/cgroup/memory.swap.current'))
                passed('All 34 real Laya inferences through authenticated Serverpod RPC')
            docker('stop', '--time', '20', tag + '-app')
            state = json.loads(docker('inspect', '--format', '{{json .State}}', tag + '-app'))
            assert state['ExitCode'] in (0, 143) and not state['OOMKilled'], 'App failed to shut down gracefully'
            docker('start', tag + '-app')
            wait_for(base + '/healthz')
            restored = rpc('workspace', 'tickets', {'workspaceId': wid}, admin)
            assert any(row['id'] == ticket['id'] for row in restored)
            assert len(restored) == 25 and len(rpc('sources', 'list', {'workspaceId': wid}, admin)) == 2
            passed('Graceful restart, idempotent migrations, and persisted tickets')
            assert docker('exec', tag + '-app', 'id', '-u') == '10001'
            forbidden = docker('exec', tag + '-app', 'find', '/app', '-name', 'passwords.yaml', '-o', '-name', '.env', '-o', '-name', 'client_secret*.json')
            assert not forbidden
            passed('Non-root runtime and no bundled credential files')
            report['appContainerStats'] = docker('stats', '--no-stream', '--format', '{{.MemUsage}} / {{.CPUPerc}}', tag + '-app')
            report['appImageId'] = docker('inspect', '--format', '{{.Image}}', tag + '-app')
            if args.laya_image:
                report['layaImageId'] = docker('inspect', '--format', '{{.Image}}', tag + '-laya')
            report['passed'] = True
            Path(args.output).write_text(json.dumps(report, indent=2) + '\n')
            print('Verification saved:', args.output, flush=True)
    finally:
        for name in reversed(names):
            docker('stop', '--time', '20', name, check=False)
            docker('rm', '-v', name, check=False)
        docker('network', 'rm', tag, check=False)


if __name__ == '__main__':
    main()
