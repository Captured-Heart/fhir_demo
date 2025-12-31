import 'dart:developer';

import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/custom_screen_header.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class ResultsView extends ConsumerWidget {
  const ResultsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final body = CacheHelper.getPatientServerId();
    inspect(body);
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            // Header Section
            CustomScreenHeader(
              title: 'Medical Records',
              subtitle: 'View all submitted medical records',
              trailing: Icon(Icons.assignment, color: AppColors.kWhite, size: 28),
            ),
            Align(alignment: Alignment.centerRight, child: AppBarServerSwitch()),
            const SelectedServerText(),
            // Results List Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: AppSpacings.k4,
                  children: [
                    // List of result categories
                    ...MedicalFormsData.medicalForms.map((form) {
                      return _ResultCategoryCard(
                        title: form.title,
                        icon: form.icon,
                        color: form.color,
                        description: 'View ${form.title.toLowerCase()} records',
                        onTap: () {
                          MedicalFormsData.navigateToResultView(
                            context,
                            form.id,
                            categoryTitle: form.title,
                            categoryColor: form.color,
                            categoryIcon: form.icon,
                          );
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCategoryCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;
  final VoidCallback onTap;

  const _ResultCategoryCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 4,
                children: [
                  MoodText.text(
                    text: title,
                    context: context,
                    textStyle: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  MoodText.text(
                    text: description,
                    context: context,
                    textStyle: context.textTheme.bodySmall?.copyWith(color: AppColors.kTextGrey),
                  ),
                ],
              ),
            ),

            // Arrow icon
            Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.kGrey),
          ],
        ),
      ),
    ).onTap(onTap: onTap, tooltip: description);
  }
}
