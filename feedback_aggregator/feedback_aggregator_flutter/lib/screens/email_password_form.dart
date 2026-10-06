import 'package:feedback_aggregator_client/feedback_aggregator_client.dart';
import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart';
import '../client.dart';

enum _Step { signIn, signUp, requestReset, verifyReset, newPassword }

class EmailPasswordForm extends StatefulWidget {
  const EmailPasswordForm({super.key, this.initialSignUp = false});
  final bool initialSignUp;
  @override
  State<EmailPasswordForm> createState() => _EmailPasswordFormState();
}

class _EmailPasswordFormState extends State<EmailPasswordForm> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  final _code = TextEditingController();
  _Step _step = _Step.signIn;
  UuidValue? _requestId;
  String? _resetToken;
  String? _error;
  bool _busy = false;
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    _step = widget.initialSignUp ? _Step.signUp : _Step.signIn;
  }

  @override
  void dispose() {
    for (final controller in [_email, _password, _confirm, _code]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _go(_Step step) {
    setState(() {
      _step = step;
      _error = null;
      _password.clear();
      _confirm.clear();
      _code.clear();
    });
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final email = _email.text.trim().toLowerCase();
    try {
      switch (_step) {
        case _Step.signIn:
          final result = await client.emailIdp.login(
            email: email,
            password: _password.text,
          );
          await client.auth.updateSignedInUser(result);
        case _Step.signUp:
          final result = await client.emailIdp.register(
            email: email,
            password: _password.text,
          );
          await client.auth.updateSignedInUser(result);
        case _Step.requestReset:
          _requestId = await client.emailIdp.startPasswordReset(email: email);
          if (mounted) _go(_Step.verifyReset);
        case _Step.verifyReset:
          _resetToken = await client.emailIdp.verifyPasswordResetCode(
            passwordResetRequestId: _requestId!,
            verificationCode: _code.text.trim(),
          );
          if (mounted) _go(_Step.newPassword);
        case _Step.newPassword:
          await client.emailIdp.finishPasswordReset(
            finishPasswordResetToken: _resetToken!,
            newPassword: _password.text,
          );
          if (mounted) {
            _go(_Step.signIn);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Password updated. Sign in with your new password.',
                ),
              ),
            );
          }
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = switch (error) {
            AuthFlowException() => error.message,
            EmailAccountLoginException() =>
              error.reason.name == 'tooManyAttempts'
                  ? 'Too many attempts. Please try again later.'
                  : 'Email or password is incorrect.',
            EmailAccountPasswordResetException() => switch (error.reason.name) {
              'tooManyAttempts' =>
                'Too many attempts. Please request another code later.',
              'policyViolation' =>
                'Use at least 8 characters without spaces at the ends.',
              'expired' => 'This code has expired. Request a new one.',
              _ =>
                'The code is incorrect or no longer valid. Please try again.',
            },
            _ => 'Could not complete this request. Please try again.',
          },
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPassword = [
      _Step.signIn,
      _Step.signUp,
      _Step.newPassword,
    ].contains(_step);
    final hasConfirm = [_Step.signUp, _Step.newPassword].contains(_step);
    final title = switch (_step) {
      _Step.signIn => 'Sign in with email',
      _Step.signUp => 'Create your account',
      _Step.requestReset => 'Forgot your password?',
      _Step.verifyReset => 'Check your inbox',
      _Step.newPassword => 'Choose a new password',
    };
    return AutofillGroup(
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            if (_step == _Step.verifyReset) ...[
              const Text(
                'If an email account exists, we sent a code to its inbox. The code expires in 15 minutes.',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _code,
                decoration: const InputDecoration(
                  labelText: 'Reset code',
                  border: OutlineInputBorder(),
                ),
                autofillHints: const [AutofillHints.oneTimeCode],
                enabled: !_busy,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter the code from your email.'
                    : null,
                onFieldSubmitted: (_) => _busy ? null : _submit(),
              ),
            ] else if (_step != _Step.newPassword) ...[
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value == null ||
                        !RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(value.trim())
                    ? 'Enter a valid email.'
                    : null,
              ),
            ],
            if (hasPassword) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _hidePassword,
                enabled: !_busy,
                autofillHints: [
                  _step == _Step.signIn
                      ? AutofillHints.password
                      : AutofillHints.newPassword,
                ],
                decoration: InputDecoration(
                  labelText: _step == _Step.newPassword
                      ? 'New password'
                      : 'Password',
                  helperText: _step == _Step.signIn
                      ? null
                      : 'At least 8 characters',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    tooltip: _hidePassword ? 'Show password' : 'Hide password',
                    onPressed: () =>
                        setState(() => _hidePassword = !_hidePassword),
                    icon: Icon(
                      _hidePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter your password.';
                  }
                  if (_step != _Step.signIn &&
                      (value.length < 8 ||
                          value.length > 256 ||
                          value.trim() != value)) {
                    return 'Use 8–256 characters without spaces at the ends.';
                  }
                  return null;
                },
                onFieldSubmitted: (_) => _busy ? null : _submit(),
              ),
            ],
            if (hasConfirm) ...[
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirm,
                obscureText: _hidePassword,
                enabled: !_busy,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value != _password.text ? 'Passwords do not match.' : null,
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                semanticsLabel: _error,
              ),
            ],
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _busy ? null : _submit,
              child: _busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(switch (_step) {
                      _Step.signIn => 'Sign in',
                      _Step.signUp => 'Create account',
                      _Step.requestReset => 'Send reset code',
                      _Step.verifyReset => 'Verify code',
                      _Step.newPassword => 'Update password',
                    }),
            ),
            if (_step == _Step.signIn) ...[
              TextButton(
                onPressed: _busy ? null : () => _go(_Step.requestReset),
                child: const Text('Forgot password?'),
              ),
              TextButton(
                onPressed: _busy ? null : () => _go(_Step.signUp),
                child: const Text('Create an account'),
              ),
            ] else ...[
              if (_step == _Step.verifyReset)
                TextButton(
                  onPressed: _busy ? null : () => _go(_Step.requestReset),
                  child: const Text('Request a new code'),
                ),
              TextButton(
                onPressed: _busy ? null : () => _go(_Step.signIn),
                child: const Text('Back to sign in'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
