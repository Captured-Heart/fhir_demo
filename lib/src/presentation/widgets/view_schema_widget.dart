import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/responsive_extensions.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/src/presentation/widgets/forms_schema_preview_widget.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';

class ViewSchemaWidget extends StatelessWidget {
  const ViewSchemaWidget({super.key, required this.jsonSchema, required this.entityName});
  final MapStringDynamic jsonSchema;
  final String entityName;

  @override
  Widget build(BuildContext context) {
    if (context.isComputerOrLarger) return const SizedBox.shrink();

    return MoodText.text(
      text: 'View schema',
      context: context,
      color: AppColors.kWhite,
      textStyle: context.textTheme.bodyMedium?.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: AppColors.kWhite,
      ),
    ).onTap(
      onTap: () {
        showModalBottomSheet(
          context: context,
          constraints: BoxConstraints(maxHeight: context.deviceHeight(0.85)),
          isScrollControlled: true,

          builder: (context) => FormSchemaJsonPreviewWidget(jsonSchema: jsonSchema, entityName: entityName),
        );
      },
      tooltip: 'View Schema',
    );
  }
}
