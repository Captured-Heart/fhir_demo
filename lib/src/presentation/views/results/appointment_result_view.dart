import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/appointments_controller.dart';
import 'package:fhir_demo/src/domain/models/medical_forms_data.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/detail_row_results.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/no_records_found.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/results_row_action_button.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppointmentResultDetailView extends ConsumerStatefulWidget {
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  const AppointmentResultDetailView({
    super.key,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });

  @override
  ConsumerState<AppointmentResultDetailView> createState() => _AppointmentResultDetailViewState();
}

class _AppointmentResultDetailViewState extends ConsumerState<AppointmentResultDetailView> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentsController.notifier).fetchAppointmentsByIdentifier();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appointmentState = ref.watch(appointmentsController);
    final appointmentCtrl = ref.read(appointmentsController.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Records'),
        backgroundColor: widget.categoryColor,
        foregroundColor: AppColors.kWhite,
        actions: [
          AppBarServerSwitch(
            onServerChanged: () {
              ref.read(appointmentsController.notifier).fetchAppointmentsByIdentifier();
            },
          ),
        ],
      ),
      body:
          appointmentState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : appointmentState.appointmentsList.isEmpty
              ? Center(child: NoRecordsFound(icon: widget.categoryIcon))
              : Column(
                children: [
                  const SizedBox(height: 12),
                  const SelectedServerText(),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: appointmentState.appointmentsList.length,
                      itemBuilder: (context, index) {
                        final result = appointmentState.appointmentsList[index];
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
                              text: 'Record #${index + 1} - ${result.appointmentType?.text ?? 'No Type'}',
                              context: context,
                              textStyle: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            subtitle: MoodText.text(
                              text: result.start?.toString() ?? 'No date',
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
                                    BuildDetailRow(
                                      label: 'ID',
                                      value: result.participant.first.actor?.reference?.split('/').last ?? 'N/A',
                                    ),
                                    if (result.comment != null)
                                      BuildDetailRow(label: 'Details', value: result.comment?.valueString ?? ''),
                                    const Divider(height: 24),

                                    // Action buttons
                                    ResultActionsRowButton(
                                      isDeleteLoading: appointmentState.deleteLoading,
                                      onDelete: () {
                                        appointmentCtrl.deleteAppointmentById(
                                          result.id!.valueString!,
                                          onSuccess: () {
                                            if (mounted) {
                                              context.showSnackBar(message: 'Appointment deleted successfully');
                                            }
                                          },
                                        );
                                      },
                                      onEdit: () {
                                        MedicalFormsData.navigateToEditForm(
                                          context,
                                          MedicalFormsData.appointments.id,
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
