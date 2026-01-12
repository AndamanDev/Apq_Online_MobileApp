import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF17A2B8);
  static const background = Color(0xFF2B3A49);
  static const field = Color(0xFF3A4A5C);
  static const accent = Color(0xFFD96A7A);
  static const white = Colors.white;
  static const orange = Color.fromARGB(255, 224, 162, 6);
  static const green = Colors.green;
  static const red = Colors.red;
}

class AppTextStyles {
  static const logo = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  static const button = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const input = TextStyle(
    color: AppColors.primary,
    fontSize: 16,
  );

  static const hint = TextStyle(
    color: AppColors.primary,
  );
}

class AppSize {
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  static double font(BuildContext context, double size) {
    final scale = screenWidth(context) / 375; 
    return size * scale.clamp(0.85, 1.2);
  }

  static double space(BuildContext context, double size) {
    final scale = screenHeight(context) / 812;
    return size * scale.clamp(0.85, 1.2);
  }
}
