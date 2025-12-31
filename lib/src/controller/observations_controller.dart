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
          case '8480-6': // Systolic BP
          case '8462-4': // Diastolic BP
            if (_bloodPressureController.text.isEmpty) {
              _bloodPressureController.text = value;
            } else {
              _bloodPressureController.text = '${_bloodPressureController.text}/$value';
            }
            break;
          case '8867-4': // Heart rate
            _heartRateController.text = value;
            break;
          case '8310-5': // Body temperature
            _temperatureController.text = value;
            break;
          case '9279-1': // Respiratory rate
            _respiratoryRateController.text = value;
            break;
          case '2708-6': // Oxygen saturation
            _oxygenSaturationController.text = value;
            break;
          case '29463-7': // Body weight
            _weightController.text = value;
            break;
          case '8302-2': // Body height
            _heightController.text = value;
            break;
          case FhirCodeProjectEnum.vitalSignsPanel:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.systolicBloodPressure:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.diastolicBloodPressure:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.heartRate:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.bodyTemperature:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.respiratoryRate:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.oxygenSaturation:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.bodyWeight:
            // TODO: Handle this case.
            throw UnimplementedError();
          case FhirCodeProjectEnum.bodyHeight:
            // TODO: Handle this case.
            throw UnimplementedError();
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
