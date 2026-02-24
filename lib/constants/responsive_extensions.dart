import 'package:fhir_demo/src/presentation/widgets/layouts/device_responsive_view.dart';
import 'package:flutter/material.dart';

/// Responsive extensions on DeviceDetails for adaptive UI sizing
extension ResponsiveDeviceExtensions on DeviceDetails {
  /// Get responsive spacing multiplier based on device type
  double get spacingMultiplier {
    if (isWidescreen) return 1.5;
    if (isLargeScreen) return 1.25;
    if (isComputer) return 1.1;
    if (isTablet) return 0.95;
    return 1.0; // mobile
  }

  /// Get adaptive spacing value
  double getResponsiveSpacing(double baseSpacing) {
    return baseSpacing * spacingMultiplier;
  }

  /// Get responsive font size multiplier
  double get fontSizeMultiplier {
    if (isWidescreen) return 1.3;
    if (isLargeScreen) return 1.2;
    if (isComputer) return 1.1;
    if (isTablet) return 1.05;
    return 1.0; // mobile
  }

  /// Get adaptive font size
  double getResponsiveFontSize(double baseFontSize) {
    return baseFontSize * fontSizeMultiplier;
  }

  /// Get responsive grid column count
  int get gridColumnCount {
    if (isWidescreen) return 4;
    if (isLargeScreen) return 3;
    if (isComputer) return 3;
    if (isTablet) return 2;
    return 1; // mobile
  }

  /// Get adaptive grid column count with custom values
  int getGridColumns({int mobile = 1, int tablet = 2, int computer = 3, int largeScreen = 3, int widescreen = 4}) {
    if (isWidescreen) return widescreen;
    if (isLargeScreen) return largeScreen;
    if (isComputer) return computer;
    if (isTablet) return tablet;
    return mobile;
  }

  /// Get responsive content width constraint
  double getContentWidth(double screenWidth) {
    if (isWidescreen) return screenWidth * 0.7;
    if (isLargeScreen) return screenWidth * 0.75;
    if (isComputer) return screenWidth * 0.8;
    if (isTablet) return screenWidth * 0.9;
    return screenWidth; // mobile uses full width
  }

  /// Get responsive horizontal padding
  EdgeInsets getResponsiveHorizontalPadding(double basePadding) {
    return EdgeInsets.symmetric(horizontal: getResponsiveSpacing(basePadding));
  }

  /// Get responsive padding
  EdgeInsets getResponsivePadding(double basePadding) {
    final spacing = getResponsiveSpacing(basePadding);
    return EdgeInsets.all(spacing);
  }

  /// Get responsive vertical spacing
  SizedBox getVerticalSpacing(double baseHeight) {
    return SizedBox(height: getResponsiveSpacing(baseHeight));
  }

  /// Get responsive horizontal spacing
  SizedBox getHorizontalSpacing(double baseWidth) {
    return SizedBox(width: getResponsiveSpacing(baseWidth));
  }

  /// Check if should use compact/centered layout
  bool get shouldUseCompactLayout => isComputer || isTablet || isLargeScreen || isWidescreen;

  /// Get responsive card elevation
  double get cardElevation {
    if (isComputer || isLargeScreen || isWidescreen) return 2.0;
    return 1.0;
  }

  /// Get responsive border radius
  double getResponsiveBorderRadius(double baseRadius) {
    if (isWidescreen || isLargeScreen) return baseRadius * 1.2;
    if (isComputer) return baseRadius * 1.1;
    return baseRadius;
  }

  /// Get responsive icon size
  double getResponsiveIconSize(double baseSize) {
    return baseSize * fontSizeMultiplier;
  }

  /// Get responsive button height
  double get buttonHeight {
    if (isWidescreen || isLargeScreen) return 56.0;
    if (isComputer) return 52.0;
    if (isTablet) return 50.0;
    return 48.0; // mobile
  }

  /// Get responsive dialog/modal width
  double getDialogWidth(double screenWidth) {
    if (isWidescreen) return 600.0;
    if (isLargeScreen) return 550.0;
    if (isComputer) return 500.0;
    if (isTablet) return screenWidth * 0.8;
    return screenWidth * 0.9; // mobile
  }
}

/// Responsive context extensions
extension ResponsiveContextExtensions on BuildContext {
  /// Get responsive value based on current device
  T responsive<T>({required T mobile, T? tablet, T? computer, T? largeScreen, T? widescreen}) {
    final size = MediaQuery.sizeOf(this);
    final details = DeviceDetails.fromSize(size);

    if (details.isWidescreen && widescreen != null) return widescreen;
    if (details.isLargeScreen && largeScreen != null) return largeScreen;
    if (details.isComputer && computer != null) return computer;
    if (details.isTablet && tablet != null) return tablet;
    return mobile;
  }

  /// Get responsive spacing
  double spacing(double base) {
    final size = MediaQuery.sizeOf(this);
    final details = DeviceDetails.fromSize(size);
    return details.getResponsiveSpacing(base);
  }

  /// Get responsive font size
  double fontSize(double base) {
    final size = MediaQuery.sizeOf(this);
    final details = DeviceDetails.fromSize(size);
    return details.getResponsiveFontSize(base);
  }

  /// Get current device details
  DeviceDetails get deviceDetails {
    final size = MediaQuery.sizeOf(this);
    return DeviceDetails.fromSize(size);
  }

  /// Check if device is mobile
  bool get isMobileDevice {
    final size = MediaQuery.sizeOf(this);
    final details = DeviceDetails.fromSize(size);
    return details.isMobile && !details.isTablet;
  }

  /// Check if device is tablet or larger
  bool get isTabletOrLarger {
    final size = MediaQuery.sizeOf(this);
    final details = DeviceDetails.fromSize(size);
    return details.isTablet || details.isComputer || details.isLargeScreen || details.isWidescreen;
  }

  /// Check if device is computer or larger
  bool get isComputerOrLarger {
    final size = MediaQuery.sizeOf(this);
    final details = DeviceDetails.fromSize(size);
    return details.isComputer || details.isLargeScreen || details.isWidescreen;
  }
}
