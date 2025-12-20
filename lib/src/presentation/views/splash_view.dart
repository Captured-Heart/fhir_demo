import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fhir_demo/constants/app_images.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/nav_routes.dart';
import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/constants/text_constants.dart';
import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();

    navigateToNextScreen();
  }

  Future<void> navigateToNextScreen() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final currentUser = CacheHelper.currentUser;
      return await Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        context.pushReplacementNamed(currentUser != null ? NavRoutes.homeRoute : NavRoutes.authRoute);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Hero(
              tag: AppImages.appLogo.pngPath,
              child: Image.asset(AppImages.appLogo.pngPath).padOnly(bottom: AppSpacings.k16).padAll(AppSpacings.k8),
            ),
            Flexible(
              child: MoodText.text(
                text: TextConstants.fhirDemo.tr(),
                context: context,
                textStyle: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ).scaleUpDown(animationDuration: 1000.ms).shakeExtension(delay: 1800.ms),
      ),
    );
  }
}
