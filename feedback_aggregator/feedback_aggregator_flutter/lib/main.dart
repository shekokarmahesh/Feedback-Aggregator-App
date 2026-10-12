import 'package:flutter/material.dart';

import 'client.dart';
import 'screens/workspace_shell.dart';
import 'screens/invitation_screen.dart';
import 'screens/sign_in_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeClient();
  runApp(const MyApp());
}

/// Builds a theme for the given [brightness].
ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF4F46E5),
      brightness: brightness,
    ),
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Feedback Aggregator',
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: ThemeMode.light,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '/');
        if (uri.path == '/invite') {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => MyHomePage(
              showLanding: false,
              invitationToken: uri.queryParameters['token'] ?? '',
            ),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => MyHomePage(
          initialWorkspaceId:
              ModalRoute.of(context)?.settings.arguments as int?,
        ),
        '/login': (context) => const MyHomePage(showLanding: false),
        '/signup': (context) =>
            const MyHomePage(showLanding: false, initialSignUp: true),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({
    super.key,
    this.showLanding = true,
    this.initialSignUp = false,
    this.invitationToken,
    this.initialWorkspaceId,
  });

  final bool showLanding;
  final bool initialSignUp;
  final String? invitationToken;
  final int? initialWorkspaceId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SignInScreen(
        showLanding: showLanding,
        initialSignUp: initialSignUp,
        invitation: invitationToken != null,
        child: invitationToken != null
            ? InvitationScreen(token: invitationToken!)
            : WorkspaceShell(initialWorkspaceId: initialWorkspaceId),
      ),
    );
  }
}
