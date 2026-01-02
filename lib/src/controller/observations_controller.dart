// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/src/domain/entities/project_observation_entity.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/observation_repository.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/patient_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final observationsController = NotifierProvider.autoDispose<ObservationsNotifier, ObservationsNotifierState>(
  ObservationsNotifier.new,
);

class ObservationsNotifier extends AutoDisposeNotifier<ObservationsNotifierState> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _respiratoryRateController = TextEditingController();
  final TextEditingController _oxygenSaturationController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _observationDateController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();

  late ObservationRepository _observationRepository;
  late PatientRepository _patientRepository;

  @override
  build() {
    _observationRepository = ref.read(observationRepositoryProvider);
    _patientRepository = ref.read(patientRepositoryProvider);
    return ObservationsNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _bloodPressureController.clear();
    _heartRateController.clear();
    _temperatureController.clear();
    _respiratoryRateController.clear();
    _oxygenSaturationController.clear();
    _weightController.clear();
    _heightController.clear();
    _notesController.clear();
    _observationDateController.clear();
    patientIdController.clear();
  }

  formatObservationDate(DateTime date) {
    _observationDateController.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Fetch all patients by identifier
  FutureVoid fetchObservationByIdentifier() async {
    try {
      ref.invalidateSelf();
      state = state.copyWith(isLoading: true);
      final result = await _observationRepository.getAllObservationByIdentifier();
      if (result.isSuccess) {
        state = state.copyWith(observationsList: result.safeData, isLoading: false);
        // Handle the fetched patients data as needed
      } else {
        log('Failed to fetch diagnoses: ${result.toString()}');
        state = state.copyWith(observationsList: [], isLoading: false);
      }
    } catch (e) {
      log('Error fetching diagnoses by identifier: $e');
      state = state.copyWith(observationsList: [], isLoading: false);
      // Handle exceptions
    }
  }

  void updatePatientId(String? patientId) {
    state = state.copyWith(patientId: patientId);
    _patientIdController.text = patientId ?? '';
  }

  void populateFormForEdit(Observation observation) {
    clearForm();
    // Populate patient ID
    if (observation.subject?.reference?.valueString != null) {
      updatePatientId(observation.subject!.reference!.valueString!.split('/').last);
    }

    // Populate observation date
    if (observation.effectiveDateTime != null) {
      _observationDateController.text = observation.effectiveDateTime!.toString().split(' ')[0];
    }

    // Populate vital signs from components
    if (observation.component?.isNotEmpty == true) {
      for (var component in observation.component!) {
        final code = FhirCodeProjectEnum.fromCode(component.code.coding?.first.code?.valueString ?? '');
        final value = component.valueQuantity?.value?.valueString ?? '';

        switch (code) {
          case FhirCodeProjectEnum.systolicBloodPressure:
          case FhirCodeProjectEnum.diastolicBloodPressure:
          case FhirCodeProjectEnum.systolicBloodPressure:
          case FhirCodeProjectEnum.diastolicBloodPressure:
            if (_bloodPressureController.text.isEmpty) {
              _bloodPressureController.text = value;
            } else {
              _bloodPressureController.text = '${_bloodPressureController.text}/$value';
            }
            break;
          case FhirCodeProjectEnum.heartRate:
          case FhirCodeProjectEnum.heartRate:
            _heartRateController.text = value;
            break;
          case FhirCodeProjectEnum.bodyTemperature:
          case FhirCodeProjectEnum.bodyTemperature:
            _temperatureController.text = value;
            break;
          case FhirCodeProjectEnum.respiratoryRate:
          case FhirCodeProjectEnum.respiratoryRate:
            _respiratoryRateController.text = value;
            break;
          case FhirCodeProjectEnum.oxygenSaturation:
          case FhirCodeProjectEnum.oxygenSaturation:
            _oxygenSaturationController.text = value;
            break;
          case FhirCodeProjectEnum.bodyWeight:
          case FhirCodeProjectEnum.bodyWeight:
            _weightController.text = value;
            break;
          case FhirCodeProjectEnum.bodyHeight:
          case FhirCodeProjectEnum.bodyHeight:
            _heightController.text = value;
            break;
          case FhirCodeProjectEnum.vitalSignsPanel:
            break;
        }
      }
    }

    // Populate notes
    if (observation.note?.isNotEmpty == true) {
      _notesController.text = observation.note!.first.text.valueString ?? '';
    }
  }

  void deleteFromStateList(String observationId) {
    final updatedList = state.observationsList.where((obs) => obs.id?.toString() != observationId).toList();
    state = state.copyWith(observationsList: updatedList, deleteLoading: false);
  }

  FutureVoid deleteObservationById(String observationId, {VoidCallback? onSuccess, VoidCallback? onError}) async {
    try {
      state = state.copyWith(deleteLoading: true);
      final result = await _observationRepository.deleteObservationById(observationId);
      // After deletion, refresh the list

      if (result == true) {
        onSuccess?.call();
        deleteFromStateList(observationId);
      } else {
        state = state.copyWith(deleteLoading: false);
        onError?.call();
      }
    } catch (e) {
      log('Error deleting observation by id: $e');
      // Handle exceptions
    }
  }

  FutureVoid submitObservationForm({
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (_formKey.currentState!.validate()) {
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

        final result = await _observationRepository.createObservation(
          ProjectObservationEntity(
            patientId: patientId,
            observationDate: DateTime.parse(_observationDateController.text),
            systolicBloodPressure:
                _bloodPressureController.text.isNotEmptyOrNull ? _bloodPressureController.text.split('/').first : null,
            diastolicBloodPressure:
                _bloodPressureController.text.isNotEmptyOrNull ? _bloodPressureController.text.split('/').last : null,
            heartRate: _heartRateController.text.isNotEmptyOrNull ? _heartRateController.text : null,
            temperature: num.tryParse(_temperatureController.text),
            respiratoryRate: _respiratoryRateController.text.isNotEmptyOrNull ? _respiratoryRateController.text : null,
            oxygenSaturation: num.tryParse(_oxygenSaturationController.text),
            weight: num.tryParse(_weightController.text),
            height: num.tryParse(_heightController.text),
            clinicalNotes: _notesController.text.isNotEmptyOrNull ? _notesController.text : null,
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

  FutureVoid editObservationForm({
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    required Observation existingObservation,
  }) async {
    if (_formKey.currentState!.validate()) {
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

        final result = await _observationRepository.editObservationById(
          existingObservation: existingObservation,
          observationData: ProjectObservationEntity(
            patientId: patientId,
            observationDate: DateTime.parse(_observationDateController.text),
            systolicBloodPressure: _bloodPressureController.text.split('/').first,
            diastolicBloodPressure: _bloodPressureController.text.split('/').last,
            heartRate: _heartRateController.text,
            temperature: num.parse(_temperatureController.text),
            respiratoryRate: _respiratoryRateController.text,
            oxygenSaturation: num.parse(_oxygenSaturationController.text),
            weight: num.parse(_weightController.text),
            height: num.parse(_heightController.text),
            clinicalNotes: _notesController.text,
          ),
        );

        if (result.isSuccess) {
          log('it was successful');
          clearForm();
          onSuccess?.call();
          fetchObservationByIdentifier();
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

  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get bloodPressureController => _bloodPressureController;
  TextEditingController get heartRateController => _heartRateController;
  TextEditingController get temperatureController => _temperatureController;
  TextEditingController get respiratoryRateController => _respiratoryRateController;
  TextEditingController get oxygenSaturationController => _oxygenSaturationController;
  TextEditingController get weightController => _weightController;
  TextEditingController get heightController => _heightController;
  TextEditingController get notesController => _notesController;
  TextEditingController get observationDateController => _observationDateController;
  TextEditingController get patientIdController => _patientIdController;
}

class ObservationsNotifierState {
  final String? patientId;
  final bool isLoading;
  final bool deleteLoading;
  final List<Observation> observationsList;

  ObservationsNotifierState({
    this.isLoading = false,
    this.deleteLoading = false,
    this.patientId,
    this.observationsList = const [],
  });

  ObservationsNotifierState copyWith({
    bool? isLoading,
    bool? deleteLoading,
    String? patientId,
    List<Observation>? observationsList,
  }) {
    return ObservationsNotifierState(
      isLoading: isLoading ?? this.isLoading,
      deleteLoading: deleteLoading ?? this.deleteLoading,
      patientId: patientId ?? this.patientId,
      observationsList: observationsList ?? this.observationsList,
    );
  }
}
