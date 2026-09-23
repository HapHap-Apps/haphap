import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Shared spacing scale. Layout code should choose from this scale rather than
/// deriving gaps from the device size.
abstract final class AppSpacing {
  static const double none = 0;
  static const double hairline = 1;
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 40;
  static const double section = 48;
  static const double loose = 64;
  static const double heroTop = 72;
  static const double screenBottom = 80;
  static const double bottomClearance = 96;
  static const double largeSection = 120;
  static const double dialogClearance = 140;
}

/// Radius tokens preserve the existing rounded HapHap visual language.
abstract final class AppRadii {
  static const Radius xsRadius = Radius.circular(4);
  static const Radius smRadius = Radius.circular(8);
  static const Radius mdRadius = Radius.circular(12);
  static const Radius lgRadius = Radius.circular(16);
  static const Radius xlRadius = Radius.circular(20);
  static const Radius xxlRadius = Radius.circular(24);
  static const Radius sheetRadius = Radius.circular(32);
  static const Radius heroRadius = Radius.circular(40);
  static const Radius pillRadius = Radius.circular(999);

  static const BorderRadius xs = BorderRadius.all(xsRadius);
  static const BorderRadius sm = BorderRadius.all(smRadius);
  static const BorderRadius md = BorderRadius.all(mdRadius);
  static const BorderRadius lg = BorderRadius.all(lgRadius);
  static const BorderRadius xl = BorderRadius.all(xlRadius);
  static const BorderRadius xxl = BorderRadius.all(xxlRadius);
  static const BorderRadius sheet = BorderRadius.all(sheetRadius);
  static const BorderRadius pill = BorderRadius.all(pillRadius);
  static const BorderRadius sheetTop = BorderRadius.vertical(top: sheetRadius);
  static const BorderRadius largeTop = BorderRadius.vertical(top: xxlRadius);
}

/// Shared surface depth. Components use these semantic shadows instead of
/// defining their own opacity, blur, and offset values.
abstract final class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: AppColors.shadow,
      blurRadius: AppSpacing.md,
      offset: Offset(0, AppSpacing.xs),
    ),
  ];

  static const List<BoxShadow> surfaceTop = [
    BoxShadow(
      color: AppColors.shadowStrong,
      blurRadius: AppSpacing.lg,
      offset: Offset(0, -AppSpacing.xs),
    ),
  ];
}

abstract final class AppElevations {
  static const double none = 0;
  static const double card = AppSpacing.xs;
}

/// Reusable component dimensions. These are component constraints, not screen
/// assumptions; flexible parents may always make them smaller.
abstract final class AppSizes {
  static const double quarterStroke = 0.25;
  static const double hairline = 1;
  static const double thinStroke = 1.5;
  static const double mediumStroke = 2.5;
  static const double indicator = 2;
  static const double strongStroke = 3;
  static const double progressIndicator = 4;
  static const double micro = 8;
  static const double microTall = 9;
  static const double iconXxs = 12;
  static const double iconCompact = 14;
  static const double iconXs = 16;
  static const double iconSmallPlus = 18;
  static const double iconSm = 20;
  static const double iconMediumPlus = 22;
  static const double iconMd = 24;
  static const double iconLargeMinus = 28;
  static const double iconLg = 32;
  static const double iconLargePlus = 36;
  static const double iconXl = 40;
  static const double compactTouchTarget = 44;
  static const double compactControl = 40;
  static const double touchTarget = 48;
  static const double ratingStar = 45;
  static const double emptyStateIcon = 50;
  static const double categoryButton = 56;
  static const double expandedButtonHeight = 52;
  static const double headerOffset = 59;
  static const double navItemWidth = 60;
  static const double navBarItemHeight = 72;
  static const double avatarSmall = 64;
  static const double avatarCompact = 70;
  static const double decorativeImage = 72;
  static const double categoryCellMinWidth = 72;
  static const double avatarMedium = 80;
  static const double bottomActionHeight = 81;
  static const double thumbnailCompact = 90;
  static const double profileImage = 100;
  static const double mediaSmall = 112;
  static const double decorativeMedia = 115;
  static const double mediaMedium = 120;
  static const double mediaLarge = 128;
  static const double restaurantCardHeight = 132;
  static const double qrCardSize = 145;
  static const double menuCardHeight = 144;
  static const double compactButtonWidth = 140;
  static const double logoWidth = 150;
  static const double narrowPanel = 160;
  static const double statsCard = 169;
  static const double heroMinHeight = 180;
  static const double mascotWidth = 192;
  static const double mascotHeight = 198;
  static const double largeQrSize = 200;
  static const double chartHeight = 200;
  static const double heroHeight = 220;
  static const double qrSize = 240;
  static const double qrCardWidth = 230;
  static const double illustrationWidth = 250;
  static const double sheetImageHeight = 300;
  static const double mediumButtonWidth = 322;
  static const double designContentWidth = 354;
  static const double onboardingPanelHeight = 358;
  static const double designCanvasWidth = 402;
  static const double maxContentWidth = 600;
  static const double uploadMaxDimension = 1024;
  static const double adminGridCardHeight = 110;
  static const double tinyButtonWidth = 96;
}

abstract final class AppTypography {
  static const String fontFamily = 'Plus Jakarta Sans';

  static const double labelSmall = 10;
  static const double labelMedium = 12;
  static const double bodyMedium = 14;
  static const double bodyLarge = 16;
  static const double titleMedium = 18;
  static const double titleLarge = 20;
  static const double headlineSmall = 24;
  static const double headlineMedium = 28;
  static const double displaySmall = 32;
  static const double displayMedium = 36;
  static const double displayLarge = 40;
  static const double hero = 64;

  static const double lineHeightTight = 1.2;
  static const double lineHeightNormal = 1.3;
  static const double lineHeightRelaxed = 1.4;
  static const double lineHeightLoose = 1.5;

  static TextTheme textTheme(TextTheme base) => base
      .copyWith(
        displaySmall: AppTextStyles.displaySmall,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      )
      .apply(bodyColor: AppColors.black, displayColor: AppColors.black);
}

/// The only text-style constructor used by presentation code. It guarantees
/// the app font even in [RichText] trees that do not inherit [DefaultTextStyle].
class AppTextStyle extends TextStyle {
  const AppTextStyle({
    super.inherit = true,
    super.color,
    super.backgroundColor,
    super.fontSize,
    super.fontWeight,
    super.fontStyle,
    super.letterSpacing,
    super.wordSpacing,
    super.textBaseline,
    super.height,
    super.leadingDistribution,
    super.locale,
    super.foreground,
    super.background,
    super.shadows,
    super.fontFeatures,
    super.fontVariations,
    super.decoration,
    super.decorationColor,
    super.decorationStyle,
    super.decorationThickness,
    super.debugLabel,
    super.fontFamily = AppTypography.fontFamily,
    super.fontFamilyFallback,
    super.package,
    super.overflow,
  });
}

/// Semantic typography scale consumed by [ThemeData.textTheme].
abstract final class AppTextStyles {
  static const displaySmall = AppTextStyle(
    fontSize: AppTypography.displaySmall,
    fontWeight: FontWeight.w700,
  );
  static const headlineMedium = AppTextStyle(
    fontSize: AppTypography.headlineMedium,
    fontWeight: FontWeight.w700,
  );
  static const headlineSmall = AppTextStyle(
    fontSize: AppTypography.headlineSmall,
    fontWeight: FontWeight.w700,
  );
  static const titleLarge = AppTextStyle(
    fontSize: AppTypography.titleLarge,
    fontWeight: FontWeight.w700,
  );
  static const titleMedium = AppTextStyle(
    fontSize: AppTypography.titleMedium,
    fontWeight: FontWeight.w600,
  );
  static const titleSmall = AppTextStyle(
    fontSize: AppTypography.bodyLarge,
    fontWeight: FontWeight.w600,
  );
  static const bodyLarge = AppTextStyle(fontSize: AppTypography.bodyLarge);
  static const bodyMedium = AppTextStyle(fontSize: AppTypography.bodyMedium);
  static const bodySmall = AppTextStyle(fontSize: AppTypography.labelMedium);
  static const labelLarge = AppTextStyle(
    fontSize: AppTypography.bodyMedium,
    fontWeight: FontWeight.w600,
  );
  static const labelMedium = AppTextStyle(
    fontSize: AppTypography.labelMedium,
    fontWeight: FontWeight.w500,
  );
  static const labelSmall = AppTextStyle(
    fontSize: AppTypography.labelSmall,
    fontWeight: FontWeight.w500,
  );
}

abstract final class AppLayout {
  static const double compactPhone = 360;
  static const double widePhone = 480;
  static const double shortPhoneHeight = 700;
  static const double compactActionRow = 200;
  static const double cardImageFraction = 0.34;
  static const double menuImageFraction = 0.3;
  static const double heroHeightFraction = 0.55;
  static const double mascotWidthFraction = 0.55;
  static const double mascotAspectRatio = 198 / 192;
  static const double sheetImageFraction = 0.7;
  static const double bottomSheetMaxHeightFactor = 0.9;

  static double pagePadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width < compactPhone ? AppSpacing.lg : AppSpacing.xxl;
  }

  static double floatingNavBarClearance(BuildContext context) {
    final systemBottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final navBarBottomInset = systemBottomInset > AppSpacing.md
        ? systemBottomInset
        : AppSpacing.md;
    return AppSizes.navBarItemHeight + navBarBottomInset;
  }

  static double responsiveExtent(
    double availableWidth, {
    required double fraction,
    required double min,
    required double max,
  }) => (availableWidth * fraction).clamp(min, max);
}

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(textTheme: AppTypography.textTheme(base.textTheme));
  }
}
