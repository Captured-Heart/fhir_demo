import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/nav_routes.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/medical_form_card.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  String? navRouteForFormId(String formId) {
    return switch (formId) {
      'register_patient' => NavRoutes.registerPatientRoute,
      'diagnosis' => NavRoutes.diagnosisRoute,
      'prescriptions' => NavRoutes.prescriptionsRoute,
      'observations' => NavRoutes.observationsRoute,
      'appointments' => NavRoutes.appointmentsRoute,
      'lab_results' => NavRoutes.labResultsRoute,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = CacheHelper.currentUser;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.kPrimary, AppColors.kPrimaryContainer],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'Welcome, ', style: context.textTheme.bodyLarge),
                        TextSpan(
                          text: user?.name ?? 'User',
                          style: context.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.kWhite.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  MoodText.text(
                    text: 'Select a medical form below',
                    context: context,
                    textStyle: context.textTheme.bodyMedium?.copyWith(color: AppColors.kWhite.withOpacity(0.9)),
                  ),
                ],
              ).padSymmetric(horizontal: 20, vertical: 12),
            ),

            // Grid Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    MoodText.text(
                      text: 'Medical Forms',
                      context: context,
                      textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    // Grid of medical forms
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.9,
                      ),
                      itemCount: MedicalFormsData.medicalForms.length,
                      itemBuilder: (context, index) {
                        final medicalForm = MedicalFormsData.medicalForms[index];
                        return MedicalFormCard(
                          medicalForm: medicalForm,
                          onTap: () {
                            final String? route = navRouteForFormId(medicalForm.id);

                            if (route != null) {
                              Navigator.pushNamed(context, route);
                            }
                          },
                        );
                      },
                    ),
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
