import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';

class AppColors {
  static const primary = Color(0xFFD6202F);
  static const primaryDark = Color(0xFF8E1520);
  static const accent = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const success = Color(0xFF16A34A);
  static const info = Color(0xFF2563EB);
}

class CategoryInfo {
  final String name;
  final IconData icon;
  final Color color;
  const CategoryInfo(this.name, this.icon, this.color);
}

const List<CategoryInfo> kCategories = [
  CategoryInfo('Lingkungan', Icons.eco, Color(0xFF15803D)),
  CategoryInfo('Pendidikan', Icons.school, Color(0xFF2563EB)),
  CategoryInfo('Kesehatan', Icons.health_and_safety, Color(0xFFDB2777)),
  CategoryInfo('Sosial', Icons.groups, Color(0xFFEA580C)),
  CategoryInfo('Kemanusiaan', Icons.volunteer_activism, Color(0xFFDC2626)),
  CategoryInfo('Hewan', Icons.pets, Color(0xFF92400E)),
  CategoryInfo('Budaya', Icons.palette, Color(0xFF7C3AED)),
  CategoryInfo('Teknologi', Icons.computer, Color(0xFF4338CA)),
];

CategoryInfo categoryInfo(String name) =>
    kCategories.firstWhere((c) => c.name == name, orElse: () => kCategories[3]);

String typeLabel(ActivityType t) {
  switch (t) {
    case ActivityType.event:
      return 'Event';
    case ActivityType.regular:
      return 'Regular';
    case ActivityType.project:
      return 'Project';
    case ActivityType.webinar:
      return 'Webinar';
  }
}

IconData typeIcon(ActivityType t) {
  switch (t) {
    case ActivityType.event:
      return Icons.event;
    case ActivityType.regular:
      return Icons.repeat;
    case ActivityType.project:
      return Icons.assignment;
    case ActivityType.webinar:
      return Icons.videocam;
  }
}

String typeDesc(ActivityType t) {
  switch (t) {
    case ActivityType.event:
      return 'Kegiatan sekali jalan';
    case ActivityType.regular:
      return 'Kegiatan rutin berkala';
    case ActivityType.project:
      return 'Program jangka panjang';
    case ActivityType.webinar:
      return 'Kelas & diskusi online';
  }
}

ThemeData buildTheme(Brightness b) {
  final dark = b == Brightness.dark;
  final scheme = ColorScheme.fromSeed(seedColor: AppColors.primary, brightness: b);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? const Color(0xFF121212) : Colors.white,
    
    // Menerapkan font modern Plus Jakarta Sans secara global ke seluruh teks aplikasi
    fontFamily: GoogleFonts.plusJakartaSans().fontFamily,
    textTheme: GoogleFonts.plusJakartaSansTextTheme(
      ThemeData(brightness: b).textTheme,
    ),

    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, fontSize: 15),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 15),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: dark ? const Color(0xFF1B1B1B) : Colors.white,
      indicatorColor: dark ? const Color(0xFF4A1A20) : const Color(0xFFFDE8EA),
      height: 68,
    ),
  );
}

extension Ui on BuildContext {
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get cardBg => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color get line => isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB);
  Color get muted => isDark ? const Color(0xFFA3A3A3) : const Color(0xFF6B7280);
  Color get softTeal => isDark ? const Color(0xFF3A1A1E) : const Color(0xFFFDECEE);
  Color get band => isDark ? const Color(0xFF181818) : const Color(0xFFF5F5F6);
  double get screenW => MediaQuery.of(this).size.width;
  bool get isWide => screenW >= 900;
}

InputDecoration inputDeco({
  String? labelText,
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool? alignLabelWithHint,
}) {
  OutlineInputBorder b(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: c, width: w));
  return InputDecoration(
    labelText: labelText,
    hintText: hintText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    alignLabelWithHint: alignLabelWithHint,
    filled: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: b(const Color(0x40808080)),
    enabledBorder: b(const Color(0x40808080)),
    focusedBorder: b(AppColors.primary, 1.8),
  );
}