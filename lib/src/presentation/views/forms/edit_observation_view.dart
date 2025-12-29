import 'package:fhir_demo/src/controller/observations_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
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

class EditObservationView extends ConsumerStatefulWidget {
  final Observation observation;

  const EditObservationView({super.key, required this.observation});

  @override
  ConsumerState<EditObservationView> createState() => _EditObservationViewState();
}

class _EditObservationViewState extends ConsumerState<EditObservationView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(observationsController.notifier).populateFormForEdit(widget.observation);
    });
  }

  Future<void> _selectDate() async {
    final controller = ref.read(observationsController.notifier);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.observationDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(observationsController.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Vital Signs'),
        backgroundColor: const Color(0xffE91E63),
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
                  text: 'Edit Patient Vital Signs',
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
                  labelText: 'Observation Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: controller.observationDateController,
                  readOnly: true,
                  onTap: _selectDate,
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select observation date';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Blood Pressure',
                  hintText: 'e.g., 120/80 mmHg',
                  controller: controller.bloodPressureController,
                  prefixIcon: const Icon(Icons.favorite),
                ),

                MoodTextfield(
                  labelText: 'Heart Rate',
                  hintText: 'e.g., 72 bpm',
                  controller: controller.heartRateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.monitor_heart),
                ),

                MoodTextfield(
                  labelText: 'Temperature',
                  hintText: 'e.g., 37.0 °C',
                  controller: controller.temperatureController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.thermostat),
                ),

                MoodTextfield(
                  labelText: 'Respiratory Rate',
                  hintText: 'e.g., 16 breaths/min',
                  controller: controller.respiratoryRateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.air),
                ),

                MoodTextfield(
                  labelText: 'Oxygen Saturation',
                  hintText: 'e.g., 98%',
                  controller: controller.oxygenSaturationController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.opacity),
                ),

                MoodTextfield(
                  labelText: 'Weight',
                  hintText: 'e.g., 70 kg',
                  controller: controller.weightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.scale),
                ),

                MoodTextfield(
                  labelText: 'Height',
                  hintText: 'e.g., 170 cm',
                  controller: controller.heightController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.height),
                ),

                MoodTextfield(
                  labelText: 'Clinical Notes',
                  hintText: 'Enter additional observations',
                  controller: controller.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.note_alt),
                ),

                const SizedBox(height: 10),

                MoodPrimaryButton(
                  title: 'Update Vital Signs',
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vital signs updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  state: ButtonState.initial,
                  bGcolor: const Color(0xffE91E63),
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
