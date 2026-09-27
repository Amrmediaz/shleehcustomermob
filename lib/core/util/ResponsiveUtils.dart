import 'package:flutter/material.dart';

/// Responsive utilities for consistent sizing across all devices
class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  // Screen dimensions
  Size get screenSize => MediaQuery.of(context).size;
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;
  double get screenDiagonal =>
      (screenWidth * screenWidth + screenHeight * screenHeight).toDouble();

  // Device type detection
  bool get isSmallPhone => screenWidth < 360;
  bool get isMediumPhone => screenWidth >= 360 && screenWidth < 600;
  bool get isLargePhone => screenWidth >= 600 && screenWidth < 900;
  bool get isTablet => screenWidth >= 900;
  bool get isLandscape => screenHeight < screenWidth;
  bool get isPortrait => screenHeight > screenWidth;

  // Responsive multiplier (ratio between current screen and standard 375px)
  double get responsiveMultiplier => screenWidth / 375.0;

  /// Get responsive width
  /// Example: responsiveWidth(100) will be 100 on 375px, scaled for other sizes
  double responsiveWidth(double baseWidth) {
    return baseWidth * responsiveMultiplier;
  }

  /// Get responsive height
  double responsiveHeight(double baseHeight) {
    return baseHeight * (screenHeight / 812.0); // iPhone X standard height
  }

  /// Get responsive font size
  double responsiveFontSize(double baseSize) {
    return baseSize * responsiveMultiplier;
  }

  // Consistent spacing values
  double get spacing4 => 4 * responsiveMultiplier;
  double get spacing8 => 8 * responsiveMultiplier;
  double get spacing12 => 12 * responsiveMultiplier;
  double get spacing16 => 16 * responsiveMultiplier;
  double get spacing20 => 20 * responsiveMultiplier;
  double get spacing24 => 24 * responsiveMultiplier;
  double get spacing32 => 32 * responsiveMultiplier;

  // Padding helpers
  EdgeInsets get paddingSmall => EdgeInsets.all(spacing8);
  EdgeInsets get paddingMedium => EdgeInsets.all(spacing12);
  EdgeInsets get paddingLarge => EdgeInsets.all(spacing16);
  EdgeInsets get paddingXLarge => EdgeInsets.all(spacing24);

  // Border radius helpers
  double get radiusSmall => 8 * responsiveMultiplier;
  double get radiusMedium => 12 * responsiveMultiplier;
  double get radiusLarge => 18 * responsiveMultiplier;
  double get radiusXLarge => 24 * responsiveMultiplier;

  // Card dimensions
  double get cardHeight {
    if (isSmallPhone) return screenHeight * 0.12;
    if (isMediumPhone) return screenHeight * 0.14;
    if (isLargePhone) return screenHeight * 0.15;
    return screenHeight * 0.16;
  }

  double get cardImageWidth {
    if (isSmallPhone) return 85;
    if (isMediumPhone) return 104;
    if (isLargePhone) return 120;
    return 140;
  }

  // Text sizes
  double get textXSmall => responsiveFontSize(10);
  double get textSmall => responsiveFontSize(12);
  double get textBase => responsiveFontSize(14);
  double get textLarge => responsiveFontSize(16);
  double get textXLarge => responsiveFontSize(18);
  double get textXXLarge => responsiveFontSize(20);
  double get textHeading3 => responsiveFontSize(24);
  double get textHeading2 => responsiveFontSize(28);
  double get textHeading1 => responsiveFontSize(32);

  // Icon sizes
  double get iconSmall => responsiveFontSize(16);
  double get iconMedium => responsiveFontSize(24);
  double get iconLarge => responsiveFontSize(32);
  double get iconXLarge => responsiveFontSize(48);

  // Safe area consideration
  EdgeInsets get safeAreaPadding => MediaQuery.of(context).padding;
  EdgeInsets get viewInsetPadding => MediaQuery.of(context).viewInsets;
  bool get hasSafeArea => safeAreaPadding.top > 0;

  // Orientation-specific values
  double get maxWidth => isTablet ? 600 : screenWidth;
  double get containerPadding => isSmallPhone ? spacing12 : spacing16;
}

/// Easy extension for accessing responsive utils
extension ResponsiveContext on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);

  Size get screenSize => MediaQuery.of(this).size;
  double get width => screenSize.width;
  double get height => screenSize.height;

  bool get isSmallPhone => width < 360;
  bool get isMediumPhone => width >= 360 && width < 600;
  bool get isLargePhone => width >= 600 && width < 900;
  bool get isTablet => width >= 900;
}

/// Responsive breakpoints
class ResponsiveBreakpoints {
  static const double smallPhone = 360;
  static const double mediumPhone = 600;
  static const double largePhone = 900;
  static const double tablet = 1200;
}

/// Responsive layout widget
class ResponsiveLayout extends StatelessWidget {
  final Widget small;
  final Widget? medium;
  final Widget? large;
  final Widget? tablet;

  const ResponsiveLayout({
    Key? key,
    required this.small,
    this.medium,
    this.large,
    this.tablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= ResponsiveBreakpoints.tablet && tablet != null) {
      return tablet!;
    } else if (width >= ResponsiveBreakpoints.largePhone && large != null) {
      return large!;
    } else if (width >= ResponsiveBreakpoints.mediumPhone && medium != null) {
      return medium!;
    }
    return small;
  }
}

/// Helper for responsive padding based on device
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? small;
  final double? medium;
  final double? large;
  final double? tablet;

  const ResponsivePadding({
    Key? key,
    required this.child,
    this.small,
    this.medium,
    this.large,
    this.tablet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    double padding = small ?? 16;

    if (width >= ResponsiveBreakpoints.tablet && tablet != null) {
      padding = tablet!;
    } else if (width >= ResponsiveBreakpoints.largePhone && large != null) {
      padding = large!;
    } else if (width >= ResponsiveBreakpoints.mediumPhone && medium != null) {
      padding = medium!;
    }

    return Padding(
      padding: EdgeInsets.all(padding),
      child: child,
    );
  }
}

/// Helper for responsive grid
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int? smallCrossAxisCount;
  final int? mediumCrossAxisCount;
  final int? largeCrossAxisCount;
  final int? tabletCrossAxisCount;
  final double? mainAxisSpacing;
  final double? crossAxisSpacing;

  const ResponsiveGridView({
    Key? key,
    required this.children,
    this.smallCrossAxisCount = 1,
    this.mediumCrossAxisCount = 2,
    this.largeCrossAxisCount = 3,
    this.tabletCrossAxisCount = 4,
    this.mainAxisSpacing,
    this.crossAxisSpacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    late int crossAxisCount;
    late double spacing;

    if (width >= ResponsiveBreakpoints.tablet) {
      crossAxisCount = tabletCrossAxisCount ?? 4;
      spacing = crossAxisSpacing ?? 16;
    } else if (width >= ResponsiveBreakpoints.largePhone) {
      crossAxisCount = largeCrossAxisCount ?? 3;
      spacing = crossAxisSpacing ?? 12;
    } else if (width >= ResponsiveBreakpoints.mediumPhone) {
      crossAxisCount = mediumCrossAxisCount ?? 2;
      spacing = crossAxisSpacing ?? 12;
    } else {
      crossAxisCount = smallCrossAxisCount ?? 1;
      spacing = crossAxisSpacing ?? 8;
    }

    return GridView.count(
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: mainAxisSpacing ?? 12,
      crossAxisSpacing: spacing,
      children: children,
    );
  }
}

/// Responsive column widget for vertical layouts
class ResponsiveColumn extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;

  const ResponsiveColumn({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.spacing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final space = spacing ?? context.responsive.spacing12;
    return Column(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          children[i],
          if (i < children.length - 1) SizedBox(height: space),
        ]
      ],
    );
  }
}

/// Responsive row widget for horizontal layouts
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;
  final MainAxisSize mainAxisSize;

  const ResponsiveRow({
    Key? key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
    this.mainAxisSize = MainAxisSize.max,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final space = spacing ?? context.responsive.spacing8;
    return Row(
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: mainAxisSize,
      children: [
        for (int i = 0; i < children.length; i++) ...[
          if (i > 0) SizedBox(width: space),
          children[i],
        ]
      ],
    );
  }
}