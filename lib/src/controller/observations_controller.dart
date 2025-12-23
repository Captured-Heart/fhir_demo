// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final observationsController = NotifierProvider.autoDispose<ObservationsNotifier, ObservationsNotifierState>(
  ObservationsNotifier.new,
);

class ObservationsNotifier extends AutoDisposeNotifier<ObservationsNotifierState> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _patientIdController;
  late TextEditingController _bloodPressureController;
  late TextEditingController _heartRateController;
  late TextEditingController _temperatureController;
  late TextEditingController _respiratoryRateController;
  late TextEditingController _oxygenSaturationController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _notesController;
  late TextEditingController _observationDateController;

  @override
  build() {
    _formKey = GlobalKey<FormState>();
    _patientIdController = TextEditingController();
    _bloodPressureController = TextEditingController();
    _heartRateController = TextEditingController();
    _temperatureController = TextEditingController();
    _respiratoryRateController = TextEditingController();
    _oxygenSaturationController = TextEditingController();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _notesController = TextEditingController();
    _observationDateController = TextEditingController();

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
