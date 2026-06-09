import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Large headline — "Move Anything, Anytime"
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
    letterSpacing: -0.5,
  );

  // Medium headline — "Choose. Book. Move."
  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    height: 1.2,
    letterSpacing: -0.3,
  );

  // Role selection headline — "How do you want to use the app?"
  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
    height: 1.3,
  );

  // Body text — descriptions under headlines
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.6,
  );

  // Subtitle — "Choose your role to get started"
  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textMedium,
    height: 1.5,
  );

  // Button text — "Book a Vehicle", "Drive & Earn"
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  // "Get Started" button text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    color: AppColors.white,
  );
}