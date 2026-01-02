import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/observations_controller.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/detail_row_results.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/no_records_found.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/results_row_action_button.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ObservationResultDetailView extends ConsumerStatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const ObservationResultDetailView({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  ConsumerState<ObservationResultDetailView> createState() => _ObservationResultDetailViewState();
}

class _ObservationResultDetailViewState extends ConsumerState<ObservationResultDetailView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(observationsController.notifier).fetchObservationByIdentifier();
    });
  }

  @override
  Widget build(BuildContext context) {
    'what is categoryTitle: ${widget.categoryTitle}'.logError();
    final observationState = ref.watch(observationsController);
    final observationCtrl = ref.read(observationsController.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Records'),
        backgroundColor: widget.categoryColor,
        foregroundColor: AppColors.kWhite,
        actions: [
          AppBarServerSwitch(
            onServerChanged: () {
              ref.read(observationsController.notifier).fetchObservationByIdentifier();
            },
          ),
        ],
      ),
      body:
          observationState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : observationState.observationsList.isEmpty
              ? Center(child: NoRecordsFound(icon: widget.categoryIcon))
              : Column(
                children: [
                  const SizedBox(height: 12),
                  const SelectedServerText(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: observationState.observationsList.length,
                      itemBuilder: (context, index) {
                        final result = observationState.observationsList[index];
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
                              text: 'Record #${index + 1} - ${result.code.coding?.first.display ?? 'No Code'}',
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
                                  mainAxisSize: MainAxisSize.min,
                                  spacing: 4,
                                  children: [
                                    BuildDetailRow(label: 'Status', value: result.status.valueString ?? 'Unknown'),
                                    BuildDetailRow(label: 'ID', value: result.id?.valueString ?? 'N/A'),
                                    if (result.component != null)
                                      ...List.generate(result.component?.length ?? 0, (compIndex) {
                                        final quantity = result.component![compIndex].valueQuantity;
                                        if (quantity == null || (quantity.value?.valueString?.isEmpty == true)) {
                                          return const SizedBox.shrink();
                                        }
                                        return BuildDetailRow(
                                          label:
                                              result.component![compIndex].code.coding?.first.display?.valueString ??
                                              'N/A',
                                          value:
                                              '${quantity.value?.valueString ?? 'N/A'} ${quantity.unit?.valueString ?? ''}',
                                        );
                                      }),
                                    const Divider(height: 24),

                                    // Action buttons
                                    ResultActionsRowButton(
                                      isDeleteLoading: observationState.deleteLoading,
                                      onDelete: () {
                                        observationCtrl.deleteObservationById(
                                          result.id!.valueString!,
                                          onSuccess: () {
                                            if (mounted) {
                                              context.showSnackBar(message: 'Observation deleted successfully');
                                            }
                                          },
                                        );
                                      },
                                      onEdit:
                                          () => MedicalFormsData.navigateToEditForm(
                                            context,
                                            MedicalFormsData.observations.id,
                                            arguments: result,
                                          ),
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
