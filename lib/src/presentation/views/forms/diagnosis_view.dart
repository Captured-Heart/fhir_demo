import 'package:fhir_demo/src/controller/diagnosis_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/patient_id_dropdown.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_drop_down.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
import 'package:fhir_demo/constants/diagnostic_status_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/button_state.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/primary_button.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/outline_button.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_textfield.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class DiagnosisView extends ConsumerStatefulWidget {
  const DiagnosisView({super.key});

  @override
  ConsumerState<DiagnosisView> createState() => _DiagnosisViewState();
}

class _DiagnosisViewState extends ConsumerState<DiagnosisView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showInstructionDialog(
        context: context,
        title: 'Medical Diagnosis',
        subtitle: 'Fill out the form to record a new medical diagnosis in the system. ',
        sharedKeys: SharedKeys.diagnosisInstructionDontShowAgain,
      ),
    );
  }

  Future<void> _selectDate({Function(DateTime?)? onPicked}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onPicked?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final diagnosisCtrl = ref.read(diagnosisController.notifier);
    final diagnosisState = ref.watch(diagnosisController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Diagnosis'),
        backgroundColor: const Color(0xff2196F3),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: diagnosisCtrl.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),
                // Header
                MoodText.text(
                  text: 'Diagnosis Information',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                PatientIdDropdown(onChanged: (selectedId) => diagnosisCtrl.updatePatientId(selectedId)),

                // Condition/Diagnosis
                MoodTextfield(
                  labelText: 'Condition/Diagnosis *',
                  hintText: 'Enter medical condition',
                  controller: diagnosisCtrl.conditionController,
                  textCapitalization: TextCapitalization.sentences,
                  prefixIcon: const Icon(Icons.medical_services),
                  inputFormatters: [],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter condition';
                    }
                    return null;
                  },
                ),

                // Severity
                AppDropDownWidget(
                  value: diagnosisState.selectedSeverity,
                  labelText: 'Severity *',
                  items: ['Mild', 'Moderate', 'Severe'],
                  onChanged: (value) => diagnosisCtrl.setSelectedSeverity(value as String?),
                ),

                //clinical Status
                AppDropDownWidget(
                  value: diagnosisState.selectedStatus,
                  labelText: 'Clinical Status *',
                  items: DiagnosticStatusConstants.diagnosticReportStatuses,
                  onChanged: (value) => diagnosisCtrl.setSelectedStatus(value as String?),
                ),
                // Clinical Status

                // Onset Date
                MoodTextfield(
                  labelText: 'Onset Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: diagnosisCtrl.onsetDateController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (selectedDate) {
                          diagnosisCtrl.formatOnsetDate(selectedDate!);
                        },
                      ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select onset date';
                    }
                    return null;
                  },
                ),

                // Diagnosing Doctor
                MoodTextfield(
                  labelText: 'Diagnosing Doctor *',
                  hintText: 'Enter doctor name',
                  controller: diagnosisCtrl.diagnosingDoctorController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.local_hospital),
                  inputFormatters: [],
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),

                // Clinical Notes
                MoodTextfield(
                  labelText: 'Clinical Notes',
                  hintText: 'Enter additional clinical notes',
                  controller: diagnosisCtrl.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  inputFormatters: [],

                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Record Diagnosis',
                  onPressed:
                      () => diagnosisCtrl.submitDiagnosisForm(
                        onSeverityValidationFailed: () {
                          context.showSnackBar(message: 'Please select a severity', isError: true);
                        },
                        onStatusValidationFailed: () {
                          context.showSnackBar(message: 'Please select a clinical status', isError: true);
                        },
                        onPatientNotFound: () {
                          context.showSnackBar(
                            message: 'Patient ID not found. Please create the patient first.',
                            isError: true,
                          );
                        },
                        onSuccess: () {
                          Navigator.of(context).pop();
                          context.showSnackBar(message: 'Diagnosis recorded successfully');
                        },
                        onError: () {
                          context.showSnackBar(message: 'Failed to record diagnosis. Please try again.', isError: true);
                        },
                      ),
                  state: diagnosisState.isLoading ? ButtonState.loading : ButtonState.loaded,
                  bGcolor: const Color(0xff2196F3),
                ),

                // Clear Button
                MoodOutlineButton(title: 'Clear Form', onPressed: diagnosisCtrl.clearForm, color: AppColors.kGrey),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
