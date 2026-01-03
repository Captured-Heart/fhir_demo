import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';

class BuildDetailRow extends StatelessWidget {
  const BuildDetailRow({super.key, required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 8,
      children: [
        MoodText.text(
          text: '$label:',
          context: context,
          textStyle: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        Expanded(child: MoodText.text(text: value, context: context, textStyle: context.textTheme.bodySmall)),
      ],
    );
  }
}
