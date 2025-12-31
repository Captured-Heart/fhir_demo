import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';

class AppDropDownWidget extends StatelessWidget {
  const AppDropDownWidget({
    super.key,
    this.onChanged,
    required this.value,
    this.hintText,
    this.labelText,
    this.items = const [],
  });

  final Function(Object?)? onChanged;
  final Object? value;
  final String? hintText, labelText;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (labelText != null)
          MoodText.text(
            text: labelText!,
            context: context,
            textStyle: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.kGrey.withValues(alpha: 0.8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value as String?,
              hint: MoodText.text(
                text: hintText ?? 'Select an option',
                context: context,
                textStyle: context.textTheme.bodyMedium,
                color: AppColors.kGrey,
              ),
              isExpanded: true,
              items:
                  items.map((severity) {
                    return DropdownMenuItem(
                      value: severity,
                      child: MoodText.text(text: severity, context: context, textStyle: context.textTheme.bodyMedium),
                    );
                  }).toList(),
              onChanged: onChanged,
              //
            ),
          ).padSymmetric(horizontal: 12),
        ),
      ],
    );
  }
}
