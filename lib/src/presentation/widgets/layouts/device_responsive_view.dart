// ignore_for_file: constant_identifier_names

import 'dart:convert';

import 'package:fhir_demo/constants/responsive_extensions.dart';
import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/services/ui_service.dart';
import 'package:fhir_demo/src/presentation/widgets/layouts/app_scaffold.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeviceBreakpoints {
  static const double MAX_SUPPORTED = 1920;

  static const double tablet = 768;
  static const double computer = 850;
  static const double largeScreen = 1400;
  static const double wideScreen = 1920;
}

class DeviceDetails {
  final BoxConstraints constraints;
  final BoxConstraints originalConstraints;

  bool isMobile = false;
  bool isTablet = false;
  bool isComputer = false;
  bool isLargeScreen = false;
  bool isWidescreen = false;

  DeviceDetails(this.constraints, this.originalConstraints);

  factory DeviceDetails.fromConstraints(BoxConstraints constraints, {BoxConstraints? originalConstraints}) {
    DeviceDetails details = DeviceDetails(constraints, originalConstraints ?? constraints);
    if (kIsWeb) {
      if (constraints.maxWidth >= DeviceBreakpoints.wideScreen) {
        details.isWidescreen = true;
        details.isLargeScreen = true;
        details.isComputer = true;
      } else if (constraints.maxWidth >= DeviceBreakpoints.largeScreen) {
        details.isLargeScreen = true;
        details.isComputer = true;
      } else if (constraints.maxWidth >= DeviceBreakpoints.computer) {
        details.isComputer = true;
      } else if (constraints.maxWidth >= DeviceBreakpoints.tablet) {
        details.isTablet = true;
        details.isMobile = true;
      } else {
        details.isMobile = true;
      }
    } else {
      details.isMobile = true;
    }

    return details;
  }

  factory DeviceDetails.fromSize(Size constraints) {
    BoxConstraints boxConstraints = BoxConstraints(maxWidth: constraints.width, maxHeight: constraints.height);
    DeviceDetails details = DeviceDetails(boxConstraints, boxConstraints);
    if (kIsWeb) {
      if (constraints.width >= DeviceBreakpoints.wideScreen) {
        details.isWidescreen = true;
        details.isLargeScreen = true;
        details.isComputer = true;
      } else if (constraints.width >= DeviceBreakpoints.largeScreen) {
        details.isLargeScreen = true;
        details.isComputer = true;
      } else if (constraints.width >= DeviceBreakpoints.computer) {
        details.isComputer = true;
      } else if (constraints.width >= DeviceBreakpoints.tablet) {
        details.isTablet = true;
        details.isMobile = true;
      } else {
        details.isMobile = true;
      }
    } else {
      details.isMobile = true;
    }
    return details;
  }
}

class WebPage extends ConsumerWidget {
  final Color? backgroundColor;
  final Widget Function(BuildContext context, BoxConstraints constraints, DeviceDetails deviceType) builder;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final bool showAppbar;
  final bool compactView;
  final List<Widget> actions;

  /// Content width percentage (0.0 to 1.0) for desktop layouts
  /// Defaults to 0.8 (80%)
  final double contentWidthPercentage;

  /// Compact view width percentage (0.0 to 1.0)
  /// Defaults to 0.5 (50%)
  final double compactWidthPercentage;

  /// Compact view height percentage (0.0 to 1.0)
  /// Defaults to 0.9 (90%)
  final double compactHeightPercentage;

  const WebPage({
    super.key,
    required this.builder,
    this.scrollController,
    this.showAppbar = true,
    this.scrollPhysics,
    this.backgroundColor,
    this.compactView = false,
    this.actions = const [],
    this.contentWidthPercentage = 0.8,
    this.compactWidthPercentage = 0.5,
    this.compactHeightPercentage = 0.9,
  }) : assert(
         contentWidthPercentage > 0.0 && contentWidthPercentage <= 1.0,
         'contentWidthPercentage must be between 0.0 and 1.0',
       ),
       assert(
         compactWidthPercentage > 0.0 && compactWidthPercentage <= 1.0,
         'compactWidthPercentage must be between 0.0 and 1.0',
       ),
       assert(
         compactHeightPercentage > 0.0 && compactHeightPercentage <= 1.0,
         'compactHeightPercentage must be between 0.0 and 1.0',
       );

  void parseBaseURL(BuildContext context) {
    String? previewQueryParam = Uri.base.queryParameters['preview'];
    if (previewQueryParam != null) {
      Codec<String, String> stringToBase64Url = utf8.fuse(base64Url);
      String decodedJson = stringToBase64Url.decode(previewQueryParam);
      Map<String, dynamic> jsonData = jsonDecode(decodedJson);

      debugPrint(jsonData.toString());
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UIService uiService = ref.read(uiServiceProvider);

    return Material(
      color: Colors.transparent,
      child: LayoutBuilder(
        builder: (context, appConstraints) {
          final double maxClampedWidth = appConstraints.maxWidth.clamp(
            DeviceBreakpoints.computer,
            DeviceBreakpoints.MAX_SUPPORTED,
          );

          // final Size appBarSize = Size(appConstraints.maxWidth, kToolbarHeight);

          final BoxConstraints constraints = appConstraints.copyWith(
            maxWidth: maxClampedWidth * contentWidthPercentage,
            minWidth: 0,
            maxHeight: appConstraints.maxHeight,
            minHeight: 0,
          );

          final DeviceDetails deviceDetails = DeviceDetails.fromConstraints(
            constraints,
            originalConstraints: appConstraints,
          );

          const String currentPath = ""; // USe Navigator;

          if (currentPath == "/") {
            parseBaseURL(context);
          }

          uiService.setDeviceType(context, deviceDetails);

          final Widget builderChild = builder(context, constraints, deviceDetails);

          return AppScaffold(
            compactView: !context.deviceDetails.isMobile,

            backgroundColor: backgroundColor,
            resizeToAvoidBottomInset: deviceDetails.isMobile,
            body: SizedBox(
              width: appConstraints.maxWidth,
              height: appConstraints.maxHeight,
              child: Center(
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Builder(
                    builder: (context) {
                      if (compactView && !deviceDetails.isMobile) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (actions.isNotEmpty)
                              Padding(
                                padding: EdgeInsets.only(
                                  bottom: AppSpacings.elementSpacing,
                                  right: constraints.maxWidth * 0.15,
                                  top: AppSpacings.k20,
                                ),
                                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: actions),
                              ),
                            Expanded(
                              child: Center(
                                child: SizedBox(
                                  width: constraints.maxWidth * compactWidthPercentage,
                                  height: constraints.maxHeight * compactHeightPercentage,
                                  child: builderChild,
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return builderChild;
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
