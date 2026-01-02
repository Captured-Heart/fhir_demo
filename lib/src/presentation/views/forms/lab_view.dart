import 'package:fhir_demo/src/controller/lab_results_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/patient_id_dropdown.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_drop_down.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
import 'package:fhir_demo/utils/validations.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/button_state.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/primary_button.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/outline_button.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_textfield.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class LabView extends ConsumerStatefulWidget {
  const LabView({super.key, this.labResult});
  final DiagnosticReport? labResult;

  @override
  ConsumerState<LabView> createState() => _LabViewState();
}

class _LabViewState extends ConsumerState<LabView> {
  bool get isEdit => widget.labResult != null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEdit && widget.labResult != null) {
        ref.read(labResultsController.notifier).populateFormForEdit(widget.labResult!);
      }
      if (!isEdit) {
        showInstructionDialog(
          context: context,
          title: 'Lab Results',
          subtitle: 'Fill out the form to record new Lab Results in the system. ',
          sharedKeys: SharedKeys.laboratoryInstructionDontShowAgain,
        );
      }
    });
  }

  Future<void> _selectDate({required Function(DateTime) onPicked}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      onPicked.call(picked);
    }
  }

  void _clearForm() {
    ref.read(labResultsController.notifier).clearForm();
  }

  @override
  Widget build(BuildContext context) {
    final labResultsCtrl = ref.watch(labResultsController.notifier);
    final labResultState = ref.watch(labResultsController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lab Results'),
        backgroundColor: const Color(0xff00BCD4),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: labResultsCtrl.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),
                // Header
                MoodText.text(
                  text: 'Laboratory Test Results',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                // Patient ID
                PatientIdDropdown(
                  onChanged: (value) => labResultsCtrl.setSelectedPatientId(value),
                  isEdit: isEdit,
                  patientIdController: labResultsCtrl.patientIdController,
                ),

                // Test Name
                MoodTextfield(
                  labelText: 'Test Name *',
                  hintText: 'e.g., Complete Blood Count',
                  controller: labResultsCtrl.testNameController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [],
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
                  controller: labResultsCtrl.testCodeController,
                  inputFormatters: [],
                  prefixIcon: const Icon(Icons.qr_code),
                ),

                // Test Date
                MoodTextfield(
                  labelText: 'Test Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: labResultsCtrl.testDateController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (pickedDate) {
                          labResultsCtrl.formatTestDate(pickedDate);
                        },
                      ),
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
                  hintText: 'Enter test result (Number)',
                  controller: labResultsCtrl.resultValueController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.analytics),
                  validator: (value) => AppValidations.validateNumberOnly(value),
                ),

                // Unit
                MoodTextfield(
                  labelText: 'Unit *',
                  hintText: 'e.g., mg/dL, mmol/L',
                  controller: labResultsCtrl.unitController,
                  inputFormatters: [],
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
                  controller: labResultsCtrl.referenceRangeController,
                  prefixIcon: const Icon(Icons.compare_arrows),
                ),

                // Interpretation
                AppDropDownWidget(
                  value: labResultState.selectedInterpretation,
                  labelText: 'Interpretation',
                  hintText: 'Select interpretation',
                  items: ['Normal', 'High', 'Low', 'Critical', 'Abnormal'],
                  onChanged: (value) => labResultsCtrl.setSelectedInterpretation(value as String?),
                ),

                // Status
                AppDropDownWidget(
                  value: labResultState.selectedStatus,
                  labelText: 'Status *',
                  hintText: 'Select status',
                  items: ['Registered', 'Partial', 'Preliminary', 'Final', 'Amended', 'Corrected', 'Cancelled'],
                  onChanged: (value) => labResultsCtrl.setSelectedStatus(value as String?),
                ),

                // Specimen Type
                MoodTextfield(
                  labelText: 'Specimen Type',
                  hintText: 'e.g., Blood, Urine',
                  controller: labResultsCtrl.specimenController,
                  inputFormatters: [],
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.biotech),
                ),

                // Performer/Lab
                MoodTextfield(
                  labelText: 'Performer/Laboratory',
                  hintText: 'Enter lab or performer name',
                  controller: labResultsCtrl.performerController,
                  inputFormatters: [],
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.business),
                ),

                // Clinical Notes
                MoodTextfield(
                  labelText: 'Clinical Notes',
                  hintText: 'Enter additional notes',
                  controller: labResultsCtrl.notesController,
                  inputFormatters: [],
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: isEdit ? 'Update Lab Result' : 'Record Lab Result',
                  onPressed:
                      labResultState.isLoading
                          ? null
                          : () {
                            if (!isEdit) {
                              submitLabResultForm(labResultsCtrl);
                            } else {
                              editLabResultForm(labResultsCtrl);
                            }
                          },
                  state: labResultState.isLoading ? ButtonState.loading : ButtonState.loaded,
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

  void submitLabResultForm(LabResultsNotifier labResultsCtrl) {
    labResultsCtrl.submitLabResultForm(
      onInterpretationValidationFailed: () {
        context.showSnackBar(message: 'Please select an interpretation', isError: true);
      },
      onStatusValidationFailed: () {
        context.showSnackBar(message: 'Please select a clinical status', isError: true);
      },
      onPatientNotFound: () {
        context.showSnackBar(message: 'Patient ID not found. Please create the patient first.', isError: true);
      },
      onSuccess: () {
        Navigator.of(context).pop();
        context.showSnackBar(message: 'Diagnosis recorded successfully');
      },
      onError: () {
        context.showSnackBar(message: 'Failed to record diagnosis. Please try again.', isError: true);
      },
    );
  }

  void editLabResultForm(LabResultsNotifier labResultsCtrl) {
    labResultsCtrl.editLabResultForm(
      existingLabResult: widget.labResult!,
      onInterpretationValidationFailed: () {
        context.showSnackBar(message: 'Please select an interpretation', isError: true);
      },
      onStatusValidationFailed: () {
        context.showSnackBar(message: 'Please select a clinical status', isError: true);
      },
      onPatientNotFound: () {
        context.showSnackBar(message: 'Patient ID not found. Please create the patient first.', isError: true);
      },
      onSuccess: () {
        Navigator.of(context).pop();
        context.showSnackBar(message: 'Lab result updated successfully');
      },
      onError: () {
        context.showSnackBar(message: 'Failed to update lab result. Please try again.', isError: true);
      },
    );
  }
}
