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

class LabResultsView extends ConsumerStatefulWidget {
  const LabResultsView({super.key});

  @override
  ConsumerState<LabResultsView> createState() => _LabResultsViewState();
}

class _LabResultsViewState extends ConsumerState<LabResultsView> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _testNameController = TextEditingController();
  final _testCodeController = TextEditingController();
  final _resultValueController = TextEditingController();
  final _unitController = TextEditingController();
  final _referenceRangeController = TextEditingController();
  final _specimenController = TextEditingController();
  final _performerController = TextEditingController();
  final _testDateController = TextEditingController();
  final _notesController = TextEditingController();

  ButtonState _submitState = ButtonState.initial;
  String? _selectedInterpretation;
  String? _selectedStatus;

  @override
  void dispose() {
    _patientIdController.dispose();
    _testNameController.dispose();
    _testCodeController.dispose();
    _resultValueController.dispose();
    _unitController.dispose();
    _referenceRangeController.dispose();
    _specimenController.dispose();
    _performerController.dispose();
    _testDateController.dispose();
    _notesController.dispose();
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
      _testDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitState = ButtonState.loading);

      // TODO: Implement FHIR lab result submission
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _submitState = ButtonState.initial);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lab result recorded successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _testNameController.clear();
    _testCodeController.clear();
    _resultValueController.clear();
    _unitController.clear();
    _referenceRangeController.clear();
    _specimenController.clear();
    _performerController.clear();
    _testDateController.clear();
    _notesController.clear();
    setState(() {
      _selectedInterpretation = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Results'),
        backgroundColor: const Color(0xff00BCD4),
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
                  text: 'Laboratory Test Results',
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

                // Test Name
                MoodTextfield(
                  labelText: 'Test Name *',
                  hintText: 'e.g., Complete Blood Count',
                  controller: _testNameController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.science),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter test name';
                    }
                    return null;
                  },
                ),

                // Test Code
                MoodTextfield(
                  labelText: 'Test Code',
                  hintText: 'e.g., CBC-001',
                  controller: _testCodeController,
                  prefixIcon: const Icon(Icons.qr_code),
                ),

                // Test Date
                MoodTextfield(
                  labelText: 'Test Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: _testDateController,
                  readOnly: true,
                  onTap: _selectDate,
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select test date';
                    }
                    return null;
                  },
                ),

                // Result Value
                MoodTextfield(
                  labelText: 'Result Value *',
                  hintText: 'Enter test result',
                  controller: _resultValueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.analytics),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter result value';
                    }
                    return null;
                  },
                ),

                // Unit
                MoodTextfield(
                  labelText: 'Unit *',
                  hintText: 'e.g., mg/dL, mmol/L',
                  controller: _unitController,
                  prefixIcon: const Icon(Icons.straighten),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter unit';
                    }
                    return null;
                  },
                ),

                // Reference Range
                MoodTextfield(
                  labelText: 'Reference Range',
                  hintText: 'e.g., 70-100 mg/dL',
                  controller: _referenceRangeController,
                  prefixIcon: const Icon(Icons.compare_arrows),
                ),

                // Interpretation
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Interpretation',
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
                          value: _selectedInterpretation,
                          hint: const Text('Select interpretation'),
                          isExpanded: true,
                          items:
                              ['Normal', 'High', 'Low', 'Critical', 'Abnormal'].map((interpretation) {
                                return DropdownMenuItem(value: interpretation, child: Text(interpretation));
                              }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedInterpretation = value);
                          },
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
                        border: Border.all(color: AppColors.kGrey.withOpacity(0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedStatus,
                          hint: const Text('Select status'),
                          isExpanded: true,
                          items:
                              ['Registered', 'Preliminary', 'Final', 'Amended', 'Corrected', 'Cancelled'].map((status) {
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

                // Specimen Type
                MoodTextfield(
                  labelText: 'Specimen Type',
                  hintText: 'e.g., Blood, Urine',
                  controller: _specimenController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.biotech),
                ),

                // Performer/Lab
                MoodTextfield(
                  labelText: 'Performer/Laboratory',
                  hintText: 'Enter lab or performer name',
                  controller: _performerController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.business),
                ),

                // Clinical Notes
                MoodTextfield(
                  labelText: 'Clinical Notes',
                  hintText: 'Enter additional notes',
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Record Lab Result',
                  onPressed: _submitForm,
                  state: _submitState,
                  bGcolor: const Color(0xff00BCD4),
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
