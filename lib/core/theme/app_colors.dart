import 'package:flutter/material.dart';

class AppColors {
  // Accent Cream (Luxury Identity)
  static const Color primary = Color(0xFFFFF5E1);
  static const Color primaryLight = Color(0xFFFFFDF5);
  static const Color primaryDark = Color(0xFFEAD8B5);
  static const Color primarySurface = Color(0xFFFFF9EE);
  static const Color primaryBorder = Color(0xFFF5E1C3);

  // Champagne Gold (Primary Interactive)
  static const Color gold = Color(0xFFCFAF6D);
  static const Color goldLight = Color(0xFFD9B97A);
  static const Color goldDark = Color(0xFFB5934F);

  // Semantic
  static const Color green = Color(0xFF16A571);
  static const Color greenSurface = Color(0xFFE8F8F2);
  static const Color amber = Color(0xFFD98512);
  static const Color amberSurface = Color(0xFFFDF3E3);
  static const Color red = Color(0xFFE5484D);
  static const Color redSurface = Color(0xFFFDECED);
  static const Color violet = Color(0xFF7A5AF8);
  static const Color violetSurface = Color(0xFFF0EEFF);

  // Neutral (Refined)
  static const Color ink = Color(0xFF1C1C1C); // Dark charcoal
  static const Color slate600 = Color(0xFF6B7280); // Medium gray
  static const Color slate500 = Color(0xFF6B7280); // Medium gray
  static const Color slate400 = Color(0xFF9DABBE);
  static const Color slate300 = Color(0xFFCBD2DD);
  static const Color line = Color(0xFFE8ECF2);
  static const Color line2 = Color(0xFFF3F5F8);
  static const Color bg = Color(0xFFFAFAF8); // Soft off-white
  static const Color white = Color(0xFFFFFFFF); // Pure white cards

  // Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.55, 1.0],
    colors: [primaryLight, primary, primaryDark],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 1.0],
    colors: [goldLight, gold],
  );

  // Shadows (Soft & Elegant Material 3)
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Color(0x08000000), // Very subtle shadow for pure white cards
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 4),
    ),
  ];
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: Color(0x05000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: Offset(0, 2),
    ),
  ];
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: gold.withOpacity(0.25), // Soft gold shadow
      blurRadius: 16,
      spreadRadius: 0,
      offset: Offset(0, 8),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [primarySurface, primaryDark],
    'gold': [primarySurface, gold],
    'green': [greenSurface, green],
    'amber': [amberSurface, amber],
    'red': [redSurface, red],
    'violet': [violetSurface, violet],
    'slate': [Colors.white, slate600],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['gold']!;
}
