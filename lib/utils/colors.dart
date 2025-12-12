import 'package:flutter/material.dart';

class AppColors {
  static const Color purple = Color(0xFF9333EA);
  static const Color purpleDark = Color(0xFF7C3AED);
  static const Color pink = Color(0xFFEC4899);
  static const Color rose = Color(0xFFF43F5E);
  static const Color orange = Color(0xFFF97316);
  static const Color amber = Color(0xFFF59E0B);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color blue = Color(0xFF3B82F6);
  static const Color indigo = Color(0xFF6366F1);

  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purple, pink, orange],
  );

  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [purple, pink],
  );

  static const LinearGradient textGradient = LinearGradient(
    colors: [purple, pink],
  );
}
