import 'dart:ui' as ui;

import 'package:deniz/deniz.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Deniz());
}

class Position {
  final int row;
  final int col;

  Position(this.row, this.col);
}

class UrmiaColors {
  static const background = Color(0xFFEFF7FA); // airy light
  static const deepBlue = Color(0xFF1E40AF); // modern deep blue
  static const turquoise = ui.Color.fromARGB(255, 103, 159, 248); // surface
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

class ModernBlueBackground extends StatelessWidget {
  final bool isDark;

  const ModernBlueBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Layered modern blue background with soft glowing blobs
    final baseGradientColors = isDark
        ? const [Color(0xFF0E2A47), Color(0xFF0B1F33)]
        // Light mode: predominantly white with the faintest blue tint
        : const [Colors.white, Color(0xFFFAFDFF)];

    final Size size = MediaQuery.of(context).size;

    return SizedBox.expand(
      child: Stack(
        children: [
          // Base gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: baseGradientColors,
                ),
              ),
            ),
          ),
          // Layered modern wave shapes
          Positioned.fill(
            child: CustomPaint(
              painter: BlueWhiteBackgroundPainter(isDark: isDark),
            ),
          ),
          // Glow blobs (lightweight bokeh-style accents)
          Positioned(
            top: -size.width * 0.22,
            right: -size.width * 0.18,
            child: _GlowBlob(
              size: size.width * 0.7,
              colors: [
                (isDark
                        ? UrmiaColors.turquoise.lighten(0.2)
                        : UrmiaColors.turquoise)
                    .withValues(alpha: isDark ? 0.20 : 0.06),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            bottom: -size.width * 0.28,
            left: -size.width * 0.22,
            child: _GlowBlob(
              size: size.width * 0.9,
              colors: [
                UrmiaColors.deepBlue.withValues(alpha: isDark ? 0.35 : 0.05),
                Colors.transparent,
              ],
            ),
          ),
          Positioned(
            top: size.height * 0.35,
            left: -size.width * 0.15,
            child: _GlowBlob(
              size: size.width * 0.6,
              colors: [
                (isDark ? UrmiaColors.turquoise : UrmiaColors.turquoise)
                    .withValues(alpha: isDark ? 0.18 : 0.04),
                Colors.transparent,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final List<Color> colors;

  const _GlowBlob({required this.size, required this.colors});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: colors, stops: const [0.0, 1.0]),
          ),
        ),
      ),
    );
  }
}

class BlueWhiteBackgroundPainter extends CustomPainter {
  final bool isDark;

  BlueWhiteBackgroundPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wave 1: top-right smooth ribbon
    final path1 = Path()
      ..moveTo(w * 0.45, -h * 0.02)
      ..lineTo(w, -h * 0.02)
      ..lineTo(w, h * 0.28)
      ..cubicTo(w * 0.85, h * 0.18, w * 0.68, h * 0.12, w * 0.48, h * 0.16)
      ..close();
    final paint1 = Paint()..isAntiAlias = true;
    paint1.shader = ui.Gradient.linear(Offset(w, 0), Offset(w * 0.4, h * 0.2), [
      (isDark ? UrmiaColors.turquoise : UrmiaColors.turquoise).withValues(
        alpha: isDark ? 0.18 : 0.10,
      ),
      Colors.white.withValues(alpha: 0.0),
    ]);
    canvas.drawPath(path1, paint1);

    // Wave 2: bottom-left soft rise
    final path2 = Path()
      ..moveTo(-w * 0.02, h * 0.72)
      ..cubicTo(w * 0.18, h * 0.65, w * 0.34, h * 0.78, w * 0.46, h * 0.76)
      ..lineTo(w * 0.46, h)
      ..lineTo(-w * 0.02, h)
      ..close();
    final paint2 = Paint()..isAntiAlias = true;
    paint2.shader = ui.Gradient.linear(Offset(0, h), Offset(w * 0.5, h * 0.7), [
      UrmiaColors.deepBlue.withValues(alpha: isDark ? 0.18 : 0.08),
      Colors.white.withValues(alpha: 0.0),
    ]);
    canvas.drawPath(path2, paint2);

    // Wave 3: center gentle band
    final path3 = Path()
      ..moveTo(0, h * 0.42)
      ..cubicTo(w * 0.18, h * 0.36, w * 0.36, h * 0.52, w * 0.56, h * 0.46)
      ..lineTo(w, h * 0.46)
      ..lineTo(w, h * 0.40)
      ..lineTo(0, h * 0.40)
      ..close();
    final paint3 = Paint()..isAntiAlias = true;
    paint3.shader =
        ui.Gradient.linear(Offset(0, h * 0.42), Offset(w, h * 0.46), [
          UrmiaColors.turquoise.withValues(alpha: isDark ? 0.12 : 0.06),
          Colors.white.withValues(alpha: 0.0),
        ]);
    canvas.drawPath(path3, paint3);
  }

  @override
  bool shouldRepaint(covariant BlueWhiteBackgroundPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
