import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/lab_results_controller.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/detail_row_results.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/no_records_found.dart';

import 'package:fhir_demo/src/presentation/widgets/shared/results_row_action_button.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LabResultDetailView extends ConsumerStatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const LabResultDetailView({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  ConsumerState<LabResultDetailView> createState() => _LabResultDetailViewState();
}

class _LabResultDetailViewState extends ConsumerState<LabResultDetailView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(labResultsController.notifier).fetchLabResultsByIdentifier();
    });
  }

  @override
  Widget build(BuildContext context) {
    'what is categoryTitle: ${widget.categoryTitle}'.logError();
    final labResultsState = ref.watch(labResultsController);
    final labResultsCtrl = ref.read(labResultsController.notifier);
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Records'),
        backgroundColor: widget.categoryColor,
        foregroundColor: AppColors.kWhite,
        actions: [
          AppBarServerSwitch(
            onServerChanged: () {
              ref.read(labResultsController.notifier).fetchLabResultsByIdentifier();
            },
          ),
        ],
      ),
      body:
          labResultsState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : labResultsState.labResultsList.isEmpty
              ? Center(child: NoRecordsFound(icon: widget.categoryIcon))
              : Column(
                children: [
                  const SizedBox(height: 12),
                  const SelectedServerText(),
                  //
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: labResultsState.labResultsList.length,
                      itemBuilder: (context, index) {
                        final result = labResultsState.labResultsList[index];
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
                              text: 'Record #${index + 1} - ${result.conclusion}',
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
                                    BuildDetailRow(
                                      label: 'Status',
                                      value:
                                          '${result.status.valueString?.toUpperCase().toString() ?? 'N/A'} - title: ${result.code.text?.valueString ?? 'N/A'}',
                                    ),
                                    BuildDetailRow(
                                      label: 'ID',
                                      value: result.subject?.reference?.split('/').last ?? 'N/A',
                                    ),
                                    if (result.performer != null)
                                      BuildDetailRow(
                                        label: 'Details',
                                        value: result.performer?.first.display?.valueString ?? '',
                                      ),
                                    const Divider(height: 24),

                                    // Action buttons
                                    ResultActionsRowButton(
                                      isDeleteLoading: labResultsState.deleteLoading,
                                      onDelete: () {
                                        labResultsCtrl.deleteLabResultById(
                                          result.id!.valueString!,
                                          onSuccess: () {
                                            if (mounted) {
                                              context.showSnackBar(message: 'Lab result deleted successfully');
                                            }
                                          },
                                        );
                                      },
                                      onEdit: () {
                                        MedicalFormsData.navigateToEditForm(
                                          context,
                                          MedicalFormsData.labResults.id,
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
