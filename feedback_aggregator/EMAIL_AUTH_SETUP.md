# Email and password authentication

Sign-in uses an email and password. Sign-up creates a new Serverpod identity and signs in immediately, without an OTP. Passwords are hashed by Serverpod's Argon2 implementation. New passwords must have 8–256 characters with no whitespace at either end. Duplicate registrations do not enter a code-verification flow; the app offers sign-in or password recovery instead.

Signup does not prove email ownership. The app never attaches a password to an existing Google identity based only on a matching email address. Use authenticated user IDs for authorization, not an email address supplied at signup.

## Resend delivery

The supplied local API key is configured under `development.resendApiKey` in the Git-ignored `feedback_aggregator_server/config/passwords.yaml`. The original `api key` file is also ignored. Do not include either file in Git.

Add the following keys to the appropriate run-mode section for deployment, or use Serverpod's secret environment variables:

```yaml
  resendApiKey: 'YOUR_RESEND_API_KEY'
  resendFromEmail: 'Feedback Aggregator <auth@your-verified-domain.com>'
```

```sh
export SERVERPOD_PASSWORD_resendApiKey='YOUR_RESEND_API_KEY'
export SERVERPOD_PASSWORD_resendFromEmail='Feedback Aggregator <auth@your-verified-domain.com>'
```

The default sender is `Feedback Aggregator <onboarding@resend.dev>`. Resend restricts this test domain to the Resend account owner's inbox and its synthetic test addresses. Your account had no verified domains when checked. To deliver to other users, [add and verify a domain](https://resend.com/docs/dashboard/domains/introduction) and configure `resendFromEmail` using that domain. No domain or sender changes are performed automatically.

## Password reset

1. Choose **Forgot password?**, enter the email, and request a code.
2. If an email/password account exists, Resend sends the real generated code with the branded HTML template and a plain-text fallback. Unknown emails return the same UI message without sending an email.
3. Enter the code from the inbox. Codes expire after 15 minutes and have a limited number of verification attempts.
4. Set and confirm a new password, then sign in. The password-reset token cannot be reused.

Serverpod retains its built-in failed-login and reset-request limits. Registration also limits attempts per normalized email. Delivery errors fail the request instead of claiming success. Logs show provider status without exposing codes, passwords, or API keys.

The template lives in `feedback_aggregator_server/lib/src/auth/auth_email.dart`: responsive table layout, indigo branding, prominent code, expiration notice, and account-security guidance. It contains no remote tracking image.

## Rebuild and run

From `feedback_aggregator/feedback_aggregator_flutter`:

```sh
flutter build web --base-href / --output ../feedback_aggregator_server/web/app \
  --dart-define=GOOGLE_CLIENT_ID=663935922190-jp360n41iutrlv9d6q9uopdile56e4hn.apps.googleusercontent.com
```

Restart the Serverpod runner after changing secret configuration. Open http://localhost:8082 and reload the page to load the new build. Google sign-in continues to use the existing OAuth configuration.
