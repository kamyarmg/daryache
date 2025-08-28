import 'package:crossword_for_programmers/main.dart';
import 'package:crossword_for_programmers/word_puzzle_game.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crossword For Programmers',
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
