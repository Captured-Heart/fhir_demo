import 'package:fhir_demo/src/controller/observations_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/patient_id_dropdown.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
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

class ObservationsView extends ConsumerStatefulWidget {
  const ObservationsView({super.key, this.observation});
  final Observation? observation;

  @override
  ConsumerState<ObservationsView> createState() => _ObservationsViewState();
}

class _ObservationsViewState extends ConsumerState<ObservationsView> {
  bool get isEdit => widget.observation != null;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEdit && widget.observation != null) {
        ref.read(observationsController.notifier).populateFormForEdit(widget.observation!);
      }

      if (!isEdit) {
        showInstructionDialog(
          context: context,
          title: 'Observations',
          subtitle: 'Fill out the form to record new observations in the system. ',
          sharedKeys: SharedKeys.observationInstructionDontShowAgain,
        );
      }
    });
  }

  Future<void> _selectDate({Function(DateTime)? onPicked}) async {
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

  void _clearForm() {
    ref.read(observationsController.notifier).clearForm();
  }

  Widget _suffixText(String text) {
    return MoodText.text(text: text, context: context, textStyle: context.textTheme.bodyMedium);
  }

  @override
  Widget build(BuildContext context) {
    final observationCtrl = ref.read(observationsController.notifier);
    final observationState = ref.watch(observationsController);
    // inspect(widget.observation);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Signs'),
        backgroundColor: const Color(0xffE91E63),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: observationCtrl.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),
                // Header
                MoodText.text(
                  text: 'Patient Vital Signs',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                // Patient ID
                PatientIdDropdown(
                  onChanged: (patientId) {
                    observationCtrl.updatePatientId(patientId);
                  },
                  isEdit: isEdit,
                  patientIdController: observationCtrl.patientIdController,
                ),

                // Observation Date
                MoodTextfield(
                  labelText: 'Observation Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: observationCtrl.observationDateController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (picked) {
                          observationCtrl.formatObservationDate(picked);
                        },
                      ),
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select observation date';
                    }
                    return null;
                  },
                ),

                // Blood Pressure
                MoodTextfield(
                  labelText: 'Blood Pressure',
                  hintText: 'e.g., 120/80 mmHg',
                  suffix: _suffixText('mmHg'),
                  controller: observationCtrl.bloodPressureController,
                  prefixIcon: const Icon(Icons.favorite),
                  keyboardType: TextInputType.numberWithOptions(signed: true),
                  validator: (value) => AppValidations.validateBloodPressure(value),
                ),

                // Heart Rate
                MoodTextfield(
                  labelText: 'Heart Rate',
                  hintText: 'e.g., 72 bpm',
                  suffix: _suffixText('bpm'),
                  controller: observationCtrl.heartRateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.monitor_heart),
                ),

                // Temperature
                MoodTextfield(
                  labelText: 'Temperature',
                  hintText: 'e.g., 37.0 °C',
                  suffix: _suffixText('°C'),
                  controller: observationCtrl.temperatureController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.thermostat),
                ),

                // Respiratory Rate
                MoodTextfield(
                  labelText: 'Respiratory Rate',
                  hintText: 'e.g., 16 breaths/min',
                  suffix: _suffixText('breaths/min'),
                  controller: observationCtrl.respiratoryRateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.air),
                ),

                // Oxygen Saturation
                MoodTextfield(
                  labelText: 'Oxygen Saturation',
                  hintText: 'e.g., 98%',
                  suffix: _suffixText('%'),
                  controller: observationCtrl.oxygenSaturationController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.opacity),
                ),

                // Weight
                MoodTextfield(
                  labelText: 'Weight',
                  hintText: 'e.g., 70 kg',
                  suffix: _suffixText('kg'),
                  controller: observationCtrl.weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.scale),
                ),

                // Height
                MoodTextfield(
                  labelText: 'Height',
                  hintText: 'e.g., 170 cm',
                  suffix: _suffixText('cm'),
                  controller: observationCtrl.heightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.height),
                ),

                // Clinical Notes
                MoodTextfield(
                  labelText: 'Clinical Notes',
                  hintText: 'Enter additional observations',
                  controller: observationCtrl.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  inputFormatters: [],
                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: isEdit ? 'Update Vital Signs' : 'Record Vital Signs',
                  onPressed:
                      observationState.isLoading
                          ? null
                          : isEdit
                          ? () => editForm(observationCtrl)
                          : () => submitForm(observationCtrl),
                  state: observationState.isLoading ? ButtonState.loading : ButtonState.loaded,
                  bGcolor: const Color(0xffE91E63),
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

  void submitForm(ObservationsNotifier observationCtrl) {
    observationCtrl.submitObservationForm(
      onPatientNotFound: () {
        context.showSnackBar(message: 'Patient ID not found. Please create the patient first.', isError: true);
      },
      onSuccess: () {
        Navigator.of(context).pop();
        context.showSnackBar(message: 'Observation recorded successfully');
      },
      onError: () {
        context.showSnackBar(message: 'Failed to record Observation. Please try again.', isError: true);
      },
    );
  }

  void editForm(ObservationsNotifier observationCtrl) {
    observationCtrl.editObservationForm(
      onPatientNotFound: () {
        context.showSnackBar(message: 'Patient ID not found. Please create the patient first.', isError: true);
      },
      onSuccess: () {
        Navigator.of(context).pop();
        context.showSnackBar(message: 'Observation updated successfully');
      },
      onError: () {
        context.showSnackBar(message: 'Failed to update Observation. Please try again.', isError: true);
      },
      existingObservation: widget.observation!,
    );
  }
}
