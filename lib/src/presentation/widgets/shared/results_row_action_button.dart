import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';

class ResultActionsRowButton extends StatelessWidget {
  const ResultActionsRowButton({
    super.key,
    required this.onDelete,
    this.onViewFull,
    this.onEdit,
    this.isDeleteLoading = false,
  });

  final VoidCallback? onDelete, onViewFull, onEdit;
  final bool isDeleteLoading;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      spacing: 12,
      children: [
        MoodText.text(
          text: 'View Full',
          context: context,
          textStyle: context.textTheme.bodyMedium,
          color: AppColors.kGreen,
        ).onTap(onTap: onViewFull, tooltip: 'View Full Details'),
        MoodText.text(
          text: 'Edit',
          context: context,
          textStyle: context.textTheme.bodyMedium,
          color: AppColors.moodYellow,
        ).onTap(onTap: onEdit, tooltip: 'Edit Record'),

        isDeleteLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : MoodText.text(
              text: 'Delete',
              context: context,
              color: AppColors.moodRed,
              textStyle: context.textTheme.bodyMedium?.copyWith(color: AppColors.moodRed),
            ).onTap(onTap: onDelete, tooltip: 'Delete Record'),
      ],
    );
  }
}
