import 'package:fhir_demo/src/controller/diagnosis_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
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

  ButtonState _submitState = ButtonState.initial;

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

  Future<void> _submitForm() async {
    setState(() => _submitState = ButtonState.loading);

    // TODO: Implement FHIR diagnosis submission
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _submitState = ButtonState.initial);

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Diagnosis recorded successfully!'), backgroundColor: Colors.green));
      Navigator.pop(context);
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
                      text: 'Severity *',
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
                              ['Mild', 'Moderate', 'Severe'].map((severity) {
                                return DropdownMenuItem(value: severity, child: Text(severity));
                              }).toList(),
                          onChanged: (value) => diagnosisCtrl.setSelectedSeverity(value),
                        ),
                      ),
                    ),
                  ],
                ),

                // Clinical Status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Clinical Status *',
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
                          value: diagnosisState.selectedStatus,
                          hint: const Text('Select status'),
                          isExpanded: true,
                          items:
                              ['Active', 'Recurrence', 'Relapse', 'Inactive', 'Remission', 'Resolved'].map((status) {
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
                  onTap: _selectDate,
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
                  hintText: 'Enter additional clinical notes',
                  controller: diagnosisCtrl.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Record Diagnosis',
                  onPressed: _submitForm,
                  state: _submitState,
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
