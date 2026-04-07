import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  COLORS
// ─────────────────────────────────────────────────────────────────────────────
class AppColors {
  AppColors._();

  static const Color primary        = Color(0xFF1976D2);
  static const Color primaryLight   = Color(0xFF42A5F5);
  static const Color primaryDark    = Color(0xFF0D47A1);
  static const Color primarySurface = Color(0xFFE3F2FD);

  static const Color white      = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FA);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color inputFill  = Color(0xFFF5F7FA);
  static const Color navBarBg   = Color(0xFFFFFFFF);

  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint      = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  static const Color border  = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF0F0F0);

  static const Color statusDelivered       = Color(0xFF2E7D32);
  static const Color statusDeliveredSurface = Color(0xFFE8F5E9);
  static const Color statusPending         = Color(0xFFF57C00);
  static const Color statusPendingSurface  = Color(0xFFFFF3E0);
  static const Color statusAssigned        = Color(0xFF1565C0);
  static const Color statusAssignedSurface = Color(0xFFE3F2FD);
  static const Color statusCancelled       = Color(0xFFC62828);
  static const Color statusCancelledSurface = Color(0xFFFFEBEE);
}

// ─────────────────────────────────────────────────────────────────────────────
//  TEXT STYLES  — all via GoogleFonts.poppins()
// ─────────────────────────────────────────────────────────────────────────────
class AppTextStyles {
  AppTextStyles._();

  // ── Display / Hero ────────────────────────────────────────────────────────
  static TextStyle get displayLarge => GoogleFonts.poppins(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryDark,
        letterSpacing: -0.5,
        height: 1.2,
      );

  static TextStyle get displayMedium => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primaryDark,
        letterSpacing: -0.3,
        height: 1.25,
      );

  // ── Headings ──────────────────────────────────────────────────────────────
  static TextStyle get headingLarge => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.3,
      );

  static TextStyle get headingMedium => GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.1,
        height: 1.3,
      );

  static TextStyle get headingSmall => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodyMedium => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.5,
      );

  // ── Labels ────────────────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelMedium => GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle get labelSmall => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
        height: 1.3,
      );

  // ── Button ────────────────────────────────────────────────────────────────
  static TextStyle get button => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
        color: AppColors.textOnPrimary,
      );

  static TextStyle get buttonSmall => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textOnPrimary,
      );

  // ── Input ─────────────────────────────────────────────────────────────────
  static TextStyle get inputText => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle get inputHint => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.4,
      );

  // ── Caption ───────────────────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.4,
        letterSpacing: 0.2,
      );

  // ── Onboarding ────────────────────────────────────────────────────────────
  static TextStyle get onboardingTitle => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w800,
        color: AppColors.primaryDark,
        height: 1.3,
        letterSpacing: -0.3,
      );

  static TextStyle get onboardingSubtitle => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.6,
      );

  // ── Greeting ──────────────────────────────────────────────────────────────
  static TextStyle get greeting => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.3,
      );

  static TextStyle get greetingName => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        height: 1.3,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
//  DIMENSIONS
// ─────────────────────────────────────────────────────────────────────────────
class AppDimens {
  AppDimens._();

  static const double xs   = 4.0;
  static const double sm   = 8.0;
  static const double md   = 12.0;
  static const double lg   = 16.0;
  static const double xl   = 20.0;
  static const double xxl  = 24.0;
  static const double xxxl = 32.0;

  static const EdgeInsets pagePadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsets pageHorizontal =
      EdgeInsets.symmetric(horizontal: 20);

  static const double cardRadius      = 14.0;
  static const double cardRadiusSmall = 10.0;
  static const EdgeInsets cardPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 14);

  static const double buttonHeight      = 52.0;
  static const double buttonHeightSmall = 38.0;
  static const double buttonRadius      = 14.0;
  static const double buttonRadiusSmall = 10.0;

  static const double inputHeight = 52.0;
  static const double inputRadius = 12.0;

  static const double avatarLg = 52.0;
  static const double avatarMd = 40.0;
  static const double avatarSm = 32.0;

  static const double bottomNavHeight = 64.0;

  static const double chipHeight = 26.0;
  static const double chipRadius = 20.0;

  static const double iconLg = 24.0;
  static const double iconMd = 20.0;
  static const double iconSm = 16.0;
}

// ─────────────────────────────────────────────────────────────────────────────
//  SHADOWS
// ─────────────────────────────────────────────────────────────────────────────
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x10000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardHover = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 20,
      offset: Offset(0, 6),
    ),
  ];

  static const List<BoxShadow> bottomNav = [
    BoxShadow(
      color: Color(0x14000000),
      blurRadius: 16,
      offset: Offset(0, -4),
    ),
  ];

  static const List<BoxShadow> button = [
    BoxShadow(
      color: Color(0x3D1976D2),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
//  HELPERS
// ─────────────────────────────────────────────────────────────────────────────
Color statusColor(String status) {
  switch (status.toLowerCase()) {
    case 'delivered':  return AppColors.statusDelivered;
    case 'pending':    return AppColors.statusPending;
    case 'assigned':
    case 'new':        return AppColors.statusAssigned;
    case 'cancelled':  return AppColors.statusCancelled;
    default:           return AppColors.textHint;
  }
}

Color statusSurfaceColor(String status) {
  switch (status.toLowerCase()) {
    case 'delivered':  return AppColors.statusDeliveredSurface;
    case 'pending':    return AppColors.statusPendingSurface;
    case 'assigned':
    case 'new':        return AppColors.statusAssignedSurface;
    case 'cancelled':  return AppColors.statusCancelledSurface;
    default:           return AppColors.primarySurface;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  THEME DATA
// ─────────────────────────────────────────────────────────────────────────────
class AppTheme {
  AppTheme._();

  static ThemeData get light {
    // Base text theme with Poppins applied to every role
    final TextTheme poppinsTextTheme = GoogleFonts.poppinsTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      textTheme: poppinsTextTheme,
      colorScheme: ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primarySurface,
        secondary: AppColors.primaryLight,
        onSecondary: AppColors.textOnPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.statusCancelled,
        onError: AppColors.white,
        outline: AppColors.border,
        surfaceContainerHighest: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
        titleTextStyle: AppTextStyles.headingMedium,
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: AppDimens.iconLg,
        ),
      ),

      // ── ElevatedButton ─────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          minimumSize: const Size(double.infinity, AppDimens.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // ── OutlinedButton ─────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize:
              const Size(double.infinity, AppDimens.buttonHeightSmall),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadiusSmall),
          ),
          textStyle: AppTextStyles.buttonSmall,
        ),
      ),

      // ── TextButton ─────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.labelMedium,
        ),
      ),

      // ── Input ──────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputFill,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: AppTextStyles.inputHint,
        labelStyle: AppTextStyles.inputHint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputRadius),
          borderSide:
              const BorderSide(color: AppColors.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.inputRadius),
          borderSide: const BorderSide(
              color: AppColors.statusCancelled, width: 1.5),
        ),
        prefixIconColor: AppColors.textHint,
        suffixIconColor: AppColors.textHint,
      ),

      // ── Card ───────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        ),
        margin: EdgeInsets.zero,
      ),

      // ── Bottom Navigation ──────────────────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.navBarBg,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: AppTextStyles.labelSmall,
        unselectedLabelStyle: AppTextStyles.labelSmall,
      ),

      // ── Chip ───────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.primarySurface,
        labelStyle: AppTextStyles.labelSmall,
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.chipRadius),
        ),
        side: BorderSide.none,
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),

      // ── Icon ───────────────────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: AppColors.textSecondary,
        size: AppDimens.iconLg,
      ),

      // ── ListTile ───────────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        titleTextStyle: AppTextStyles.headingSmall,
        subtitleTextStyle: AppTextStyles.bodyMedium,
        iconColor: AppColors.primary,
        minLeadingWidth: 0,
      ),
    );
  }
}