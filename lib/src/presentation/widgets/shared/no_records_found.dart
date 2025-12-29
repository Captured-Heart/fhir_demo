import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';

class NoRecordsFound extends StatelessWidget {
  const NoRecordsFound({super.key, required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 16,
      children: [
        Icon(icon, size: 64, color: AppColors.kGrey.withValues(alpha: 0.5)),
        MoodText.text(
          text: 'No records found',
          context: context,
          textStyle: context.textTheme.titleMedium?.copyWith(color: AppColors.kTextGrey),
        ),
        MoodText.text(
          text: 'Submit a form to see results here',
          context: context,
          textStyle: context.textTheme.bodySmall?.copyWith(color: AppColors.kTextGrey),
        ),
      ],
    );
  }
}
