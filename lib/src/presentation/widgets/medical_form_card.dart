import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/controller/fhir_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/src/domain/entities/medical_form_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Reusable card widget for displaying medical forms in the grid
class MedicalFormCard extends ConsumerWidget {
  final MedicalFormEntity medicalForm;
  final VoidCallback onTap;

  const MedicalFormCard({super.key, required this.medicalForm, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serverType = ref.watch(fhirSettingsProvider).serverType;
    final patientLength = CacheHelper.getPatientServerIdByServerType(serverType)?.length ?? 0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: medicalForm.color.withValues(alpha: 0.1),
          borderRadius: AppSpacings.borderRadiusk20All,
          border: Border.all(color: medicalForm.color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 12,
          children: [
            // Icon container
            Badge(
              label: Text('$patientLength', textScaler: TextScaler.linear(1.3)),
              isLabelVisible: medicalForm.title.contains('Register') && (patientLength > 0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: medicalForm.color.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(medicalForm.icon, size: 32, color: medicalForm.color),
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                medicalForm.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: medicalForm.color),
              ),
            ),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                medicalForm.description,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: context.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
