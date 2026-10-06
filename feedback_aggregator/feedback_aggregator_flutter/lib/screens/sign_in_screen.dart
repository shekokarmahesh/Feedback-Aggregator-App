import 'package:flutter/material.dart';
import 'package:serverpod_auth_idp_flutter/serverpod_auth_idp_flutter.dart';

import '../client.dart';
import 'email_password_form.dart';
import 'landing_screen.dart';

class SignInScreen extends StatefulWidget {
  final Widget child;
  final bool showLanding;
  final bool initialSignUp;
  const SignInScreen({
    super.key,
    required this.child,
    this.showLanding = true,
    this.initialSignUp = false,
  });

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    client.auth.authInfoListenable.addListener(_updateSignedInState);
    _isSignedIn = client.auth.isAuthenticated;
  }

  @override
  void dispose() {
    client.auth.authInfoListenable.removeListener(_updateSignedInState);
    super.dispose();
  }

  void _updateSignedInState() {
    setState(() {
      _isSignedIn = client.auth.isAuthenticated;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return _isSignedIn
        ? widget.child
        : widget.showLanding
        ? const LandingScreen()
        : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextButton.icon(
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false),
                          icon: const Icon(Icons.arrow_back, size: 16),
                          label: const Text('Back to home'),
                        ),
                        const SizedBox(height: 16),
                        Icon(
                          Icons.forum_outlined,
                          size: 40,
                          color: colors.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Welcome to Feedback Aggregator',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sign in or create an account to get started.',
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        EmailPasswordForm(initialSignUp: widget.initialSignUp),
                        if (googleSignInEnabled) ...[
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text('or'),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          GoogleSignInWidget(
                            client: client,
                            onAuthenticated: () {
                              context.showSnackBar(
                                message: 'User authenticated.',
                                backgroundColor: colors.primaryContainer,
                                foregroundColor: colors.onPrimaryContainer,
                              );
                            },
                            onError: (error) {
                              context.showSnackBar(
                                message: 'Could not sign in. Please try again.',
                                backgroundColor: colors.errorContainer,
                                foregroundColor: colors.onErrorContainer,
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}

extension on BuildContext {
  void showSnackBar({
    required String message,
    required Color backgroundColor,
    required Color foregroundColor,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: foregroundColor)),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 5),
      ),
    );
  }
}
