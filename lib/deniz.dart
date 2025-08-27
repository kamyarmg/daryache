import 'package:deniz/main.dart';
import 'package:deniz/word_puzzle_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Deniz extends StatefulWidget {
  const Deniz({super.key});

  @override
  State<Deniz> createState() => _DenizState();
}

class _DenizState extends State<Deniz> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deniz',
      locale: const Locale('en'),
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: UrmiaColors.turquoise,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: UrmiaColors.background,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: UrmiaColors.deepBlue,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0E1A2A),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      themeMode: _mode,
      home: WordPuzzleGame(
        onToggleTheme: _toggleTheme,
        isDark: _mode == ThemeMode.dark,
      ),
    );
  }
}
