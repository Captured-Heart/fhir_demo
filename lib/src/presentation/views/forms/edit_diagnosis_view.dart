import 'dart:developer';

import 'package:fhir_demo/src/controller/diagnosis_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/constants/diagnostic_status_constants.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/button_state.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/spacings.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/primary_button.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/outline_button.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_textfield.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class EditDiagnosisView extends ConsumerStatefulWidget {
  final DiagnosticReport diagnosis;

  const EditDiagnosisView({super.key, required this.diagnosis});

  @override
  ConsumerState<EditDiagnosisView> createState() => _EditDiagnosisViewState();
}

class _EditDiagnosisViewState extends ConsumerState<EditDiagnosisView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(diagnosisController.notifier).populateFormForEdit(widget.diagnosis);
    });
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
    inspect(widget.diagnosis);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Diagnosis'),
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
                  text: 'Edit Diagnosis Information',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                // Patient ID
                MoodTextfield(
                  labelText: 'Patient ID *',
                  hintText: 'Enter patient identifier',
                  controller: diagnosisCtrl.patientIdController,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient ID';
                    }
                    return null;
                  },
                ),

                // Condition/Diagnosis
                MoodTextfield(
                  labelText: 'Condition/Diagnosis *',
                  hintText: 'Enter medical condition',
                  controller: diagnosisCtrl.conditionController,
                  textCapitalization: TextCapitalization.sentences,
                  prefixIcon: const Icon(Icons.medical_services),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter condition';
                    }
                    return null;
                  },
                ),

                // Severity
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Severity',
                      context: context,
                      textStyle: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.kGrey.withValues(alpha: 0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: diagnosisState.selectedSeverity,
                          hint: const Text('Select severity'),
                          isExpanded: true,
                          items:
                              ['Mild', 'Moderate', 'Severe', 'Critical'].map((severity) {
                                return DropdownMenuItem(value: severity, child: Text(severity));
                              }).toList(),
                          onChanged: (value) => diagnosisCtrl.setSelectedSeverity(value),
                        ),
                      ),
                    ),
                  ],
                ),

                // Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Status *',
                      context: context,
                      textStyle: context.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.kGrey.withValues(alpha: 0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: diagnosisState.selectedStatus?.toLowerCase(),
                          hint: const Text('Select status'),
                          isExpanded: true,
                          items:
                              DiagnosticStatusConstants.diagnosticReportStatuses.map((status) {
                                return DropdownMenuItem(value: status, child: Text(status));
                              }).toList(),
                          onChanged: (value) => diagnosisCtrl.setSelectedStatus(value),
                        ),
                      ),
                    ),
                  ],
                ),

                // Onset Date
                MoodTextfield(
                  labelText: 'Onset Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: diagnosisCtrl.onsetDateController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (date) {
                          if (date != null) {
                            diagnosisCtrl.onsetDateController.text =
                                '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
                          }
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
                  hintText: 'Enter additional notes',
                  controller: diagnosisCtrl.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  prefixIcon: const Icon(Icons.note_alt),
                ),

                const SizedBox(height: 10),

                // Update Button
                MoodPrimaryButton(
                  title: 'Update Diagnosis',
                  onPressed: () {
                    diagnosisCtrl.editDiagnosisForm(
                      existingDiagnosis: widget.diagnosis,
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
                        context.showSnackBar(message: 'Diagnosis update successfully');
                      },
                      onError: () {
                        context.showSnackBar(message: 'Failed to update diagnosis. Please try again.', isError: true);
                      },
                    );
                  },
                  state: diagnosisState.isLoading ? ButtonState.loading : ButtonState.initial,
                  bGcolor: const Color(0xff2196F3),
                ),

                // Clear Button
                MoodOutlineButton(
                  title: 'Reset Form',
                  onPressed: () => diagnosisCtrl.clearForm(),
                  color: AppColors.kGrey,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
