// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentsController = NotifierProvider.autoDispose<AppointmentsNotifier, AppointmentsNotifierState>(
  AppointmentsNotifier.new,
);

class AppointmentsNotifier extends AutoDisposeNotifier<AppointmentsNotifierState> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _patientIdController;
  late TextEditingController _doctorController;
  late TextEditingController _appointmentDateController;
  late TextEditingController _appointmentTimeController;
  late TextEditingController _reasonController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;

  @override
  build() {
    _formKey = GlobalKey<FormState>();
    _patientIdController = TextEditingController();
    _doctorController = TextEditingController();
    _appointmentDateController = TextEditingController();
    _appointmentTimeController = TextEditingController();
    _reasonController = TextEditingController();
    _locationController = TextEditingController();
    _notesController = TextEditingController();

    return AppointmentsNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _doctorController.clear();
    _appointmentDateController.clear();
    _appointmentTimeController.clear();
    _reasonController.clear();
    _locationController.clear();
    _notesController.clear();
    state = state.copyWith(selectedType: null, selectedStatus: null);
  }

  void setSelectedType(String? type) {
    state = state.copyWith(selectedType: type);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(selectedStatus: status);
  }

  void populateFormForEdit(Appointment appointment) {
    // Populate patient ID from participants
    if (appointment.participant.isNotEmpty == true) {
      for (var participant in appointment.participant) {
        final reference = participant.actor?.reference?.valueString;
        if (reference != null) {
          if (reference.startsWith('Patient/')) {
            _patientIdController.text = reference.split('/').last;
          } else if (reference.startsWith('Practitioner/')) {
            _doctorController.text = participant.actor?.display?.valueString ?? reference.split('/').last;
          } else if (reference.startsWith('Location/')) {
            _locationController.text = participant.actor?.display?.valueString ?? reference.split('/').last;
          }
        }
      }
    }

    // Populate appointment type
    if (appointment.appointmentType?.text != null) {
      state = state.copyWith(selectedType: appointment.appointmentType!.text!.valueString);
    }

    // Populate status
    if (appointment.status.hasValue) {
      final status = appointment.status.valueString;
      if (status != null && status.isNotEmpty) {
        state = state.copyWith(selectedStatus: status.substring(0, 1).toUpperCase() + status.substring(1));
      }
    }

    // Populate date and time
    if (appointment.start != null) {
      final dateTime = appointment.start!.valueDateTime;
      if (dateTime != null) {
        _appointmentDateController.text = dateTime.toString().split(' ')[0];
        _appointmentTimeController.text = dateTime.toString().split(' ')[1].substring(0, 5);
      }
    }

    // Populate reason
    if (appointment.description != null) {
      _reasonController.text = appointment.description?.valueString ?? '';
    }

    // Populate notes
    if (appointment.comment != null) {
      _notesController.text = appointment.comment?.valueString ?? '';
    }
  }

  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get patientIdController => _patientIdController;
  TextEditingController get doctorController => _doctorController;
  TextEditingController get appointmentDateController => _appointmentDateController;
  TextEditingController get appointmentTimeController => _appointmentTimeController;
  TextEditingController get reasonController => _reasonController;
  TextEditingController get locationController => _locationController;
  TextEditingController get notesController => _notesController;
}

class AppointmentsNotifierState {
  final String? selectedType;
  final String? selectedStatus;
  final bool isLoading;

  AppointmentsNotifierState({this.selectedType, this.selectedStatus, this.isLoading = false});

  AppointmentsNotifierState copyWith({String? selectedType, String? selectedStatus, bool? isLoading}) {
    return AppointmentsNotifierState(
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
