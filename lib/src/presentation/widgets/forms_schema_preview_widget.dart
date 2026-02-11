import 'dart:convert';
import 'dart:js_interop';

import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/responsive_extensions.dart';
import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';

class FormSchemaJsonPreviewWidget extends StatelessWidget {
  const FormSchemaJsonPreviewWidget({super.key, required this.jsonSchema, required this.entityName});
  final MapStringDynamic jsonSchema;
  final String entityName;

  @override
  Widget build(BuildContext context) {
    if (!context.isComputerOrLarger) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacings.k12),
        child: GridPaper(
          color: AppColors.kGrey.withValues(alpha: 0.35),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.code, color: AppColors.kGrey),
                    const SizedBox(width: 8),
                    Flexible(
                      child: MoodText.text(
                        text: 'JSON Schema Preview',
                        context: context,
                        textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                MoodText.text(
                  text: entityName,
                  context: context,
                  textStyle: context.textTheme.bodySmall?.copyWith(color: AppColors.kGrey, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      spacing: AppSpacings.k20,
                      children: [
                        SelectableText('{', style: context.textTheme.titleLarge, maxLines: 1),
                        ...jsonSchema
                            .map(
                              (key, value) => MapEntry(
                                key,
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: AppSpacings.k12,
                                  children: [
                                    SelectableText(
                                      '$key :',
                                      style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                      // maxLines: 1,
                                    ),
                                    Expanded(
                                      child: SelectableText(switch (value.runtimeType) {
                                        const (List) => () {
                                          // ignore: invalid_runtime_check_with_js_interop_types
                                          if ((value is JSArray) || (value is List<Map<String, dynamic>>)) {
                                            final items = (value as List).map((item) => jsonEncode(item)).join('\n\n');
                                            return items;
                                          } else if (value is List<String>) {
                                            return value.join('\n');
                                          } else if (value is DateTime) {
                                            return value.toIso8601String();
                                          } else {
                                            return value.toString();
                                          }
                                        }(),
                                        _ => '$value',
                                      }, style: context.textTheme.titleLarge?.copyWith(height: 1.2)),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .values,
                        SelectableText('}', style: context.textTheme.titleLarge, maxLines: 1),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
