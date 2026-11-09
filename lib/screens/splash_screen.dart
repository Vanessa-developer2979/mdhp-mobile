
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../core/colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppColors.primaryDark,
          backgroundBlendMode: BlendMode.overlay,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _NetworkPatternPainter(),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primaryLight,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.4,
                          ),
                          offset: const Offset(0, 12),
                          blurRadius: 32,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        LucideIcons.shieldCheck,
                        color: Colors.white,
                        size: 52,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Text(
                    'Digital Health Passport',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Ministry of Health · Republic of Malawi',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NetworkPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.06)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = AppColors.primaryLight.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final random = math.Random(42);
    final dots = <Offset>[];

    for (int i = 0; i < 25; i++) {
      dots.add(
        Offset(
          random.nextDouble() * size.width,
          random.nextDouble() * size.height,
        ),
      );
    }

    for (int i = 0; i < dots.length; i++) {
      for (int j = i + 1; j < dots.length; j++) {
        final dx = dots[i].dx - dots[j].dx;
        final dy = dots[i].dy - dots[j].dy;

        final distance = math.sqrt(dx * dx + dy * dy);

        if (distance < 140) {
          canvas.drawLine(dots[i], dots[j], paint);
        }
      }
    }

    for (final dot in dots) {
      canvas.drawCircle(dot, 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => false;
}
