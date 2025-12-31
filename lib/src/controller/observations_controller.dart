// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fhir_demo/src/domain/entities/project_observation_entity.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final observationsController = NotifierProvider.autoDispose<ObservationsNotifier, ObservationsNotifierState>(
  ObservationsNotifier.new,
);

class ObservationsNotifier extends AutoDisposeNotifier<ObservationsNotifierState> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _bloodPressureController = TextEditingController();
  final TextEditingController _heartRateController = TextEditingController();
  final TextEditingController _temperatureController = TextEditingController();
  final TextEditingController _respiratoryRateController = TextEditingController();
  final TextEditingController _oxygenSaturationController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _observationDateController = TextEditingController();

  @override
  build() {
    return ObservationsNotifierState();
  }

  void clearForm() {
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

  void populateFormForEdit(Observation observation) {
    // Populate patient ID
    if (observation.subject?.reference?.valueString != null) {
      _patientIdController.text = observation.subject!.reference!.valueString!.split('/').last;
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
            if (_bloodPressureController.text.isEmpty) {
              _bloodPressureController.text = value;
            } else {
              _bloodPressureController.text = '${_bloodPressureController.text}/$value';
            }
            break;
          case FhirCodeProjectEnum.heartRate:
            _heartRateController.text = value;
            break;
          case FhirCodeProjectEnum.bodyTemperature:
            _temperatureController.text = value;
            break;
          case FhirCodeProjectEnum.respiratoryRate:
            _respiratoryRateController.text = value;
            break;
          case FhirCodeProjectEnum.oxygenSaturation:
            _oxygenSaturationController.text = value;
            break;
          case FhirCodeProjectEnum.bodyWeight:
            _weightController.text = value;
            break;
          case FhirCodeProjectEnum.bodyHeight:
            _heightController.text = value;
            break;
          case FhirCodeProjectEnum.vitalSignsPanel:
            // Skip the panel itself, only process individual components
            break;
        }
      }
    }

    // Populate notes
    if (observation.note?.isNotEmpty == true) {
      _notesController.text = observation.note!.first.text.valueString ?? '';
    }
  }

  // -------- GETTERS --------
  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get patientIdController => _patientIdController;
  TextEditingController get bloodPressureController => _bloodPressureController;
  TextEditingController get heartRateController => _heartRateController;
  TextEditingController get temperatureController => _temperatureController;
  TextEditingController get respiratoryRateController => _respiratoryRateController;
  TextEditingController get oxygenSaturationController => _oxygenSaturationController;
  TextEditingController get weightController => _weightController;
  TextEditingController get heightController => _heightController;
  TextEditingController get notesController => _notesController;
  TextEditingController get observationDateController => _observationDateController;
}

class ObservationsNotifierState {
  final bool isLoading;

  ObservationsNotifierState({this.isLoading = false});

  ObservationsNotifierState copyWith({bool? isLoading}) {
    return ObservationsNotifierState(isLoading: isLoading ?? this.isLoading);
  }
}
