// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final labResultsController = NotifierProvider.autoDispose<LabResultsNotifier, LabResultsNotifierState>(
  LabResultsNotifier.new,
);

class LabResultsNotifier extends AutoDisposeNotifier<LabResultsNotifierState> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _patientIdController;
  late TextEditingController _testNameController;
  late TextEditingController _testCodeController;
  late TextEditingController _testDateController;
  late TextEditingController _resultValueController;
  late TextEditingController _unitController;
  late TextEditingController _referenceRangeController;
  late TextEditingController _specimenController;
  late TextEditingController _performerController;
  late TextEditingController _notesController;

  @override
  build() {
    _formKey = GlobalKey<FormState>();
    _patientIdController = TextEditingController();
    _testNameController = TextEditingController();
    _testCodeController = TextEditingController();
    _testDateController = TextEditingController();
    _resultValueController = TextEditingController();
    _unitController = TextEditingController();
    _referenceRangeController = TextEditingController();
    _specimenController = TextEditingController();
    _performerController = TextEditingController();
    _notesController = TextEditingController();

    return LabResultsNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
    _testNameController.clear();
    _testCodeController.clear();
    _testDateController.clear();
    _resultValueController.clear();
    _unitController.clear();
    _referenceRangeController.clear();
    _specimenController.clear();
    _performerController.clear();
    _notesController.clear();
    state = state.copyWith(selectedInterpretation: null, selectedStatus: null);
  }

  void setSelectedInterpretation(String? interpretation) {
    state = state.copyWith(selectedInterpretation: interpretation);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(selectedStatus: status);
  }

  void populateFormForEdit(DiagnosticReport labResult) {
    // Populate patient ID
    if (labResult.subject?.reference?.valueString != null) {
      _patientIdController.text = labResult.subject!.reference!.valueString!.split('/').last;
    }

    // Populate test name and code
    if (labResult.code.text != null) {
      _testNameController.text = labResult.code.text?.valueString ?? '';
    }
    if (labResult.code.coding?.isNotEmpty == true) {
      _testCodeController.text = labResult.code.coding!.first.code?.valueString ?? '';
    }

    // Populate test date
    if (labResult.effectiveDateTime != null) {
      _testDateController.text = labResult.effectiveDateTime!.toString().split(' ')[0];
    }

    // Populate status
    if (labResult.status.hasValue) {
      final status = labResult.status.valueString ?? '';
      state = state.copyWith(selectedStatus: status.substring(0, 1).toUpperCase() + status.substring(1));
    }

    // Populate performer
    if (labResult.performer?.isNotEmpty == true) {
      _performerController.text = labResult.performer!.first.display?.valueString ?? '';
    }

    // Populate specimen
    if (labResult.specimen?.isNotEmpty == true) {
      _specimenController.text = labResult.specimen!.first.display?.valueString ?? '';
    }

    // Populate notes/conclusion
    if (labResult.conclusion != null) {
      _notesController.text = labResult.conclusion?.valueString ?? '';
    }

    // Note: Result values, unit, reference range, and interpretation
    // typically come from Observation resources referenced in labResult.result
    // For now, leaving these empty as they require additional API calls
  }

  // -------- GETTERS --------
  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get patientIdController => _patientIdController;
  TextEditingController get testNameController => _testNameController;
  TextEditingController get testCodeController => _testCodeController;
  TextEditingController get testDateController => _testDateController;
  TextEditingController get resultValueController => _resultValueController;
  TextEditingController get unitController => _unitController;
  TextEditingController get referenceRangeController => _referenceRangeController;
  TextEditingController get specimenController => _specimenController;
  TextEditingController get performerController => _performerController;
  TextEditingController get notesController => _notesController;
}

class LabResultsNotifierState {
  final String? selectedInterpretation;
  final String? selectedStatus;
  final bool isLoading;

  LabResultsNotifierState({this.selectedInterpretation, this.selectedStatus, this.isLoading = false});

  LabResultsNotifierState copyWith({String? selectedInterpretation, String? selectedStatus, bool? isLoading}) {
    return LabResultsNotifierState(
      selectedInterpretation: selectedInterpretation ?? this.selectedInterpretation,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
