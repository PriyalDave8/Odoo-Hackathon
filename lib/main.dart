import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'dashboard_screen.dart';

void main() {
  runApp(const GlobeTrotterApp());
}

class GlobeTrotterApp extends StatefulWidget {
  const GlobeTrotterApp({super.key});

  @override
  State<GlobeTrotterApp> createState() => _GlobeTrotterAppState();
}

class _GlobeTrotterAppState extends State<GlobeTrotterApp> {
  Map<String, dynamic>? currentUser;

  void _handleLoginSuccess(Map<String, dynamic> user) {
    setState(() {
      currentUser = user;
    });
  }

  void _handleLogout() {
    setState(() {
      currentUser = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GlobeTrotter - Travel Planning Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        fontFamily: 'Segoe UI',
      ),
      home: currentUser == null
          ? AuthScreen(onLoginSuccess: _handleLoginSuccess)
          : DashboardScreen(
              user: currentUser!,
              onLogout: _handleLogout,
            ),
    );
  }
}
