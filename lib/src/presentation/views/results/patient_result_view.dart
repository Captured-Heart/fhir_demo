import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/patient_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
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
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 16,
                  children: [
                    Icon(widget.categoryIcon, size: 64, color: AppColors.kGrey.withValues(alpha: 0.5)),
                    MoodText.text(
                      text: 'No records found',
                      context: context,
                      textStyle: context.textTheme.titleMedium?.copyWith(color: AppColors.kTextGrey),
                    ),
                    MoodText.text(
                      text: 'Submit a form to see results here',
                      context: context,
                      textStyle: context.textTheme.bodySmall?.copyWith(color: AppColors.kTextGrey),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  const SizedBox(height: 12),
                  const SelectedServerText(),

                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                              child: Icon(widget.categoryIcon, color: widget.categoryColor, size: 20),
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
                                    _buildDetailRow(context, 'Status', result.active?.toString() ?? 'Unknown'),
                                    _buildDetailRow(context, 'ID', result.id?.toString() ?? 'N/A'),
                                    if (result.address != null)
                                      _buildDetailRow(context, 'Details', result.address?.first.text?.toString() ?? ''),
                                    const Divider(height: 24),

                                    // Action buttons
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      spacing: 8,
                                      children: [
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.visibility),
                                          label: const Text('View Full'),
                                        ),
                                        TextButton.icon(
                                          onPressed: () {},
                                          icon: const Icon(Icons.download),
                                          label: const Text('Export'),
                                        ),
                                      ],
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

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: MoodText.text(
            text: '$label:',
            context: context,
            textStyle: context.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: MoodText.text(text: value, context: context, textStyle: context.textTheme.bodySmall)),
      ],
    );
  }
}
