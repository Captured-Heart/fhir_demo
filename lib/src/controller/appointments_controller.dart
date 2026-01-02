// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/src/domain/entities/project_Appointment_entity.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/appontment_repository.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/patient_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentsController = NotifierProvider.autoDispose<AppointmentsNotifier, AppointmentsNotifierState>(
  AppointmentsNotifier.new,
);

class AppointmentsNotifier extends AutoDisposeNotifier<AppointmentsNotifierState> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _doctorController = TextEditingController();
  final TextEditingController _appointmentDateController = TextEditingController();
  final TextEditingController _appointmentTimeController = TextEditingController();
  final TextEditingController _reasonController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late AppointmentRepository _appointmentRepository;
  late PatientRepository _patientRepository;

  @override
  build() {
    _appointmentRepository = ref.read(appointmentRepositoryProvider);
    _patientRepository = ref.read(patientRepositoryProvider);
    return AppointmentsNotifierState();
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

  void updatePatientId(String value) {
    state = state.copyWith(patientId: value);
  }

  void formatAppointmentDate(DateTime date) {
    _appointmentDateController.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void formatAppointmentTime(TimeOfDay time) {
    _appointmentTimeController.text =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  void deleteFromStateList(String appointmentId) {
    final updatedList =
        state.appointmentsList.where((appointment) => appointment.id?.toString() != appointmentId).toList();
    state = state.copyWith(appointmentsList: updatedList, deleteLoading: false);
  }

  FutureVoid deleteAppointmentById(String appointmentId, {VoidCallback? onSuccess, VoidCallback? onError}) async {
    try {
      state = state.copyWith(deleteLoading: true);
      final result = await _appointmentRepository.deleteAppointmentById(appointmentId);
      // After deletion, refresh the list

      if (result == true) {
        onSuccess?.call();
        deleteFromStateList(appointmentId);
      } else {
        state = state.copyWith(deleteLoading: false);
        onError?.call();
      }
    } catch (e) {
      log('Error deleting diagnosis by id: $e');
      // Handle exceptions
    }
  }

  // Fetch all appointments by identifier
  FutureVoid fetchAppointmentsByIdentifier() async {
    try {
      ref.invalidateSelf();
      state = state.copyWith(isLoading: true);
      final result = await _appointmentRepository.getAllAppointmentByIdentifier();
      if (result.isSuccess) {
        state = state.copyWith(appointmentsList: result.safeData, isLoading: false);
        // Handle the fetched patients data as needed
      } else {
        log('Failed to fetch appointments: ${result.toString()}');
        state = state.copyWith(appointmentsList: [], isLoading: false);
      }
    } catch (e) {
      log('Error fetching appointments by identifier: $e');
      state = state.copyWith(appointmentsList: [], isLoading: false);
      // Handle exceptions
    }
  }

  void populateFormForEdit(Appointment appointment) {
    // Populate patient ID from participants
    if (appointment.participant.isNotEmpty == true) {
      for (var participant in appointment.participant) {
        final reference = participant.actor?.reference?.valueString;
        if (reference != null) {
          if (reference.startsWith('Patient/')) {
            _patientIdController.text = reference.split('/').last;
          }
        } else {
          _doctorController.text = participant.actor?.display?.valueString ?? '';
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

    // location from slot
    if (appointment.slot != null && appointment.slot!.isNotEmpty) {
      _locationController.text = appointment.slot!.first.display?.valueString ?? '';
    }
  }

  FutureVoid submitAppointmentForm({
    VoidCallback? onTypeValidationFailed,
    VoidCallback? onStatusValidationFailed,
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedStatus == null) {
        onStatusValidationFailed?.call();
        return;
      }

      if (state.selectedType == null) {
        onTypeValidationFailed?.call();
        return;
      }

      state = state.copyWith(isLoading: true);
      try {
        final patientId = state.patientId?.removeCharactersFromPatientId ?? '';
        // Validate patient exists before creating diagnosis
        final patientExists = await _patientRepository.validatePatientExists(patientId);
        if (!patientExists) {
          log('[Appointment] Patient/${state.patientId ?? ''} does not exist on server');
          state = state.copyWith(isLoading: false);
          onPatientNotFound?.call();
          return;
        }

        final result = await _appointmentRepository.createAppointment(
          ProjectAppointmentEntity(
            patientId: patientId,
            doctor: _doctorController.text,
            appointmentType: state.selectedType!,
            appointmentDate: DateTime.parse(_appointmentDateController.text),
            appointmentTime: _appointmentTimeController.text,
            status: state.selectedStatus!,
            reasonForVisit: _reasonController.text,
            location: _locationController.text,
            notes: _notesController.text,
          ),
        );

        if (result.isSuccess) {
          log('it was successful');
          clearForm();
          onSuccess?.call();
          return;
        } else {
          onError?.call();
          log('Failed to create patient: ${result.toString()}');
        }
        //
      } catch (e) {
        log('what is the error in patient controller $e');
        // Handle errors here
        state = state.copyWith(isLoading: false);
      } finally {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  FutureVoid editAppointmentForm({
    VoidCallback? onTypeValidationFailed,
    VoidCallback? onStatusValidationFailed,
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    required Appointment existingAppointment,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedType == null) {
        onTypeValidationFailed?.call();
        return;
      }

      if (state.selectedStatus == null) {
        onStatusValidationFailed?.call();
        return;
      }
      state = state.copyWith(isLoading: true);
      try {
        // Validate patient exists before creating diagnosis
        final patientId = state.patientId?.removeCharactersFromPatientId ?? '';

        final patientExists = await _patientRepository.validatePatientExists(patientId);
        if (!patientExists) {
          log('[Diagnosis] Patient/$patientId does not exist on server');
          state = state.copyWith(isLoading: false);
          onPatientNotFound?.call();
          return;
        }

        final result = await _appointmentRepository.editAppointmentById(
          existingAppointment: existingAppointment,
          appointmentData: ProjectAppointmentEntity(
            patientId:
                existingAppointment.participant
                    .where((e) => e.actor?.reference?.startsWith('Patient/') ?? false)
                    .first
                    .actor
                    ?.reference
                    ?.split('/')
                    .last ??
                '',
            doctor: _doctorController.text,
            appointmentType: state.selectedType ?? '',
            appointmentDate: DateTime.parse(_appointmentDateController.text),
            appointmentTime: _appointmentTimeController.text,
            status: state.selectedStatus ?? '',
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            location: _locationController.text.isNotEmpty ? _locationController.text : null,
            reasonForVisit: _reasonController.text,
          ),
        );

        if (result.isSuccess) {
          log('it was successful');
          clearForm();
          onSuccess?.call();
          fetchAppointmentsByIdentifier();
          return;
        } else {
          onError?.call();
          log('Failed to edit diagnosis: ${result.toString()}');
        }
        //
      } catch (e) {
        log('what is the error in diagnosis controller $e');
        // Handle errors here
        state = state.copyWith(isLoading: false);
      } finally {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

class AppointmentsNotifierState {
  final String? selectedType;
  final String? selectedStatus;
  final bool isLoading;
  final bool deleteLoading;
  final String? patientId;
  final List<Appointment> appointmentsList;

  AppointmentsNotifierState({
    this.selectedType,
    this.selectedStatus,
    this.isLoading = false,
    this.deleteLoading = false,
    this.patientId,
    this.appointmentsList = const [],
  });

  AppointmentsNotifierState copyWith({
    String? selectedType,
    String? selectedStatus,
    bool? isLoading,
    bool? deleteLoading,
    String? patientId,
    List<Appointment>? appointmentsList,
  }) {
    return AppointmentsNotifierState(
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
      deleteLoading: deleteLoading ?? this.deleteLoading,
      patientId: patientId ?? this.patientId,
      appointmentsList: appointmentsList ?? this.appointmentsList,
    );
  }
}
