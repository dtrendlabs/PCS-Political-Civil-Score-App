import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/profile_screen.dart';

void main() {
  runApp(const PCSApp());
}

class PCSApp extends StatelessWidget {
  const PCSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Civil Ledger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B2A4A),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
      ),
      home: const ProfileScreen(),
    );
  }
}
