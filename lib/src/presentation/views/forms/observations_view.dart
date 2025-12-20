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
  const ObservationsView({super.key});

  @override
  ConsumerState<ObservationsView> createState() => _ObservationsViewState();
}

class _ObservationsViewState extends ConsumerState<ObservationsView> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _respiratoryRateController = TextEditingController();
  final _oxygenSaturationController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _notesController = TextEditingController();
  final _observationDateController = TextEditingController();

  ButtonState _submitState = ButtonState.initial;

  @override
  void dispose() {
    _patientIdController.dispose();
    _bloodPressureController.dispose();
    _heartRateController.dispose();
    _temperatureController.dispose();
    _respiratoryRateController.dispose();
    _oxygenSaturationController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _notesController.dispose();
    _observationDateController.dispose();
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
      _observationDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitState = ButtonState.loading);

      // TODO: Implement FHIR observation submission
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _submitState = ButtonState.initial);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vital signs recorded successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _bloodPressureController.clear();
    _heartRateController.clear();
    _temperatureController.clear();
    _respiratoryRateController.clear();
    _oxygenSaturationController.clear();
    _weightController.clear();
    _heightController.clear();
    _notesController.clear();
    _observationDateController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vital Signs'),
        backgroundColor: const Color(0xffE91E63),
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
                  text: 'Patient Vital Signs',
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

                // Observation Date
                MoodTextfield(
                  labelText: 'Observation Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: _observationDateController,
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

                // Blood Pressure
                MoodTextfield(
                  labelText: 'Blood Pressure',
                  hintText: 'e.g., 120/80 mmHg',
                  controller: _bloodPressureController,
                  prefixIcon: const Icon(Icons.favorite),
                ),

                // Heart Rate
                MoodTextfield(
                  labelText: 'Heart Rate',
                  hintText: 'e.g., 72 bpm',
                  controller: _heartRateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.monitor_heart),
                ),

                // Temperature
                MoodTextfield(
                  labelText: 'Temperature',
                  hintText: 'e.g., 37.0 °C',
                  controller: _temperatureController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.thermostat),
                ),

                // Respiratory Rate
                MoodTextfield(
                  labelText: 'Respiratory Rate',
                  hintText: 'e.g., 16 breaths/min',
                  controller: _respiratoryRateController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.air),
                ),

                // Oxygen Saturation
                MoodTextfield(
                  labelText: 'Oxygen Saturation',
                  hintText: 'e.g., 98%',
                  controller: _oxygenSaturationController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.opacity),
                ),

                // Weight
                MoodTextfield(
                  labelText: 'Weight',
                  hintText: 'e.g., 70 kg',
                  controller: _weightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.scale),
                ),

                // Height
                MoodTextfield(
                  labelText: 'Height',
                  hintText: 'e.g., 170 cm',
                  controller: _heightController,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  prefixIcon: const Icon(Icons.height),
                ),

                // Clinical Notes
                MoodTextfield(
                  labelText: 'Clinical Notes',
                  hintText: 'Enter additional observations',
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Record Vital Signs',
                  onPressed: _submitForm,
                  state: _submitState,
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
}
