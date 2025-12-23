import 'package:fhir_demo/src/controller/prescriptions_controller.dart';
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

  ButtonState _submitState = ButtonState.initial;

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

  Future<void> _submitForm() async {
    final prescriptionctrl = ref.read(prescriptionsController.notifier);
    if (prescriptionctrl.formKey.currentState!.validate()) {
      setState(() => _submitState = ButtonState.loading);

      // TODO: Implement FHIR prescription submission
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _submitState = ButtonState.initial);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Prescription created successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  void _clearForm() {
    final prescriptionctrl = ref.read(prescriptionsController.notifier);
    prescriptionctrl.clearForm();
  }

  @override
  Widget build(BuildContext context) {
    final prescriptionctrl = ref.watch(prescriptionsController.notifier);
    final state = ref.watch(prescriptionsController);

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

                // Patient ID
                MoodTextfield(
                  labelText: 'Patient ID *',
                  hintText: 'Enter patient identifier',
                  controller: prescriptionctrl.patientIdController,
                  prefixIcon: const Icon(Icons.person),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter patient ID';
                    }
                    return null;
                  },
                ),

                // Medication Name
                MoodTextfield(
                  labelText: 'Medication Name *',
                  hintText: 'Enter medication name',
                  controller: prescriptionctrl.medicationController,
                  textCapitalization: TextCapitalization.words,
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
                  prefixIcon: const Icon(Icons.local_pharmacy),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter dosage';
                    }
                    return null;
                  },
                ),

                // Route
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Route of Administration *',
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
                          value: state.selectedRoute,
                          hint: const Text('Select route'),
                          isExpanded: true,
                          items:
                              ['Oral', 'Intravenous', 'Intramuscular', 'Subcutaneous', 'Topical', 'Inhalation'].map((
                                route,
                              ) {
                                return DropdownMenuItem(value: route, child: Text(route));
                              }).toList(),
                          onChanged: (value) {
                            prescriptionctrl.setSelectedRoute(value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Frequency
                MoodTextfield(
                  labelText: 'Frequency *',
                  hintText: 'e.g., Twice daily',
                  controller: prescriptionctrl.frequencyController,
                  textCapitalization: TextCapitalization.sentences,
                  prefixIcon: const Icon(Icons.schedule),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter frequency';
                    }
                    return null;
                  },
                ),

                // Duration
                MoodTextfield(
                  labelText: 'Duration *',
                  hintText: 'e.g., 7 days',
                  controller: prescriptionctrl.durationController,
                  prefixIcon: const Icon(Icons.timer),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter duration';
                    }
                    return null;
                  },
                ),

                // Start Date
                MoodTextfield(
                  labelText: 'Start Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: prescriptionctrl.startDateController,
                  readOnly: true,
                  onTap: _selectDate,
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
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.info_outline),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Create Prescription',
                  onPressed: _submitForm,
                  state: _submitState,
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
