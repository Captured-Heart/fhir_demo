import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/prescriptions_controller.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/detail_row_results.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/no_records_found.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/results_row_action_button.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrescriptionResultDetailView extends ConsumerStatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const PrescriptionResultDetailView({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  ConsumerState<PrescriptionResultDetailView> createState() => _PrescriptionResultDetailViewState();
}

class _PrescriptionResultDetailViewState extends ConsumerState<PrescriptionResultDetailView> {
  @override
  void initState() {
    super.initState();
    _fetchPrescriptions();
  }

  _fetchPrescriptions() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(prescriptionsController.notifier).fetchPrescriptionsByIdentifier();
    });
  }

  @override
  Widget build(BuildContext context) {
    'what is categoryTitle: ${widget.categoryTitle}'.logError();
    final prescriptionsState = ref.watch(prescriptionsController);
    final prescriptionsCtrl = ref.read(prescriptionsController.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Records'),
        backgroundColor: widget.categoryColor,
        foregroundColor: AppColors.kWhite,
        actions: [
          AppBarServerSwitch(
            onServerChanged: () {
              _fetchPrescriptions();
            },
          ),
        ],
      ),
      body:
          prescriptionsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : prescriptionsState.prescriptionLists.isEmpty
              ? Center(child: NoRecordsFound(icon: widget.categoryIcon))
              : Column(
                children: [
                  const SizedBox(height: 12),
                  const SelectedServerText(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: prescriptionsState.prescriptionLists.length,
                      itemBuilder: (context, index) {
                        final result = prescriptionsState.prescriptionLists[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ExpansionTile(
                            leading: CircleAvatar(
                              backgroundColor: widget.categoryColor.withValues(alpha: 0.1),
                              child: Icon(widget.categoryIcon, color: widget.categoryColor, size: 20),
                            ),
                            title: MoodText.text(
                              text:
                                  'Record #${index + 1} - ${(result.medicationX as CodeableConcept).text?.valueString ?? 'Medication'}',
                              context: context,
                              textStyle: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: MoodText.text(
                              text: result.authoredOn.toString(),
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
                                    BuildDetailRow(label: 'Status', value: result.status.valueString ?? 'Unknown'),
                                    BuildDetailRow(label: 'ID', value: result.id?.valueString ?? 'N/A'),
                                    if (result.dosageInstruction != null)
                                      BuildDetailRow(
                                        label: 'Details',
                                        value: result.dosageInstruction?.first.text?.valueString ?? 'N/A',
                                      ),
                                    const Divider(height: 24),

                                    // Action buttons
                                    ResultActionsRowButton(
                                      isDeleteLoading: prescriptionsState.isDeleteLoading,
                                      onDelete: () {
                                        prescriptionsCtrl.deletePrescriptionsById(
                                          result.id!.valueString!,
                                          onSuccess: () {
                                            if (mounted) {
                                              context.showSnackBar(message: 'Prescription deleted successfully');
                                            }
                                          },
                                        );
                                      },
                                      onEdit: () {
                                        MedicalFormsData.navigateToEditForm(
                                          context,
                                          MedicalFormsData.prescriptions.id,
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
