import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const ProviderScope(child: TranscribeFlowApp()));
}

class TranscribeFlowApp extends StatelessWidget {
  const TranscribeFlowApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TranscribeFlow Enterprise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF01060E), // Deep Navy
        primaryColor: const Color(0xFF00C6FB), // Electric Blue
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00C6FB),
          secondary: Color(0xFFFF00CC), // Vibrant Purple
          surface: Color(0xFF0A192F), // Glassy Navy
          background: Color(0xFF01060E),
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0A192F).withOpacity(0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00C6FB)),
          ),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
