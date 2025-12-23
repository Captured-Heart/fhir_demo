// ignore_for_file: public_member_api_docs, sort_constructors_first
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
