// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/src/domain/entities/project_lab_result_entity.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/lab_results_repository.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/patient_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final labResultsController = NotifierProvider.autoDispose<LabResultsNotifier, LabResultsNotifierState>(
  LabResultsNotifier.new,
);

class LabResultsNotifier extends AutoDisposeNotifier<LabResultsNotifierState> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _patientIdController = TextEditingController();
  final TextEditingController _testNameController = TextEditingController();
  final TextEditingController _testCodeController = TextEditingController();
  final TextEditingController _testDateController = TextEditingController();
  final TextEditingController _resultValueController = TextEditingController();
  final TextEditingController _unitController = TextEditingController();
  final TextEditingController _referenceRangeController = TextEditingController();
  final TextEditingController _specimenController = TextEditingController();
  final TextEditingController _performerController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  late LabResultsRepository _labResultsRepository;
  late PatientRepository _patientRepository;

  @override
  build() {
    _labResultsRepository = ref.read(labResultsRepositoryProvider);
    _patientRepository = ref.read(patientRepositoryProvider);
    return LabResultsNotifierState();
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

  formatTestDate(DateTime date) {
    _testDateController.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

  void setSelectedPatientId(String? patientId) {
    state = state.copyWith(patientId: patientId);
  }

  void setSelectedStatus(String? status) {
    state = state.copyWith(selectedStatus: status);
  }

  void populateFormForEdit(DiagnosticReport labResult) {
    inspect(labResult);
    // Populate patient ID
    if (labResult.subject?.reference?.valueString != null) {
      _patientIdController.text = labResult.subject!.reference!.valueString!.split('/').last;
    }

    // interpretation
    if (labResult.conclusionCode != null && labResult.conclusionCode!.isNotEmpty) {
      final interpretation = labResult.conclusionCode!.first.text?.valueString ?? '';
      state = state.copyWith(selectedInterpretation: interpretation);
    }

    // Populate test name and code
    if (labResult.code.coding?.isNotEmpty == true) {
      _testNameController.text = labResult.code.coding?.first.display?.valueString ?? '';
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

    //result value and unit
    if (labResult.result?.isNotEmpty == true) {
      final resultRef = labResult.result!.first.display?.valueString ?? '';
      final parts = resultRef.split(' ');
      if (parts.length >= 2) {
        _resultValueController.text = parts.first;
        _unitController.text = parts.last;
      }
    }

    // Populate reference range
    if (labResult.presentedForm?.isNotEmpty == true) {
      final resultRef = labResult.presentedForm!.first.data?.valueString ?? '';
      _referenceRangeController.text = resultRef;
    }
  }

  // Fetch all patients by identifier
  FutureVoid fetchLabResultsByIdentifier() async {
    try {
      ref.invalidateSelf();
      state = state.copyWith(isLoading: true);
      final result = await _labResultsRepository.getAllLabResultsByIdentifier();
      if (result.isSuccess) {
        state = state.copyWith(labResultsList: result.safeData, isLoading: false);
        // Handle the fetched patients data as needed
      } else {
        log('Failed to fetch lab results: ${result.toString()}');
        state = state.copyWith(labResultsList: [], isLoading: false);
      }
    } catch (e) {
      log('Error fetching lab results by identifier: $e');
      state = state.copyWith(labResultsList: [], isLoading: false);
      // Handle exceptions
    }
  }

  void deleteFromStateList(String labResultId) {
    final updatedList = state.labResultsList.where((diag) => diag.id?.toString() != labResultId).toList();
    state = state.copyWith(labResultsList: updatedList, deleteLoading: false);
  }

  FutureVoid deleteLabResultById(String labResultId, {VoidCallback? onSuccess, VoidCallback? onError}) async {
    try {
      state = state.copyWith(deleteLoading: true);
      final result = await _labResultsRepository.deleteLabResultsById(labResultId);
      // After deletion, refresh the list

      if (result == true) {
        onSuccess?.call();
        deleteFromStateList(labResultId);
      } else {
        state = state.copyWith(deleteLoading: false);
        onError?.call();
      }
    } catch (e) {
      log('Error deleting lab result by id: $e');
      // Handle exceptions
    }
  }

  FutureVoid submitLabResultForm({
    required VoidCallback onInterpretationValidationFailed,
    required VoidCallback onStatusValidationFailed,
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedInterpretation == null) {
        onInterpretationValidationFailed.call();
        return;
      }

      if (state.selectedStatus == null) {
        onStatusValidationFailed.call();
        return;
      }

      state = state.copyWith(isLoading: true);
      try {
        final patientId = state.patientId?.removeCharactersFromPatientId ?? '';
        // Validate patient exists before creating labresults
        final patientExists = await _patientRepository.validatePatientExists(patientId);
        if (!patientExists) {
          log('[LabResults] Patient/${state.patientId ?? ''} does not exist on server');
          state = state.copyWith(isLoading: false);
          onPatientNotFound?.call();
          return;
        }

        final result = await _labResultsRepository.createLabResults(
          ProjectLabResultEntity(
            patientID: patientId,
            testName: _testNameController.text.trim(),
            testCode: _testCodeController.text.trim(),
            testDate: DateTime.parse(_testDateController.text.trim()),
            resultValue: _resultValueController.text.trim(),
            unit: _unitController.text.trim(),
            referenceRange: _referenceRangeController.text.trim(),
            specimenType: _specimenController.text.trim(),
            laboratory: _performerController.text.trim(),
            interpretation: state.selectedInterpretation!,
            status: state.selectedStatus!,
            notes: _notesController.text.trim(),
          ),
        );

        if (result.isSuccess) {
          log('it was successful');
          clearForm();
          onSuccess?.call();
          return;
        } else {
          onError?.call();
          log('Failed to create lab result: ${result.toString()}');
        }
        //
      } catch (e) {
        log('what is the error in lab results controller $e');
        // Handle errors here
        state = state.copyWith(isLoading: false);
      } finally {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  FutureVoid editLabResultForm({
    required VoidCallback onInterpretationValidationFailed,
    required VoidCallback onStatusValidationFailed,
    VoidCallback? onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
    required DiagnosticReport existingLabResult,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedInterpretation == null) {
        onInterpretationValidationFailed.call();
        return;
      }

      if (state.selectedStatus == null) {
        onStatusValidationFailed.call();
        return;
      }
      state = state.copyWith(isLoading: true);
      try {
        // Validate patient exists before creating diagnosis
        final patientId = state.patientId?.removeCharactersFromPatientId ?? '';

        final patientExists = await _patientRepository.validatePatientExists(patientId);
        if (!patientExists) {
          log('[Lab Results] Patient/$patientId does not exist on server');
          state = state.copyWith(isLoading: false);
          onPatientNotFound?.call();
          return;
        }

        final result = await _labResultsRepository.editLabResultsById(
          labResultsData: ProjectLabResultEntity(
            patientID: existingLabResult.subject?.reference?.split('/').last ?? '',
            testName: _testNameController.text.trim(),
            testCode: _testCodeController.text.trim(),
            testDate: DateTime.parse(_testDateController.text.trim()),
            resultValue: _resultValueController.text.trim(),
            unit: _unitController.text.trim(),
            referenceRange: _referenceRangeController.text.trim(),
            specimenType: _specimenController.text.trim(),
            laboratory: _performerController.text.trim(),
            interpretation: state.selectedInterpretation!,
            status: state.selectedStatus!,
            notes: _notesController.text.trim(),
          ),
          existingLabResults: existingLabResult,
        );

        if (result.isSuccess) {
          log('it was successful');
          clearForm();
          onSuccess?.call();
          fetchLabResultsByIdentifier();
          return;
        } else {
          onError?.call();
          log('Failed to edit lab result: ${result.toString()}');
        }
        //
      } catch (e) {
        log('what is the error in lab results controller $e');
        // Handle errors here
        state = state.copyWith(isLoading: false);
      } finally {
        state = state.copyWith(isLoading: false);
      }
    }
  }
}

class LabResultsNotifierState {
  final String? selectedInterpretation;
  final String? selectedStatus;
  final String? patientId;
  final bool isLoading, deleteLoading;
  final List<DiagnosticReport> labResultsList;

  LabResultsNotifierState({
    this.selectedInterpretation,
    this.selectedStatus,
    this.isLoading = false,
    this.patientId,
    this.deleteLoading = false,
    this.labResultsList = const [],
  });

  LabResultsNotifierState copyWith({
    String? selectedInterpretation,
    String? selectedStatus,
    bool? isLoading,
    bool? deleteLoading,
    String? patientId,
    List<DiagnosticReport>? labResultsList,
  }) {
    return LabResultsNotifierState(
      selectedInterpretation: selectedInterpretation ?? this.selectedInterpretation,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      isLoading: isLoading ?? this.isLoading,
      patientId: patientId ?? this.patientId,
      deleteLoading: deleteLoading ?? this.deleteLoading,
      labResultsList: labResultsList ?? this.labResultsList,
    );
  }
}
