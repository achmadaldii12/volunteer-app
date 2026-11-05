import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'core/theme.dart';
import 'providers/app_state.dart';
import 'screens/auth_screens.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID');
  runApp(ChangeNotifierProvider(
    create: (_) => AppState()..init(),
    child: const VolunteerApp(),
  ));
}

class VolunteerApp extends StatelessWidget {
  const VolunteerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return MaterialApp(
      title: 'Volunteer',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: s.themeMode,
      home: !s.ready
          ? const _Splash()
          : !s.onboarded
              ? const OnboardingScreen()
              : s.user == null
                  ? const LoginScreen()
                  : const MainShell(),
    );
  }
}

class _Splash extends StatelessWidget {
  const _Splash();

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.primary,
        body: Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.volunteer_activism, size: 76, color: Colors.white),
            SizedBox(height: 14),
            Text('Volunteer',
                style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
            SizedBox(height: 24),
            SizedBox(
                width: 26,
                height: 26,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white)),
          ]),
        ),
      );
}
