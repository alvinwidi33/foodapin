
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFFFD4068);
  static const Color secondary = Color(0xFFF58663);
  static const Color tertiary = Color(0xFFFFE7B6);
  static const Color fourtenary = Color(0xFFFEF2DC);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  
  static const LinearGradient backgroundSplash = LinearGradient(
    colors: [primary, secondary],
  );

  static TextStyle headingStyle = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 20,
  );

  static TextStyle bodyStyle = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );
  static TextStyle cardBody = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 10.8,
  );
  static TextStyle cardTitle = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 12,
  );

  static TextStyle titleDetail = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );
  static TextStyle subtitleDetail = GoogleFonts.poppins(
    fontWeight: FontWeight.w400,
    fontSize: 16,
  );

  static TextStyle buttonStyle = GoogleFonts.poppins(
    fontWeight: FontWeight.bold,
    fontSize: 16,
    color: Colors.white,
  );

static InputDecoration inputDecoration(String hint) {
  return InputDecoration(
    hintText: hint,
    border: InputBorder.none,
    enabledBorder: InputBorder.none,
    focusedBorder: InputBorder.none,
    filled: false, 
    contentPadding: const EdgeInsets.symmetric(
      horizontal: 24,
      vertical: 18,
    ),
  );
}

static BoxDecoration buttonDecorationDisabled = BoxDecoration(
  color: Colors.grey.shade300,
  borderRadius: BorderRadius.circular(20),
);

  static BoxDecoration inputContainerDecoration = BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(28),
    border : Border.all(
      color: primary,
      width: 2
    )
  );

  static BoxDecoration buttonDecorationPrimary = BoxDecoration(
    color: primary,
    borderRadius: BorderRadius.circular(28),
  );
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: Colors.white,
      textTheme: TextTheme(
        headlineSmall: headingStyle,
        bodyLarge: bodyStyle,
        labelLarge: buttonStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: buttonStyle,
          minimumSize: const Size(double.infinity, 56),
        ),
      ),
    );
  }
}

