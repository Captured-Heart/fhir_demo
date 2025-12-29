import 'package:fhir_demo/src/controller/appointments_controller.dart';
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

class EditAppointmentView extends ConsumerStatefulWidget {
  final Appointment appointment;

  const EditAppointmentView({super.key, required this.appointment});

  @override
  ConsumerState<EditAppointmentView> createState() => _EditAppointmentViewState();
}

class _EditAppointmentViewState extends ConsumerState<EditAppointmentView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appointmentsController.notifier).populateFormForEdit(widget.appointment);
    });
  }

  Future<void> _selectDate() async {
    final controller = ref.read(appointmentsController.notifier);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      controller.appointmentDateController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _selectTime() async {
    final controller = ref.read(appointmentsController.notifier);
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      controller.appointmentTimeController.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(appointmentsController.notifier);
    final state = ref.watch(appointmentsController);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Appointment'),
        backgroundColor: const Color(0xff9C27B0),
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
                  text: 'Edit Appointment Details',
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
                  labelText: 'Doctor *',
                  hintText: 'Enter doctor name',
                  controller: controller.doctorController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.medical_services),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter doctor name';
                    }
                    return null;
                  },
                ),

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
                        border: Border.all(color: AppColors.kGrey.withValues(alpha: 0.3)),
                        borderRadius: AppSpacings.borderRadiusk20All,
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.selectedType,
                          hint: const Text('Select type'),
                          isExpanded: true,
                          items:
                              ['Consultation', 'Follow-up', 'Routine Checkup', 'Emergency', 'Surgery'].map((type) {
                                return DropdownMenuItem(value: type, child: Text(type));
                              }).toList(),
                          onChanged: (value) => controller.setSelectedType(value),
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
                              ['Scheduled', 'Confirmed', 'Arrived', 'In Progress', 'Completed', 'Cancelled'].map((
                                status,
                              ) {
                                return DropdownMenuItem(value: status, child: Text(status));
                              }).toList(),
                          onChanged: (value) => controller.setSelectedStatus(value),
                        ),
                      ),
                    ),
                  ],
                ),

                MoodTextfield(
                  labelText: 'Appointment Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: controller.appointmentDateController,
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

                MoodTextfield(
                  labelText: 'Appointment Time *',
                  hintText: 'HH:MM',
                  controller: controller.appointmentTimeController,
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

                MoodTextfield(
                  labelText: 'Reason for Visit *',
                  hintText: 'Enter reason for appointment',
                  controller: controller.reasonController,
                  textCapitalization: TextCapitalization.sentences,
                  prefixIcon: const Icon(Icons.edit_note),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter reason for visit';
                    }
                    return null;
                  },
                ),

                MoodTextfield(
                  labelText: 'Location',
                  hintText: 'Enter location or clinic name',
                  controller: controller.locationController,
                  textCapitalization: TextCapitalization.words,
                  prefixIcon: const Icon(Icons.location_on),
                ),

                MoodTextfield(
                  labelText: 'Additional Notes',
                  hintText: 'Enter any additional information',
                  controller: controller.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.note_alt),
                ),

                const SizedBox(height: 10),

                MoodPrimaryButton(
                  title: 'Update Appointment',
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Appointment updated successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  state: state.isLoading ? ButtonState.loading : ButtonState.initial,
                  bGcolor: const Color(0xff9C27B0),
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
