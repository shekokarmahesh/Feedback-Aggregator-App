"""Build the report from recorded synthetic evidence; no model/API calls."""
from pathlib import Path
import html
import json
import re
import zipfile
from markdown_it import MarkdownIt

folder = Path(__file__).resolve().parent
names = ['ordered-1', 'ordered-2', 'shuffled-7', 'shuffled-42']
runs = {n: json.loads((folder / (n + '.json')).read_text()) for n in names}
base = runs['ordered-2']
reports = {r['id']: r for r in base['reports']}
health = json.loads((folder / 'model-health.json').read_text())
verification = json.loads((folder / 'verification.json').read_text())
manifest = json.loads((folder / 'source-manifest.json').read_text())

def table(headers, rows):
    def cell(v):
        return str(v).replace('|', '\\|').replace('\n', ' ')
    return '| ' + ' | '.join(headers) + ' |\n| ' + ' | '.join(['---']*len(headers)) + ' |\n' + '\n'.join('| ' + ' | '.join(cell(v) for v in row) + ' |' for row in rows)

def percent(value):
    return f'{100*value:.1f}%'

summary = []
for name, result in runs.items():
    run = result['run']
    m = run['metrics']
    summary.append([name, len(run['issues']), m['mergedCount'], m['reviewCount'], percent(m['precision']), percent(m['recall']), m['falseMergePairs'], m['missedDuplicatePairs'], f"{run['latencyMs']/1000:.3f}s"])
groups = []
for g in base['run']['issues']:
    labels = {reports[r]['expectedIssue'] for r in g['reportIds']}
    groups.append([g['id'], g['title'], g['reportCount'], g['uniqueReporters'], ', '.join(g['sources']), g['score'], ', '.join(g['reportIds']), 'Incorrect / mixed' if len(labels)>1 else 'Consistent with gold'])

nodes = [
    (30, 70, 210, 100, 'PostgreSQL', ['Membership + run limits', 'Existing managed database']),
    (640, 70, 220, 100, 'Mock sources', ['34 reports / five channels', 'Generated inside backend']),
    (30, 260, 210, 110, 'Flutter web', ['Cards, groups, evidence', 'Filters + review queue']),
    (325, 260, 220, 110, 'LayaPocEndpoint', ['Login + workspace access', 'Admin / Editor can write']),
    (640, 260, 220, 110, 'POC engine + adapter', ['Retrieve / compare / group', 'PocRun + LayaClient']),
    (1005, 260, 225, 110, 'Local Laya 0.4.1', ['English model / Apple MPS', '127.0.0.1:8093 / no API key']),
    (640, 505, 220, 85, 'Workspace scratch state', ['Groups, decisions, statuses']),
]
svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1260 640" role="img" aria-labelledby="arch-title"><title id="arch-title">Local Laya POC architecture: Flutter, authenticated Serverpod, PostgreSQL, mock feedback, workspace memory, and local Laya inference</title><defs><marker id="arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="6" markerHeight="6" orient="auto-start-reverse"><path d="M0 0L10 5L0 10Z" fill="#64748b"/></marker></defs><style>.name{font:600 17px system-ui;fill:#17243b}.small{font:13px system-ui;fill:#526178}.label{font:12px system-ui;fill:#526178}.edge{stroke:#64748b;stroke-width:1.6;fill:none;marker-end:url(#arrow)}.both{marker-start:url(#arrow)}</style><rect x="300" y="15" width="590" height="600" rx="18" fill="#f1f5fb" stroke="#d2deef" stroke-dasharray="6 5"/><text x="325" y="48" class="small">SERVERPOD BACKEND PROCESS</text>'
for x, y, w, h, title, lines in nodes:
    svg += f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="12" fill="white" stroke="#ccd6e5"/><text x="{x+18}" y="{y+33}" class="name">{html.escape(title)}</text>'
    for i, line in enumerate(lines):
        svg += f'<text x="{x+18}" y="{y+60+i*23}" class="small">{html.escape(line)}</text>'
for path, both in [('M240 315H325',True),('M545 315H640',True),('M860 315H1005',True),('M325 280H275V120H240',True),('M750 170V260',False),('M750 370V505',True)]:
    svg += f'<path class="edge {"both" if both else ""}" d="{path}"/>'
for x,y,label in [(282,299,'RPC / JSON'),(592,299,'step / snapshot'),(932,299,'HTTP / batch'),(218,207,'access + limits'),(805,220,'sample text'),(810,445,'workspace key')]:
    svg += f'<text x="{x}" y="{y}" text-anchor="middle" class="label">{label}</text>'
svg += '<text x="30" y="446" class="small">Viewer: read only</text><text x="30" y="470" class="small">Source cards are mock integrations</text><text x="325" y="563" class="small">Results clear on restart</text><text x="325" y="586" class="small">Live tickets unchanged</text><text x="1005" y="446" class="small">Inference stays local</text><text x="1005" y="470" class="small">No OpenRouter or Docker needed</text></svg>'
(folder / 'architecture.svg').write_text(svg)

md = f'''# Laya feedback aggregation POC

## Retest report · 9 October 2026

**Verdict: the local integration works, but clustering quality is insufficient for automatic use.** The POC can run without a paid API key. It preserves evidence and produces a priority-ranked team view, but misses too many repeated reports with the current Laya model and prompts.

## What we tested

We froze the existing model, prompts, retrieval logic, and thresholds. Four real-inference runs used the same 34 synthetic English reports: six product issues paraphrased across Discord, Slack, Email, Forms, and Support, plus two chatter messages and two vague complaints. The 30 concrete reports contain **60 expected duplicate pairs**: six groups × C(5,2). The two chatter messages have distinct labels; vague reports have no gold label.

Two ordered runs check repeatability. Shuffled arrival orders use Dart Random seeds 7 and 42. All four runs completed without inference errors. This is the existing development fixture, not an independent holdout. Gold labels were used only after decisions for scoring, never as model inputs.

## Measured results

{table(['Run','Issues','Merges','Review','Precision','Recall','False pairs','Missed pairs','Request time'], summary)}

The ordered runs reproduced identical decisions, groups, scores, and metrics. Their request times differed. The original order recovered **5/60 true duplicate pairs**, with one incorrect pair; seed 7 recovered 22/60 with two incorrect pairs; seed 42 recovered 19/60 with zero incorrect pairs. The seed-42 precision is not a general claim of perfect accuracy.

API fees were **$0** in every run; inference consumes local machine resources. Durations sum model-adapter requests and exclude model download/startup, database/RPC overhead, and browser rendering. Machine load was not controlled, so these are observations rather than latency guarantees.

Pairwise precision = correct same-issue merged pairs / all merged pairs. Duplicate recall = recovered duplicate pairs / 60 expected duplicate pairs. Reviews, unmerged duplicates, and fragmented groups count as misses. Merge count means report-attachment events: a three-report group contributes three report pairs. Both chatter reports stayed in review in every run; neither was confidently removed as noise.

## Working system architecture

![Local Laya POC architecture](architecture.svg)

```mermaid
flowchart LR
  UI[Flutter web POC] <-->|workspace RPC / JSON| API[Authenticated Serverpod endpoint]
  API <-->|membership + run limits| DB[(Managed PostgreSQL)]
  API <-->|step / snapshot| ENGINE[POC engine + Laya adapter]
  MOCK[34 generated reports / five channels] --> ENGINE
  ENGINE <-->|HTTP triage + pair batch| LAYA[Local Laya English / Apple MPS]
  ENGINE <-->|workspace ID| MEMORY[(Temporary groups and decisions)]
```

1. **Flutter web:** sample integration cards, source selection, grouped issues, search/status/channel filters, original reports, review queue, and priority scores. Flutter calls Serverpod, never the model directly.
2. **Serverpod API:** `read`, `start`, `step`, and `updateStatus` require login and workspace membership. Admin and Editor can run and update; Viewer can inspect. PostgreSQL supplies membership checks and the run-start rate limiter.
3. **Mock fixture:** generated by the backend. Discord, Slack, Email, Forms, and Support are labels, not connected accounts or inbound APIs. Source counts are 7/7/7/7/6 respectively.
4. **POC engine:** discovers issues from earlier accepted reports. It retrieves at most seven candidates using Jaccard word-set similarity and compares against each issue's first report.
5. **Local model service:** separate Python process on loopback HTTP. Triage calls `/v1/systemone`; candidate pairs call `/v1/systemone/batch`. No OpenRouter key or Docker dependency is needed on this Mac.
6. **Scratch state:** groups, evidence IDs, decisions, metrics, and statuses are kept in workspace-keyed bounded memory. They are shared inside that workspace and clear on backend restart. Grouped issues are not written into live feedback tickets. This is a single-instance POC, not durable distributed clustering.

## Decision workflow

1. Ask Laya to classify feedback as bug, feature, noise, or unclear and separately estimate severity from 0 to 4.
2. Bug/feature triage needs **answer confidence ≥0.60** before duplicate comparison. Unclear or low-confidence triage stays in review; confidently classified noise is excluded.
3. Compare the incoming message with up to seven issue exemplars. Each binary `noul` value is the probability that the pair describes the same specific issue. Values are independent; they do not sum to one.
4. Exactly one candidate at **≥0.80** is merged. Multiple qualifying candidates go to review. If every candidate is **≤0.50**, create a new issue. Intermediate matches go to review. With no candidates, confident actionable feedback starts the first issue.
5. Preserve original evidence, count linked reporter identities once, update priority, and return the snapshot. Issue titles come from their first reports; Laya does not generate prose summaries.

Choice/score gates use `answer_confidence`, not entropy-based `confidence`. Binary matching uses probability of true, not confidence in whichever binary answer won. Invalid model responses, token truncation, collapsed options, HTTP errors, and timeouts are rejected rather than replaced with fabricated groups. Failed reports remain retryable within the bounded attempt policy.

## Actual ordered output

{table(['Issue','First-report title','Reports','People','Channels','Priority /100','Report IDs','Gold check'], groups)}

The top issue is **POC-6: password recovery emails missing**, with three reports from Slack, Forms, and Support, priority **42/100**. Its components are severity 23 + reach 9 + recent reports 4 + channel breadth 6. The sample identities are explicitly linked; real cross-platform identity resolution remains to be designed.

### Correct cross-channel merge

SAMPLE-20 (Forms): “Reset password cannot be completed because the email with the code is never delivered.” It joined POC-6, whose first message SAMPLE-8 (Slack) says: “Password recovery emails are missing. Tried resending the reset code three times.” Duplicate probability was **0.8817**. SAMPLE-26 (Support) also joined.

### Incorrect merge

SAMPLE-24 (Forms): “Please offer a dark appearance option for the dashboard.” It joined **POC-3, a filtered CSV with no rows**, at probability **0.8141**. These are different issues. This mistake recurred in both ordered runs and shuffled seed 7. It adds an unrelated person/channel to the issue and can distort priority.

### Missed duplicate

SAMPLE-9 (Slack), a large CSV timeout, matched POC-2 at **0.7833**, below the 0.80 policy threshold, and remained in review. The conservative gate avoids forcing a borderline match but loses recall.

### High-confidence review

SAMPLE-25, a Google-login redirect loop, scored **0.9709** against POC-5 and **0.8891** against POC-1. Both earlier groups already describe Google-login loops. The competing-match rule sent the report to review. The POC has no group-to-group merge to repair this fragmentation. A high confidence can therefore coexist with a review outcome.

## Priority scoring

`round(40 × severity / 4) + round(30 × min(unique people / 10, 1)) + round(20 × min(reports younger than 24h / 5, 1)) + round(10 × channel count / 5)`

Confidently critical severity (≥3.5 with severity answer confidence ≥0.80) receives a minimum priority of 95. Components are rounded. All ten ordered groups have severity flagged for review. Priority is a product rule, not a model accuracy metric; errors can affect ranking.

## Verification and limits

- **33 backend tests and 18 Flutter tests passed** during this retest. They verify software behavior, role/membership gates, evidence preservation, protocol handling, score rules, and UI flow. They do not establish model accuracy.
- **Live app check:** {verification['liveUi']}
- **Model:** Laya 0.4.1 / `english` / `convaiinnovations/laya`, revision `{health['revisions']['english']}`. Health reported Apple `mps`, zero CPU fallbacks.
- **Scope:** one synthetic English development fixture. No independent real-data, multilingual, adversarial, or large-volume evaluation was performed.
- **Order sensitivity:** demonstrated. Online grouping, lexical retrieval, first-report exemplars, and earlier fragmentation are plausible contributors; no ablation isolated their individual effects.
- **Missing product capabilities:** live connectors, durable cluster storage, manual reassignment/merge/split, and real identity resolution.
- **Bounds:** five starts per member/workspace/hour, at most twice the report count in attempts, at most 100 workspaces in scratch memory, and pruning of old idle runs.

## Verdict and next experiment

**Keep this as an experimental POC. Do not enable unattended customer-feedback grouping with this model/prompt combination.** The software path works, but original-order recall of 8.3% fails the main goal of consolidating repeated feedback. Even the better shuffled outputs miss 38–41 of 60 duplicate pairs.

Next, compare a stronger local semantic model and embedding-based retrieval on independently labeled realistic reports, add human merge/split/reassign controls, and tune thresholds on separate validation data. Evaluate multiple arrival orders. Suggested targets to agree with the team—not existing requirements—are ≥95% pair precision and ≥80% recall before automatic actions are considered.

## Reproduce and inspect

Start the existing model from the repository root: `cd feedback_aggregator && sh tools/laya/run.sh`.

Run the unchanged engine benchmark from `feedback_aggregator/feedback_aggregator_server`:

```sh
dart run tool/benchmark_laya.dart ../tools/laya/.runtime/benchmark.json
```

Inside this artifact folder, `dart run_evaluation.dart` repeats ordered/shuffled runs using byte-for-byte engine snapshots in `source/`. It requires the existing Dart SDK and unauthenticated loopback Laya service; it does not start Serverpod or touch its database. It overwrites ordered-2/shuffled captures, so copy the folder first to preserve this session.

`build_report.py` regenerates the report from saved evidence using Python with `markdown-it-py` (already available in `tools/laya/.venv`). Model-health and verification metadata describe this session and should be refreshed for a different setup.

Raw results: [ordered-1](ordered-1.json), [ordered-2](ordered-2.json), [shuffled-7](shuffled-7.json), [shuffled-42](shuffled-42.json). Also included: [model health](model-health.json), [verification](verification.json), and [source hashes](source-manifest.json). Gold labels in artifacts are for evaluation only, not model requests.

## Implementation evidence

The inspected implementation is an **uncommitted working-tree snapshot** over base commit `{manifest['baseCommit']}`. These are not claims about committed bytes at that ref. SHA-256 hashes pin the inspected files. Paths below are relative to `feedback_aggregator/`.

- `feedback_aggregator_flutter/lib/screens/laya_poc_panel.dart:12` — RPC calls; line 88 — run/resume flow.
- `feedback_aggregator_server/lib/src/laya_poc/laya_poc_endpoint.dart:11` — login and workspace-keyed scratch state; line 42 — role-gated start/rate limiter; line 105 — idempotent step.
- `feedback_aggregator_server/lib/src/workspaces/workspace_service.dart:53` — membership/role gate; line 66 — workspace/user-scoped membership lookup.
- `feedback_aggregator_server/lib/src/laya_poc/sample_feedback.dart:33` — fixed generated fixture.
- `feedback_aggregator_server/lib/src/laya_poc/poc_run.dart:76` — lexical retrieval; line 18 — priority; line 204 — post-decision pairwise metrics.
- `feedback_aggregator_server/lib/src/laya_poc/laya_client.dart:76` — triage and pair-batch HTTP; line 173 — response validation; line 238 — policy.
- `tools/laya/run.sh:10` — local model service and pinned weights.
'''
(folder / 'report.md').write_text(md)
renderer = MarkdownIt('commonmark', {'html': True}).enable('table')
body = renderer.render(md)
body = re.sub(r'<p><img src="architecture.svg"[^>]*></p>', '<div class="diagram">'+svg+'</div>', body)
body = re.sub(r'<pre><code class="language-mermaid">(.*?)</code></pre>', r'<details><summary>Mermaid source</summary><pre><code>\1</code></pre></details>', body, flags=re.S)
styles = '''*{box-sizing:border-box}html{scroll-behavior:smooth}body{margin:0;background:#f4f6f9;color:#1b2a42;font:15px/1.7 system-ui,-apple-system,sans-serif}header{background:#132640;color:white;padding:24px max(24px,calc((100vw - 1100px)/2));display:flex;justify-content:space-between;align-items:center;gap:20px;flex-wrap:wrap}header b{font-size:13px;letter-spacing:.7px}header a{color:#c8d9ff;font-size:12px;margin-left:18px}button,select,input{font:inherit;padding:8px 12px;border:1px solid #c3cede;border-radius:6px;background:white;color:#1b2a42}button{cursor:pointer}main{max-width:1160px;margin:32px auto;padding:36px;background:white;border:1px solid #dbe2ed;border-radius:12px}h1{font-size:44px;line-height:1.12;letter-spacing:-1.5px;margin:8px 0 14px}h2{font-size:25px;line-height:1.3;letter-spacing:-.4px;margin:38px 0 16px;border-top:1px solid #e1e7f0;padding-top:28px}h2:first-of-type{border:0;padding:0;margin:0 0 20px;color:#6d7c92;font-size:14px;font-weight:500}h3{font-size:18px;margin-top:26px}p,li{max-width:100%}a{color:#285cb8;text-underline-offset:3px}code,pre{font:12px/1.65 ui-monospace,SFMono-Regular,Consolas,monospace}code{background:#edf2fa;padding:2px 4px;border-radius:4px;overflow-wrap:anywhere}pre{padding:18px;border-radius:8px;background:#11243f;color:#e1eafb;white-space:pre-wrap;overflow-wrap:anywhere}pre code{padding:0;background:none;color:inherit}table{border-collapse:collapse;width:100%;font-size:12px;margin:20px 0}th{background:#f1f5fb;color:#52657e;font-size:11px;text-transform:uppercase;letter-spacing:.5px;text-align:left}td,th{padding:11px 9px;border-bottom:1px solid #dfe6ef;vertical-align:top}td:first-child{white-space:nowrap;font-weight:600}.scroll{overflow:auto}.diagram{overflow:auto}.diagram svg{width:100%;min-width:850px;height:auto;display:block}summary{cursor:pointer;font-size:13px;font-weight:600;padding:12px 0}details{border-top:1px solid #e0e7f0}blockquote{margin:20px 0;border-left:3px solid #bd882e;padding:14px 20px;background:#fff6e6}#explorer{margin-top:40px;border-top:2px solid #1d497e;padding-top:24px}.filters{display:flex;gap:12px;flex-wrap:wrap;align-items:center}.filters label{font-size:12px}.filters input{max-width:100%;width:300px}.muted{color:#6b7b92;font-size:12px}.badge{padding:3px 6px;background:#eaf0fa;border-radius:4px;font-size:11px}footer{margin:30px auto;color:#6e7d93;font-size:12px;text-align:center}a:focus-visible,button:focus-visible,summary:focus-visible,input:focus-visible,select:focus-visible{outline:3px solid #efb14b;outline-offset:3px}@media(max-width:800px){main{padding:22px;margin:20px 12px}h1{font-size:34px}header{padding:20px 24px}.filters label{width:100%}}@media print{body{background:white;font-size:10pt}header,.filters,footer{display:none}main{max-width:none;margin:0;padding:0;border:0}h1{font-size:30px}h2{break-after:avoid;font-size:20px}table{font-size:8px}td,th{padding:6px}.diagram svg{min-width:0}.scroll{overflow:visible}#explorer{display:none}pre{background:#f3f5f8;color:#1b2a42}.diagram{break-inside:avoid}}'''
payload = json.dumps(runs, ensure_ascii=False).replace('</', '<\\/')
explorer = '''<section id="explorer"><h2>Interactive evidence explorer</h2><p>This viewer reads captured results. It makes no API calls. Open any report to inspect its text, gold label, decision, and candidate scores.</p><div class="filters"><label>Run <select id="run"><option value="ordered-2">Ordered 2</option><option value="ordered-1">Ordered 1</option><option value="shuffled-7">Shuffled seed 7</option><option value="shuffled-42">Shuffled seed 42</option></select></label><label>Outcome <select id="outcome"><option value="all">All</option><option value="merged">Merged</option><option value="new">New issue</option><option value="review">Review</option><option value="noise">Noise</option></select></label><label for="query">Search <input id="query" type="search" placeholder="Original message or source"></label></div><p id="count" class="muted" aria-live="polite"></p><div id="entries"></div></section>'''
script = '''const runs=JSON.parse(document.getElementById('evidence-data').textContent);const el=id=>document.getElementById(id);const esc=s=>String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));function render(){const r=runs[el('run').value];const ds=Object.fromEntries(r.run.decisions.map(d=>[d.reportId,d]));const q=el('query').value.toLowerCase();const rows=r.reports.filter(x=>(el('outcome').value==='all'||ds[x.id].outcome===el('outcome').value)&&(x.id+' '+x.source+' '+x.text).toLowerCase().includes(q));el('count').textContent=rows.length+' of 34 reports shown';el('entries').innerHTML=rows.map(x=>{const d=ds[x.id];return '<details><summary><span class="badge">'+esc(d.outcome)+'</span> '+esc(x.id)+' / '+esc(x.source)+' / '+esc(x.title)+' → '+esc(d.issueId||'review/unassigned')+'</summary><p>'+esc(x.text)+'</p><p class="muted">Gold (evaluation only): '+esc(x.expectedIssue||'unlabeled / vague')+' / '+esc(x.reporterId)+'</p><pre>'+esc(JSON.stringify(d,null,2))+'</pre></details>';}).join('')||'<p>No matching reports.</p>';}['run','outcome'].forEach(id=>el(id).addEventListener('change',render));el('query').addEventListener('input',render);document.querySelectorAll('main table').forEach(t=>{const w=document.createElement('div');w.className='scroll';t.replaceWith(w);w.appendChild(t);});render();'''
doc = '<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Laya POC — architecture and measured results</title><style>'+styles+'</style></head><body><header><b>FEEDBACK AGGREGATOR / LOCAL LAYA EVALUATION</b><div><button onclick="window.print()">Print / Save as PDF</button><a href="report.md" download>Markdown</a><a href="laya-poc-evidence.zip" download>Evidence bundle</a></div></header><main>'+body+explorer+'</main><footer>Recorded 09 October 2026 · Synthetic feedback only · No credentials in this artifact</footer><script id="evidence-data" type="application/json">'+payload+'</script><script>'+script+'</script></body></html>'
(folder / 'report.html').write_text(doc)
include = ['report.html','report.md','architecture.svg','build_report.py','run_evaluation.dart','source-manifest.json','model-health.json','verification.json'] + [n+'.json' for n in names] + ['source/'+n for n in ['laya_client.dart','poc_run.dart','sample_feedback.dart']]
include += [name for name in ['artifact-checks.json'] if (folder/name).exists()]
with zipfile.ZipFile(folder/'laya-poc-evidence.zip','w',zipfile.ZIP_DEFLATED) as archive:
    for name in include:
        archive.write(folder/name,name)
print('Built HTML report, Markdown report, architecture SVG, and evidence ZIP.')
