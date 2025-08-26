import 'package:daryache/main.dart';
import 'package:daryache/word_puzzle_game.dart';
import 'package:flutter/material.dart';

class Daryache extends StatefulWidget {
  const Daryache({super.key});

  @override
  State<Daryache> createState() => _DaryacheState();
}

class _DaryacheState extends State<Daryache> {
  ThemeMode _mode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'دریاچه ارومیه',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Vazir',
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
        fontFamily: 'Vazir',
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
      builder: (context, child) {
        return Directionality(textDirection: TextDirection.rtl, child: child!);
      },
    );
  }
}
