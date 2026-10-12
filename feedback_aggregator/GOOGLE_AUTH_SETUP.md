# Google sign-in setup

Use Serverpod's built-in Google provider alongside the existing email/password provider. Google requires a Cloud project and OAuth client credentials; a Google account and Cloud project are free. This setup does not require a paid Cloud hosting plan, Firebase, Clerk, or a Cloud free-trial subscription. Use the team's project Google account, and grant collaborators access to the Cloud project instead of sharing passwords.

## 1. Create the OAuth client

1. Sign into [Google Cloud Console](https://console.cloud.google.com/projectcreate) with the team's Google account. Create a project named **Feedback Aggregator**.
2. Open **Google Auth Platform**, click **Get started**, and enter the app name, support email, and contact email. Choose **External** for the audience.
3. In **Audience**, keep **Testing** and add your and your teammates' Google emails as test users.
4. In **Data Access**, use only `openid`, `.../auth/userinfo.email`, and `.../auth/userinfo.profile` for sign-in.
5. In **Clients**, create a **Web application** OAuth client named **Feedback Aggregator Web**.
6. Set **Authorized JavaScript origins** to `http://localhost:8082`.
7. Set **Authorized redirect URIs** to `http://localhost:8082/auth/callback`.
8. Download the client's JSON credentials and save them privately. Do not commit the JSON or send the client secret in chat.

The client ID is public; the client secret stays on the backend. You do not need Android or iOS OAuth clients for this Flutter website.

## 2. Configure the backend

Open `feedback_aggregator_server/config/passwords.yaml`, which is Git-ignored. Add this entry **inside the existing `development:` section**, preserving its other keys:

```yaml
  googleClientSecret: |
    {"web":{"client_id":"YOUR_CLIENT_ID.apps.googleusercontent.com","client_secret":"YOUR_CLIENT_SECRET","redirect_uris":["http://localhost:8082/auth/callback"]}}
```

Use the values from the downloaded JSON. Alternatively, set the complete JSON as the `SERVERPOD_PASSWORD_googleClientSecret` environment variable in the terminal that starts the backend.

The backend enables Google only when this secret is configured. Email/password continues to work without it. The initial database migration already includes Google's authentication tables, so no new schema migration is required.

## 3. Build and run the website

First configure the ignored `.env` using [collaborator setup](COLLABORATOR_SETUP.md). From the `feedback_aggregator` directory:

```sh
cd feedback_aggregator_server
set -a
. ./.env
set +a
cd ../feedback_aggregator_flutter
flutter build web --base-href / --output ../feedback_aggregator_server/web/app \
  --dart-define=GOOGLE_CLIENT_ID=YOUR_CLIENT_ID.apps.googleusercontent.com
cd ../feedback_aggregator_server
serverpod start --no-flutter
```

Open **http://localhost:8082/**. Google sign-in returns to `/auth/callback` on this same origin. For this setup, test the built website served by Serverpod; `flutter run -d chrome` uses another origin. Rebuild after changing the client ID or Flutter code.

Without `GOOGLE_CLIENT_ID`, the website shows email/password only. Google is enabled for web; native targets require their own OAuth setup before enabling the native provider.

## 4. Check both methods

- **Email:** enter email and password, or choose Create an account. Sign-up signs you in immediately without an OTP. Sign out and sign back in with the password.
- **Password reset:** request a reset and use the code delivered to your inbox through Resend. See [email delivery setup](EMAIL_AUTH_SETUP.md).
- **Google:** choose Google and sign in with an allowed test user. Confirm you return to the app and can sign out.
- **Session:** reload the website after sign-in; the stored Serverpod session should restore.

Password-reset emails use Resend in development and production. Google sign-in does not provide email delivery. Configure a verified Resend sender for delivery to all users.

## Deployment

Add the deployed HTTPS origin and exact `/auth/callback` URL to the same Web OAuth client's allowed URLs, and put the credentials into the server's production secret configuration. Rebuild the web app with the public client ID and serve it from that origin. Complete Google's branding/publishing requirements before allowing users outside your test list.

## Official references

- [Google's sign-in codelab: free Cloud account and project](https://codelabs.developers.google.com/codelabs/sign-in-with-google-button)
- [Google OAuth client setup](https://developers.google.com/identity/gsi/web/guides/get-google-api-clientid)
- [Serverpod Google provider setup and web callback](https://docs.serverpod.dev/concepts/authentication/providers/google/setup)
