import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/patient_controller.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/detail_row_results.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/no_records_found.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/results_row_action_button.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PatientResultDetailView extends ConsumerStatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const PatientResultDetailView({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  ConsumerState<PatientResultDetailView> createState() => _PatientResultDetailViewState();
}

class _PatientResultDetailViewState extends ConsumerState<PatientResultDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchPatients();
    });
  }

  void fetchPatients() {
    ref.read(patientController.notifier).fetchPatientsByIdentifier();
  }

  @override
  Widget build(BuildContext context) {
    final patientState = ref.watch(patientController);
    final patientCtrl = ref.read(patientController.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Records'),
        backgroundColor: widget.categoryColor,
        foregroundColor: AppColors.kWhite,
        actions: [
          AppBarServerSwitch(
            onServerChanged: () {
              fetchPatients();
            },
          ),
        ],
      ),
      body:
          patientState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : patientState.patientList.isEmpty
              ? Center(child: NoRecordsFound(icon: widget.categoryIcon))
              : Column(
                children: [
                  const SizedBox(height: 12),
                  const SelectedServerText(),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(4),
                      itemCount: patientState.patientList.length,
                      itemBuilder: (context, index) {
                        final result = patientState.patientList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: widget.categoryColor.withValues(alpha: 0.1),
                              child: MoodText.text(
                                text: '${index + 1}',
                                context: context,
                                textStyle: context.textTheme.bodyMedium,
                              ),
                            ),
                            title: MoodText.text(
                              context: context,
                              text:
                                  ('${result.name?.first.family?.toString().toUpperCase() ?? ''}, ${result.name?.first.given?.first.toString() ?? ''}'),
                              textStyle: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: MoodText.text(
                              text: result.birthDate?.toString() ?? 'No date',
                              context: context,
                              textStyle: context.textTheme.bodySmall?.copyWith(color: AppColors.kTextGrey),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  spacing: 8,
                                  children: [
                                    BuildDetailRow(label: 'Status', value: result.active?.toString() ?? 'Unknown'),
                                    BuildDetailRow(label: 'ID', value: result.id?.toString() ?? 'N/A'),
                                    if (result.address != null)
                                      BuildDetailRow(
                                        label: 'Details',
                                        value: result.address?.first.text?.toString() ?? '',
                                      ),
                                    const Divider(height: 24),

                                    // Action buttons
                                    ResultActionsRowButton(
                                      isDeleteLoading: patientState.isDeleteLoading,
                                      onDelete: () {
                                        patientCtrl.deletePatientById(
                                          result.id!.toString(),
                                          onSuccess: () {
                                            if (mounted) {
                                              context.showSnackBar(message: 'Record deleted successfully');
                                            }
                                          },
                                        );
                                      },
                                      onEdit: () {
                                        // Navigate to edit patient view
                                        MedicalFormsData.navigateToEditForm(
                                          context,
                                          MedicalFormsData.registerPatient.id,
                                          arguments: result,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
    );
  }
}
