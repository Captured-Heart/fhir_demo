import 'package:fhir_demo/src/controller/lab_results_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
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

class EditLabResultView extends ConsumerStatefulWidget {
  final DiagnosticReport labResult;

  const EditLabResultView({super.key, required this.labResult});

  @override
  ConsumerState<EditLabResultView> createState() => _EditLabResultViewState();
}

class _EditLabResultViewState extends ConsumerState<EditLabResultView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(labResultsController.notifier).populateFormForEdit(widget.labResult);
    });
  }

  Future<void> _selectDate() async {
    final controller = ref.read(labResultsController.notifier);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.testDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(labResultsController.notifier);
    final state = ref.watch(labResultsController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lab Result'),
        backgroundColor: const Color(0xff00BCD4),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),

                MoodText.text(
                  text: 'Edit Laboratory Test Results',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                MoodTextfield(
                  labelText: 'Patient ID *',
                  hintText: 'Enter patient identifier',
                  controller: controller.patientIdController,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient ID';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Test Name *',
                  hintText: 'e.g., Complete Blood Count',
                  controller: controller.testNameController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.science),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter test name';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Test Code',
                  hintText: 'e.g., CBC',
                  controller: controller.testCodeController,
                  textCapitalization: TextCapitalization.characters,
                  prefixIcon: const Icon(Icons.qr_code),
                ),

                MoodTextfield(
                  labelText: 'Test Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: controller.testDateController,
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

                MoodTextfield(
                  labelText: 'Result Value *',
                  hintText: 'Enter test result value',
                  controller: controller.resultValueController,
                  prefixIcon: const Icon(Icons.numbers),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter result value';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Unit',
                  hintText: 'e.g., mg/dL, mmol/L',
                  controller: controller.unitController,
                  prefixIcon: const Icon(Icons.straighten),
                ),

                MoodTextfield(
                  labelText: 'Reference Range',
                  hintText: 'e.g., 4.5-5.5',
                  controller: controller.referenceRangeController,
                  prefixIcon: const Icon(Icons.compare_arrows),
                ),

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
                        border: Border.all(color: AppColors.kGrey.withValues(alpha: 0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedInterpretation,
                          hint: const Text('Select interpretation'),
                          isExpanded: true,
                          items:
                              ['Normal', 'Abnormal', 'High', 'Low', 'Critical'].map((interpretation) {
                                return DropdownMenuItem(value: interpretation, child: Text(interpretation));
                              }).toList(),
                          onChanged: (value) => controller.setSelectedInterpretation(value),
                        ),
                      ),
                    ),
                  ],
                ),

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
                          value: state.selectedStatus,
                          hint: const Text('Select status'),
                          isExpanded: true,
                          items:
                              ['Registered', 'Partial', 'Preliminary', 'Final', 'Amended', 'Corrected', 'Cancelled'].map((status) {
                                return DropdownMenuItem(value: status, child: Text(status));
                              }).toList(),
                          onChanged: (value) => controller.setSelectedStatus(value),
                        ),
                      ),
                    ),
                  ],
                ),

                MoodTextfield(
                  labelText: 'Specimen Type',
                  hintText: 'e.g., Blood, Urine',
                  controller: controller.specimenController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.water_drop),
                ),

                MoodTextfield(
                  labelText: 'Performed By',
                  hintText: 'Enter lab technician or doctor name',
                  controller: controller.performerController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.person_outline),
                ),

                MoodTextfield(
                  labelText: 'Clinical Notes',
                  hintText: 'Enter additional observations or comments',
                  controller: controller.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 4,
                  prefixIcon: const Icon(Icons.note_alt),
                ),

                const SizedBox(height: 10),

                MoodPrimaryButton(
                  title: 'Update Lab Result',
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Lab result updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  state: state.isLoading ? ButtonState.loading : ButtonState.initial,
                  bGcolor: const Color(0xff00BCD4),
                ),

                MoodOutlineButton(title: 'Reset Form', onPressed: () => controller.clearForm(), color: AppColors.kGrey),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
