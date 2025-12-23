import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';

class CustomScreenHeader extends StatelessWidget {
  const CustomScreenHeader({super.key, required this.title, required this.subtitle, this.trailing, this.titleWidget});

  final String title, subtitle;
  final Widget? trailing, titleWidget;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.kPrimary, AppColors.kPrimaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 4,
            children: [
              titleWidget ??
                  MoodText.text(
                    text: title,
                    context: context,
                    textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    color: AppColors.kWhite,
                  ),
              MoodText.text(
                text: subtitle,
                context: context,
                textStyle: context.textTheme.bodyMedium?.copyWith(),
                color: AppColors.kWhite.withValues(alpha: 0.8),
              ),
            ],
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ).padSymmetric(horizontal: 20, vertical: 12),
    );
  }
}
