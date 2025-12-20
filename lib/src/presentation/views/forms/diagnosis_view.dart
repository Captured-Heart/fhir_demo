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
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _conditionController = TextEditingController();
  final _severityController = TextEditingController();
  final _onsetDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _diagnosingDoctorController = TextEditingController();

  ButtonState _submitState = ButtonState.initial;
  String? _selectedSeverity;
  String? _selectedStatus;

  @override
  void dispose() {
    _patientIdController.dispose();
    _conditionController.dispose();
    _severityController.dispose();
    _onsetDateController.dispose();
    _notesController.dispose();
    _diagnosingDoctorController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _onsetDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitState = ButtonState.loading);

      // TODO: Implement FHIR diagnosis submission
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _submitState = ButtonState.initial);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Diagnosis recorded successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _conditionController.clear();
    _severityController.clear();
    _onsetDateController.clear();
    _notesController.clear();
    _diagnosingDoctorController.clear();
    setState(() {
      _selectedSeverity = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Diagnosis'),
        backgroundColor: const Color(0xff2196F3),
        foregroundColor: AppColors.kWhite,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
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
                  controller: _patientIdController,
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
                  controller: _conditionController,
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
                        border: Border.all(color: AppColors.kGrey.withOpacity(0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSeverity,
                          hint: const Text('Select severity'),
                          isExpanded: true,
                          items:
                              ['Mild', 'Moderate', 'Severe'].map((severity) {
                                return DropdownMenuItem(value: severity, child: Text(severity));
                              }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedSeverity = value);
                          },
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
                        border: Border.all(color: AppColors.kGrey.withOpacity(0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          hint: const Text('Select status'),
                          isExpanded: true,
                          items:
                              ['Active', 'Recurrence', 'Relapse', 'Inactive', 'Remission', 'Resolved'].map((status) {
                                return DropdownMenuItem(value: status, child: Text(status));
                              }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedStatus = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Onset Date
                MoodTextfield(
                  labelText: 'Onset Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: _onsetDateController,
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
                  controller: _diagnosingDoctorController,
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
                  controller: _notesController,
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
                MoodOutlineButton(title: 'Clear Form', onPressed: _clearForm, color: AppColors.kGrey),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
