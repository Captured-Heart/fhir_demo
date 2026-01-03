// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/src/domain/entities/project_diagnosis_entity.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/diagnosis_repository.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/patient_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final diagnosisController = NotifierProvider.autoDispose<DiagnosisNotifier, DiagnosisNotifierState>(
  DiagnosisNotifier.new,
);

class DiagnosisNotifier extends AutoDisposeNotifier<DiagnosisNotifierState> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _conditionController = TextEditingController();
  final TextEditingController _severityController = TextEditingController();
  final TextEditingController _onsetDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _diagnosingDoctorController = TextEditingController();
  final TextEditingController patientIdController = TextEditingController();
  late DiagnosisRepository _diagnosisRepository;
  late PatientRepository _patientRepository;
  @override
  build() {
    _diagnosisRepository = ref.read(diagnosisRepositoryProvider);
    _patientRepository = ref.read(patientRepositoryProvider);

    return DiagnosisNotifierState();
  }

  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get conditionController => _conditionController;
  TextEditingController get severityController => _severityController;
  TextEditingController get onsetDateController => _onsetDateController;
  TextEditingController get notesController => _notesController;
  TextEditingController get diagnosingDoctorController => _diagnosingDoctorController;
  TextEditingController get patientIdTextController => patientIdController;

  void clearForm() {
    _formKey.currentState?.reset();
    _conditionController.clear();
    _severityController.clear();
    _onsetDateController.clear();
    _notesController.clear();
    _diagnosingDoctorController.clear();
    state = state.copyWith(selectedSeverity: null, selectedStatus: null);
  }

  void setSelectedSeverity(String? severity) {
    state = state.copyWith(selectedSeverity: severity);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(selectedStatus: status);
  }

  void updatePatientId(String patientId) {
    patientIdController.text = patientId;
    state = state.copyWith(patientId: patientId);
  }

  formatOnsetDate(DateTime date) {
    _onsetDateController.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void populateFormForEdit(DiagnosticReport diagnosis) {
    // Populate patient ID
    if (diagnosis.subject?.reference?.valueString != null) {
      updatePatientId(diagnosis.subject!.reference!.valueString!.split('/').last);
    }

    // Populate condition
    if (diagnosis.code.text != null) {
      _conditionController.text = diagnosis.code.text?.valueString ?? '';
    }

    // Populate status
    if (diagnosis.status.hasValue) {
      final status = diagnosis.status.valueString ?? '';
      state = state.copyWith(selectedStatus: status);
    }

    // Populate notes/conclusion
    if (diagnosis.conclusion != null) {
      setSelectedSeverity(diagnosis.conclusion?.valueString ?? '');
    }

    if (diagnosis.presentedForm != null && diagnosis.presentedForm!.isNotEmpty) {
      final attachment = diagnosis.presentedForm!.first;
      if (attachment.title != null) {
        _notesController.text = attachment.title?.valueString ?? '';
      }
    }

    // Populate diagnosing doctor
    if (diagnosis.performer?.isNotEmpty == true) {
      _diagnosingDoctorController.text = diagnosis.performer!.first.display?.valueString ?? '';
    }

    // Populate onset date
    if (diagnosis.effectiveDateTime != null) {
      _onsetDateController.text = diagnosis.effectiveDateTime!.toString().split(' ')[0];
    }
  }

  // Fetch all patients by identifier
  FutureVoid fetchDiagnosesByIdentifier() async {
    try {
      ref.invalidateSelf();
      state = state.copyWith(isLoading: true);
      final result = await _diagnosisRepository.getAllDiagnosesByIdentifier();
      if (result.isSuccess) {
        state = state.copyWith(diagnosesList: result.safeData, isLoading: false);
        // Handle the fetched patients data as needed
      } else {
        log('Failed to fetch diagnoses: ${result.toString()}');
        state = state.copyWith(diagnosesList: [], isLoading: false);
      }
    } catch (e) {
      log('Error fetching diagnoses by identifier: $e');
      state = state.copyWith(diagnosesList: [], isLoading: false);
      // Handle exceptions
    }
  }

  void deleteFromStateList(String diagnosisId) {
    final updatedList = state.diagnosesList.where((diag) => diag.id?.toString() != diagnosisId).toList();
    state = state.copyWith(diagnosesList: updatedList, deleteLoading: false);
  }

  FutureVoid deleteDiagnosisById(String diagnosisId, {VoidCallback? onSuccess, VoidCallback? onError}) async {
    try {
      state = state.copyWith(deleteLoading: true);
      final result = await _diagnosisRepository.deleteDiagnosisById(diagnosisId);
      // After deletion, refresh the list

      if (result == true) {
        onSuccess?.call();
        deleteFromStateList(diagnosisId);
      } else {
        state = state.copyWith(deleteLoading: false);
        onError?.call();
      }
    } catch (e) {
      log('Error deleting diagnosis by id: $e');
      // Handle exceptions
    }
  }

  FutureVoid submitDiagnosisForm({
    VoidCallback? onSeverityValidationFailed,
    VoidCallback? onStatusValidationFailed,
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedSeverity == null) {
        onSeverityValidationFailed?.call();
        return;
      }

      if (state.selectedStatus == null) {
        onStatusValidationFailed?.call();
        return;
      }

      state = state.copyWith(isLoading: true);
      try {
        final patientId = state.patientId?.removeCharactersFromPatientId ?? '';
        // Validate patient exists before creating diagnosis
        final patientExists = await _patientRepository.validatePatientExists(patientId);
        if (!patientExists) {
          log('[Diagnosis] Patient/${state.patientId ?? ''} does not exist on server');
          state = state.copyWith(isLoading: false);
          onPatientNotFound?.call();
          return;
        }

        final result = await _diagnosisRepository.createDiagnosis(
          ProjectDiagosisEntity(
            patientID: patientId,
            diagnosis: _conditionController.text,
            severity: state.selectedSeverity ?? '',
            clinicalStatus: state.selectedStatus ?? '',
            onsetDate: DateTime.parse(_onsetDateController.text),
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            recorder: _diagnosingDoctorController.text.isNotEmpty ? _diagnosingDoctorController.text : null,
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

  FutureVoid editDiagnosisForm({
    VoidCallback? onSeverityValidationFailed,
    VoidCallback? onStatusValidationFailed,
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    required DiagnosticReport existingDiagnosis,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedSeverity == null) {
        onSeverityValidationFailed?.call();
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

        final result = await _diagnosisRepository.editDiagnosisById(
          diagnosisData: ProjectDiagosisEntity(
            patientID: patientId,
            diagnosis: _conditionController.text,
            severity: state.selectedSeverity ?? '',
            clinicalStatus: state.selectedStatus ?? '',
            onsetDate: DateTime.parse(_onsetDateController.text),
            notes: _notesController.text.isNotEmpty ? _notesController.text : null,
            recorder: _diagnosingDoctorController.text.isNotEmpty ? _diagnosingDoctorController.text : null,
          ),
          existingDiagnosis: existingDiagnosis,
        );

        if (result.isSuccess) {
          log('it was successful');
          clearForm();
          onSuccess?.call();
          fetchDiagnosesByIdentifier();
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

class DiagnosisNotifierState {
  final String? selectedSeverity;
  final String? selectedStatus;
  final String? patientId;
  final bool isLoading;
  final bool deleteLoading;

  final List<DiagnosticReport> diagnosesList;

  DiagnosisNotifierState({
    this.selectedSeverity,
    this.selectedStatus,
    this.patientId,
    this.isLoading = false,

    this.deleteLoading = false,
    this.diagnosesList = const [],
  });

  DiagnosisNotifierState copyWith({
    Object? selectedSeverity = _sentinel,
    Object? selectedStatus = _sentinel,
    String? patientId,
    bool? isLoading,
    bool? deleteLoading,
    List<DiagnosticReport>? diagnosesList,
  }) {
    return DiagnosisNotifierState(
      selectedSeverity: selectedSeverity == _sentinel ? this.selectedSeverity : selectedSeverity as String?,
      selectedStatus: selectedStatus == _sentinel ? this.selectedStatus : selectedStatus as String?,
      isLoading: isLoading ?? this.isLoading,
      deleteLoading: deleteLoading ?? this.deleteLoading,
      diagnosesList: diagnosesList ?? this.diagnosesList,
      patientId: patientId ?? this.patientId,
    );
  }
}

// Sentinel value for copyWith
const Object _sentinel = Object();
