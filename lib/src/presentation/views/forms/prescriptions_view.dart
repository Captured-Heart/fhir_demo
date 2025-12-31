import 'package:fhir_demo/src/controller/prescriptions_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/patient_id_dropdown.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_drop_down.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
import 'package:fhir_demo/utils/validations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/app_colors.dart';
import 'package:fhir_demo/constants/button_state.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/primary_button.dart';
import 'package:fhir_demo/src/presentation/widgets/buttons/outline_button.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_textfield.dart';
import 'package:fhir_demo/src/presentation/widgets/texts/texts_widget.dart';

class PrescriptionsView extends ConsumerStatefulWidget {
  const PrescriptionsView({super.key});

  @override
  ConsumerState<PrescriptionsView> createState() => _PrescriptionsViewState();
}

class _PrescriptionsViewState extends ConsumerState<PrescriptionsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => showInstructionDialog(
        context: context,
        title: 'Prescription',
        subtitle: 'Fill out the form to record a new prescription in the system. ',
        sharedKeys: SharedKeys.prescriptionInstructionDontShowAgain,
      ),
    );
  }

  Future<void> _selectDate({Function(DateTime?)? onPicked}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      onPicked?.call(picked);
    }
  }

  void _clearForm() {
    final prescriptionctrl = ref.read(prescriptionsController.notifier);
    prescriptionctrl.clearForm();
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionctrl = ref.watch(prescriptionsController.notifier);
    final prescriptionState = ref.watch(prescriptionsController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prescriptions'),
        backgroundColor: const Color(0xffFF9800),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: prescriptionctrl.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),
                // Header
                MoodText.text(
                  text: 'Prescription Details',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                PatientIdDropdown(
                  onChanged: (patientId) {
                    prescriptionctrl.updatePatientId(patientId);
                  },
                ),

                // Medication Name
                MoodTextfield(
                  labelText: 'Medication Name *',
                  hintText: 'Enter medication name',
                  controller: prescriptionctrl.medicationController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [],
                  prefixIcon: const Icon(Icons.medication),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter medication name';
                    }
                    return null;
                  },
                ),

                // Dosage
                MoodTextfield(
                  labelText: 'Dosage *',
                  hintText: 'e.g., 500mg',
                  controller: prescriptionctrl.dosageController,
                  inputFormatters: [],
                  prefixIcon: const Icon(Icons.local_pharmacy),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    return AppValidations.validateNumberOnly(value, fieldName: 'Dosage');
                  },
                ),

                // Route
                AppDropDownWidget(
                  value: prescriptionState.selectedRoute,
                  labelText: 'Route of Administration *',
                  items: ['Oral', 'Intravenous', 'Intramuscular', 'Subcutaneous', 'Topical', 'Inhalation'],
                  onChanged: (value) {
                    prescriptionctrl.setSelectedRoute(value as String?);
                  },
                ),

                // Frequency
                MoodTextfield(
                  labelText: 'Frequency *',
                  hintText: 'e.g: 2 - (The unit is daily, and auto added)',
                  controller: prescriptionctrl.frequencyController,
                  textCapitalization: TextCapitalization.sentences,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.schedule),
                  validator: (value) {
                    return AppValidations.validateNumberOnly(value, fieldName: 'Frequency');
                  },
                ),

                // Duration
                MoodTextfield(
                  labelText: 'Duration *',
                  hintText: 'e.g., 7 (Unit is in days)',
                  controller: prescriptionctrl.durationController,
                  prefixIcon: const Icon(Icons.timer),
                  inputFormatters: [],
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    return AppValidations.validateNumberOnly(value, fieldName: 'Duration');
                  },
                ),

                // Start Date
                MoodTextfield(
                  labelText: 'Start Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: prescriptionctrl.startDateController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (value) {
                          prescriptionctrl.formatStartDate(value!);
                        },
                      ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select start date';
                    }
                    return null;
                  },
                ),

                // Prescribing Doctor
                MoodTextfield(
                  labelText: 'Prescribing Doctor *',
                  hintText: 'Enter doctor name',
                  controller: prescriptionctrl.prescribingDoctorController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [],
                  prefixIcon: const Icon(Icons.local_hospital),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),

                // Special Instructions
                MoodTextfield(
                  labelText: 'Special Instructions',
                  hintText: 'Enter special instructions for patient',
                  controller: prescriptionctrl.instructionsController,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [],
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.info_outline),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Create Prescription',
                  onPressed:
                      prescriptionState.isLoading
                          ? null
                          : () {
                            prescriptionctrl.submitForm(
                              onRouteofAdminFailed: () {
                                context.showSnackBar(message: 'Please select a route of administration', isError: true);
                              },
                              onSuccess: () {
                                context.showSnackBar(message: 'Prescription registered successfully');
                                Navigator.pop(context);
                              },
                              onError: () {
                                context.showSnackBar(message: 'Failed to register prescription', isError: true);
                              },
                            );
                          },
                  state: prescriptionState.isLoading ? ButtonState.loading : ButtonState.loaded,
                  bGcolor: const Color(0xffFF9800),
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
