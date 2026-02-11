import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/constants/responsive_extensions.dart';
import 'package:fhir_demo/src/presentation/widgets/layouts/app_scaffold.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/custom_screen_header.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
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
    return AppScaffold(
      compactView: context.isTabletOrLarger,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Section
            CustomScreenHeader(
              title: '',
              subtitle: 'Select a medical form below',

              titleWidget: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(text: 'Welcome, ', style: context.textTheme.bodyLarge?.copyWith(color: AppColors.kWhite)),
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
              trailing: Icon(Icons.dashboard, color: AppColors.kWhite, size: 28),
            ),

            // Grid Section
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 16,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: MoodText.text(
                            text: 'Medical Forms',
                            context: context,
                            textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),

                        AppBarServerSwitch(),
                      ],
                    ),
                    SelectedServerText(),

                    // Grid of medical forms
                    Builder(
                      builder: (context) {
                        final deviceDetails = context.deviceDetails;
                        final crossAxisCount = deviceDetails.getGridColumns(
                          mobile: 2,
                          tablet: 3,
                          computer: 3,
                          largeScreen: 3,
                          widescreen: 3,
                        );
                        final childAspectRatio = context.responsive<double>(
                          mobile: 0.9,
                          tablet: 0.95,
                          computer: 1.0,
                          largeScreen: 1.05,
                          widescreen: 1.1,
                        );

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: childAspectRatio,
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
