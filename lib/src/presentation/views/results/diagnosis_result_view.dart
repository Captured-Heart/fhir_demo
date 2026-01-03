import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/diagnosis_controller.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/detail_row_results.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/no_records_found.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/results_row_action_button.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DiagnosisResultDetailView extends ConsumerStatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const DiagnosisResultDetailView({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  ConsumerState<DiagnosisResultDetailView> createState() => _DiagnosisResultDetailViewState();
}

class _DiagnosisResultDetailViewState extends ConsumerState<DiagnosisResultDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(diagnosisController.notifier).fetchDiagnosesByIdentifier();
    });
  }

  @override
  Widget build(BuildContext context) {
    'what is categoryTitle: ${widget.categoryTitle}'.logError();
    final diagnosisState = ref.watch(diagnosisController);
    final diagnosisCtrl = ref.read(diagnosisController.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Records'),
        backgroundColor: widget.categoryColor,
        foregroundColor: AppColors.kWhite,
        actions: [
          AppBarServerSwitch(
            onServerChanged: () {
              ref.read(diagnosisController.notifier).fetchDiagnosesByIdentifier();
            },
          ),
        ],
      ),
      body:
          diagnosisState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : diagnosisState.diagnosesList.isEmpty
              ? Center(child: NoRecordsFound(icon: widget.categoryIcon))
              : Column(
                children: [
                  const SizedBox(height: 12),
                  const SelectedServerText(),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: diagnosisState.diagnosesList.length,
                      itemBuilder: (context, index) {
                        final result = diagnosisState.diagnosesList[index];
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
                              text: 'Record #${index + 1} - ${result.conclusion} ',
                              context: context,
                              textStyle: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: MoodText.text(
                              text: result.effectiveDateTime?.toString() ?? 'No date',
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
                                    BuildDetailRow(label: 'Status', value: result.status.toString()),
                                    BuildDetailRow(label: 'ID', value: result.id?.toString() ?? 'N/A'),
                                    if (result.presentedForm != null)
                                      BuildDetailRow(
                                        label: result.presentedForm!.first.fhirType,
                                        value: result.presentedForm?.first.title?.toString() ?? 'No details',
                                      ),
                                    const Divider(height: 24),

                                    // Action buttons
                                    ResultActionsRowButton(
                                      isDeleteLoading: diagnosisState.deleteLoading,
                                      onDelete: () {
                                        diagnosisCtrl.deleteDiagnosisById(
                                          result.id!.toString(),
                                          onSuccess: () {
                                            if (mounted) {
                                              context.showSnackBar(message: 'Record deleted successfully');
                                            }
                                          },
                                        );
                                      },
                                      onEdit: () {
                                        MedicalFormsData.navigateToEditForm(
                                          context,
                                          MedicalFormsData.diagnosis.id,
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
