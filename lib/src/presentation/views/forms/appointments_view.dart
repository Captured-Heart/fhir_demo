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

class AppointmentsView extends ConsumerStatefulWidget {
  const AppointmentsView({super.key});

  @override
  ConsumerState<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends ConsumerState<AppointmentsView> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _doctorController = TextEditingController();
  final _appointmentDateController = TextEditingController();
  final _appointmentTimeController = TextEditingController();
  final _reasonController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  ButtonState _submitState = ButtonState.initial;
  String? _selectedType;
  String? _selectedStatus;

  @override
  void dispose() {
    _patientIdController.dispose();
    _doctorController.dispose();
    _appointmentDateController.dispose();
    _appointmentTimeController.dispose();
    _reasonController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _appointmentDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      _appointmentTimeController.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _submitState = ButtonState.loading);

      // TODO: Implement FHIR appointment submission
      await Future.delayed(const Duration(seconds: 2));

      setState(() => _submitState = ButtonState.initial);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Appointment scheduled successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    }
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _doctorController.clear();
    _appointmentDateController.clear();
    _appointmentTimeController.clear();
    _reasonController.clear();
    _locationController.clear();
    _notesController.clear();
    setState(() {
      _selectedType = null;
      _selectedStatus = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: const Color(0xff9C27B0),
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
                  text: 'Appointment Details',
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

                // Doctor/Practitioner
                MoodTextfield(
                  labelText: 'Doctor/Practitioner *',
                  hintText: 'Enter doctor name',
                  controller: _doctorController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.local_hospital),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),

                // Appointment Type
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 8,
                  children: [
                    MoodText.text(
                      text: 'Appointment Type *',
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
                          value: _selectedType,
                          hint: const Text('Select type'),
                          isExpanded: true,
                          items:
                              ['Routine', 'Follow-up', 'Emergency', 'Consultation', 'Check-up'].map((type) {
                                return DropdownMenuItem(value: type, child: Text(type));
                              }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedType = value);
                          },
                        ),
                      ),
                    ),
                  ],
                ),

                // Appointment Date
                MoodTextfield(
                  labelText: 'Appointment Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: _appointmentDateController,
                  readOnly: true,
                  onTap: _selectDate,
                  suffixIcon: const Icon(Icons.calendar_today),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select appointment date';
                    }
                    return null;
                  },
                ),

                // Appointment Time
                MoodTextfield(
                  labelText: 'Appointment Time *',
                  hintText: 'HH:MM',
                  controller: _appointmentTimeController,
                  readOnly: true,
                  onTap: _selectTime,
                  suffixIcon: const Icon(Icons.access_time),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select appointment time';
                    }
                    return null;
                  },
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
                              ['Proposed', 'Pending', 'Booked', 'Arrived', 'Fulfilled', 'Cancelled'].map((status) {
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

                // Reason for Visit
                MoodTextfield(
                  labelText: 'Reason for Visit *',
                  hintText: 'Enter reason for appointment',
                  controller: _reasonController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  prefixIcon: const Icon(Icons.description),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reason for visit';
                    }
                    return null;
                  },
                ),

                // Location
                MoodTextfield(
                  labelText: 'Location',
                  hintText: 'Enter appointment location',
                  controller: _locationController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.location_on),
                ),

                // Additional Notes
                MoodTextfield(
                  labelText: 'Additional Notes',
                  hintText: 'Enter any additional notes',
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: 'Schedule Appointment',
                  onPressed: _submitForm,
                  state: _submitState,
                  bGcolor: const Color(0xff9C27B0),
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
