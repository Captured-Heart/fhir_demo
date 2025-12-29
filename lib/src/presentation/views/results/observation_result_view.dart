import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/controller/patient_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/results_row_action_button.dart';
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
    ref.read(patientController.notifier).fetchPatientsByIdentifier();
    // TODO: Fetch results for the specific category if needed
  }

  @override
  Widget build(BuildContext context) {
    'what is categoryTitle: ${widget.categoryTitle}'.logError();
    // TODO: Fetch actual results from API/storage
    final mockResults = _getMockResults();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.categoryTitle} Records'),
        backgroundColor: widget.categoryColor,
        foregroundColor: AppColors.kWhite,
      ),
      body:
          mockResults.isEmpty
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
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: mockResults.length,
                itemBuilder: (context, index) {
                  final result = mockResults[index];
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
                        text: result['title'] ?? 'Record #${index + 1}',
                        context: context,
                        textStyle: context.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      subtitle: MoodText.text(
                        text: result['date'] ?? 'No date',
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
                              _buildDetailRow(context, 'Status', result['status'] ?? 'Unknown'),
                              _buildDetailRow(context, 'ID', result['id'] ?? 'N/A'),
                              if (result['details'] != null)
                                _buildDetailRow(context, 'Details', result['details'] ?? ''),
                              const Divider(height: 24),

                              // Action buttons
                              ResultActionsRowButton(isDeleteLoading: false, onDelete: () {}),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
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

  // Mock data - replace with actual API data
  List<Map<String, String>> _getMockResults() {
    return [
      {
        'title': 'Recent ${widget.categoryTitle} Entry',
        'date': DateTime.now().subtract(const Duration(days: 2)).toString().split(' ')[0],
        'status': 'Completed',
        'id': 'REC-${DateTime.now().millisecondsSinceEpoch}',
        'details': 'All fields submitted successfully. Data has been processed and stored.',
      },
      {
        'title': 'Previous ${widget.categoryTitle} Record',
        'date': DateTime.now().subtract(const Duration(days: 15)).toString().split(' ')[0],
        'status': 'Reviewed',
        'id': 'REC-${DateTime.now().subtract(const Duration(days: 15)).millisecondsSinceEpoch}',
        'details': 'Record has been reviewed by healthcare provider.',
      },
      {
        'title': 'Initial ${widget.categoryTitle} Assessment',
        'date': DateTime.now().subtract(const Duration(days: 30)).toString().split(' ')[0],
        'status': 'Archived',
        'id': 'REC-${DateTime.now().subtract(const Duration(days: 30)).millisecondsSinceEpoch}',
        'details': 'Initial assessment completed. Follow-up recommended.',
      },
    ];
  }
}
