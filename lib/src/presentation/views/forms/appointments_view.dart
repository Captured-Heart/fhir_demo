import 'package:fhir_demo/src/controller/appointments_controller.dart';
import 'package:fhir_demo/src/presentation/widgets/dialogs/instruction_dialog.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/app_bar_server_switch.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/patient_id_dropdown.dart';
import 'package:fhir_demo/src/presentation/widgets/shared/selected_server_text.dart';
import 'package:fhir_demo/src/presentation/widgets/textfield/app_drop_down.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';
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

class AppointmentsView extends ConsumerStatefulWidget {
  const AppointmentsView({super.key, this.appointment});
  final Appointment? appointment;

  @override
  ConsumerState<AppointmentsView> createState() => _AppointmentsViewState();
}

class _AppointmentsViewState extends ConsumerState<AppointmentsView> {
  bool get isEdit => widget.appointment != null;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (isEdit && widget.appointment != null) {
        ref.read(appointmentsController.notifier).populateFormForEdit(widget.appointment!);
      }

      if (!isEdit) {
        showInstructionDialog(
          context: context,
          title: 'Appointments',
          subtitle: 'Fill out the form to schedule a new appointment in the system. ',
          sharedKeys: SharedKeys.appointmentInstructionDontShowAgain,
        );
      }
    });
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

  Future<void> _selectTime({Function(TimeOfDay?)? onPicked}) async {
    final TimeOfDay? picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      onPicked?.call(picked);
    }
  }

  void _clearForm() {
    ref.read(appointmentsController.notifier).clearForm();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentCtrl = ref.watch(appointmentsController.notifier);
    final appointmentState = ref.watch(appointmentsController);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Appointment'),
        backgroundColor: const Color(0xff9C27B0),
        foregroundColor: AppColors.kWhite,
        actions: [AppBarServerSwitch()],
      ),
      body: SafeArea(
        child: Form(
          key: appointmentCtrl.formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                SelectedServerText(),
                // Header
                MoodText.text(
                  text: 'Appointment Details',
                  context: context,
                  textStyle: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                // Patient ID
                PatientIdDropdown(
                  onChanged: (patientId) {
                    appointmentCtrl.updatePatientId(patientId);
                  },
                  isEdit: isEdit,
                  patientIdController: appointmentCtrl.patientIdController,
                ),

                // Doctor/Practitioner
                MoodTextfield(
                  labelText: 'Doctor/Practitioner *',
                  hintText: 'Enter doctor name',
                  controller: appointmentCtrl.doctorController,
                  inputFormatters: [],
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
                AppDropDownWidget(
                  value: appointmentState.selectedType,
                  hintText: 'Select type',
                  labelText: 'Appointment Type *',
                  items: ['Routine', 'Follow-up', 'Emergency', 'Consultation', 'Check-up'],
                  onChanged: (value) {
                    appointmentCtrl.setSelectedType(value as String?);
                  },
                ),

                // Appointment Date
                MoodTextfield(
                  labelText: 'Appointment Date *',
                  hintText: 'YYYY-MM-DD',
                  controller: appointmentCtrl.appointmentDateController,
                  readOnly: true,
                  onTap:
                      () => _selectDate(
                        onPicked: (date) {
                          appointmentCtrl.formatAppointmentDate(date!);
                        },
                      ),
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
                  controller: appointmentCtrl.appointmentTimeController,
                  readOnly: true,
                  onTap:
                      () => _selectTime(
                        onPicked: (time) {
                          appointmentCtrl.formatAppointmentTime(time!);
                        },
                      ),
                  suffixIcon: const Icon(Icons.access_time),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select appointment time';
                    }
                    return null;
                  },
                ),

                // Status
                AppDropDownWidget(
                  value: appointmentState.selectedStatus,
                  hintText: 'Select status',
                  labelText: 'Status *',
                  items: ['Proposed', 'Pending', 'Booked', 'Arrived', 'Fulfilled', 'Cancelled'],
                  onChanged: (value) {
                    appointmentCtrl.setSelectedStatus(value as String?);
                  },
                ),

                // Reason for Visit
                MoodTextfield(
                  labelText: 'Reason for Visit *',
                  hintText: 'Enter reason for appointment',
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 2,
                  controller: appointmentCtrl.reasonController,
                  inputFormatters: [],
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
                  controller: appointmentCtrl.locationController,
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [],
                  prefixIcon: const Icon(Icons.location_on),
                ),

                // Additional Notes
                MoodTextfield(
                  labelText: 'Additional Notes',
                  hintText: 'Enter any additional notes',
                  controller: appointmentCtrl.notesController,
                  textCapitalization: TextCapitalization.sentences,
                  inputFormatters: [],
                  maxLines: 3,
                  prefixIcon: const Icon(Icons.notes),
                ),

                const SizedBox(height: 10),

                // Submit Button
                MoodPrimaryButton(
                  title: isEdit ? 'Update Appointment' : 'Schedule Appointment',
                  onPressed:
                      appointmentState.isLoading
                          ? null
                          : () => isEdit ? editForm(appointmentCtrl) : submitForm(appointmentCtrl),
                  state: appointmentState.isLoading ? ButtonState.loading : ButtonState.loaded,
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

  void submitForm(AppointmentsNotifier appointmentCtrl) {
    appointmentCtrl.submitAppointmentForm(
      onTypeValidationFailed: () {
        context.showSnackBar(message: 'Please select an appointment type', isError: true);
      },
      onStatusValidationFailed: () {
        context.showSnackBar(message: 'Please select a clinical status', isError: true);
      },
      onPatientNotFound: () {
        context.showSnackBar(message: 'Patient ID not found. Please create the patient first.', isError: true);
      },
      onSuccess: () {
        Navigator.of(context).pop();
        context.showSnackBar(message: 'Appointment recorded successfully');
      },
      onError: () {
        context.showSnackBar(message: 'Failed to record appointment. Please try again.', isError: true);
      },
    );
  }

  void editForm(AppointmentsNotifier appointmentCtrl) {
    appointmentCtrl.editAppointmentForm(
      existingAppointment: widget.appointment!,
      onTypeValidationFailed: () {
        context.showSnackBar(message: 'Please select an appointment type', isError: true);
      },
      onStatusValidationFailed: () {
        context.showSnackBar(message: 'Please select a clinical status', isError: true);
      },
      onPatientNotFound: () {
        context.showSnackBar(message: 'Patient ID not found. Please create the patient first.', isError: true);
      },
      onSuccess: () {
        Navigator.of(context).pop();
        context.showSnackBar(message: 'Appointment updated successfully');
      },
      onError: () {
        context.showSnackBar(message: 'Failed to update appointment. Please try again.', isError: true);
      },
    );
  }
}
