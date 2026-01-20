import 'package:flutter/material.dart';

import '../ui/auth/auth_gate.dart';
import '../ui/auth/signup_page.dart';

class PianoPrincessApp extends StatelessWidget {
  const PianoPrincessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Piano Princess',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB455FF)),
        scaffoldBackgroundColor: const Color(0xFFF9F6FF),
      ),
      home: const AuthGate(),
      routes: {
        '/signup': (_) => const SignupPage(),
      },
    );

  }
}
