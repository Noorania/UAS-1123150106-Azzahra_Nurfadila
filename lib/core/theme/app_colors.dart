import 'package:flutter/material.dart';

class AppColors {
  // Primary (Tombol utama, CTA, icon aktif, saldo, progress, switch aktif, FAB)
  static const Color primary = Color(0xFFD33243);
  static const Color primaryDark = Color(0xFFB82A39);
  static const Color primaryLight = Color(0xFFFDECED);

  // Secondary (Transfer, top up, pembayaran, quick menu, badge, chip)
  static const Color secondary = Color(0xFF3B9890);
  static const Color secondaryLight = Color(0xFFE8F8F2);

  // Success / Dark Olive (Transaksi berhasil, cashback, reward, success message)
  static const Color success = Color(0xFF718804);
  static const Color darkOlive = Color(0xFF718804);

  // Accent / Light Lime (Voucher, poin, promo, informasi)
  static const Color accent = Color(0xFFA9BF53);
  static const Color lightLime = Color(0xFFA9BF53);

  // Soft Accent (Promo card, banner, ilustrasi, empty state)
  static const Color softPink = Color(0xFFE07C8E);
  static const Color mint = Color(0xFFA0D8CD);

  // Semantic
  static const Color warning = Color(0xFFD98512); // Amber
  static const Color error = Color(0xFFE5484D);

  // Background & Surface
  static const Color bg = Color(0xFFF8F9FA); // Background
  static const Color white = Color(0xFFFFFFFF); // Surface

  // Typography
  static const Color ink = Color(0xFF1D1D1F); // Text Primary
  static const Color slate500 = Color(0xFF6B7280); // Text Secondary
  static const Color slate400 = Color(0xFF9DABBE);
  static const Color slate600 = Color(0xFF6B7280);

  // Border & Divider
  static const Color line = Color(0xFFECECEC);
  static const Color line2 = Color(0xFFF3F5F8);

  // Keep compatibility for old fields that we might miss, mapped to new palette
  static const Color green = secondary;
  static const Color gold = primary; // Fallback mapping
  static const Color violet = Color(0xFF7A5AF8);
  static const Color primarySurface = softPink;
  static const Color amber = warning;
  static const Color amberSurface = mint;
  static const Color red = primary;
  static const Color redSurface = primaryLight;
  static const Color slate300 = slate400;
  static const Color primaryBorder = line;
  static const Color greenSurface = secondaryLight;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, softPink],
  );

  static const LinearGradient goldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, softPink],
  );

  // Shadows
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: const Color(0x0A000000),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> shadowSoft = [
    BoxShadow(
      color: const Color(0x08000000),
      blurRadius: 8,
      spreadRadius: 0,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> shadowPrimary = [
    BoxShadow(
      color: primary.withOpacity(0.25),
      blurRadius: 16,
      spreadRadius: 0,
      offset: const Offset(0, 8),
    ),
  ];

  // Tone map for FeatureIcon
  static Map<String, List<Color>> tones = {
    'blue': [mint.withOpacity(0.3), secondary],
    'gold': [softPink.withOpacity(0.3), primary],
    'green': [lightLime.withOpacity(0.3), darkOlive],
    'amber': [mint.withOpacity(0.3), secondary], // replaced
    'red': [primaryLight, primary],
    'violet': [softPink.withOpacity(0.3), primary], // replaced
    'slate': [Colors.white, slate600],
  };

  static List<Color> tone(String name) => tones[name] ?? tones['gold']!;
}
