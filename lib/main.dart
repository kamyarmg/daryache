import 'dart:ui' as ui;

import 'package:daryache/daryache.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Daryache());
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);
}

class UrmiaColors {
  static const background = Color(0xFFEFF7FA); // airy light
  static const deepBlue = Color(0xFF136A8A); // lake depth
  static const turquoise = Color(0xFF27B1D9); // surface
  static const saltPink = Color(0xFFFF7EA8); // seasonal pink hue
}

extension ColorShade on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final h = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return h.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final h = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return h.toColor();
  }
}

class Glass extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double radius;

  const Glass({super.key, required this.child, this.padding, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Tuned glass variables for light vs dark
    final gradientColors = isDark
        ? [
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.06),
          ]
        : [
            Colors.white.withValues(alpha: 0.20),
            Colors.white.withValues(alpha: 0.10),
          ];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.white.withValues(alpha: 0.35);
    final shadowColor = isDark
        ? Colors.black.withValues(alpha: 0.30)
        : Colors.black.withValues(alpha: 0.06);
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            // Layered gradient to simulate frosted glass with depth
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: shadowColor,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
