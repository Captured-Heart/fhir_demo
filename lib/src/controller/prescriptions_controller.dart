// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer';

import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/src/domain/entities/project_prescription_entity.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/patient_repository.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/prescription_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final prescriptionsController = NotifierProvider.autoDispose<PrescriptionsNotifier, PrescriptionsNotifierState>(
  PrescriptionsNotifier.new,
);

class PrescriptionsNotifier extends AutoDisposeNotifier<PrescriptionsNotifierState> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _prescribingDoctorController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _patientIdController = TextEditingController();

  late PrescriptionRepository _prescriptionRepository;
  late PatientRepository _patientRepository;

  @override
  build() {
    _prescriptionRepository = ref.read(prescriptionRepositoryProvider);
    _patientRepository = ref.read(patientRepositoryProvider);
    return PrescriptionsNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _medicationController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _durationController.clear();
    _instructionsController.clear();
    _prescribingDoctorController.clear();
    _startDateController.clear();
    state = state.copyWith(selectedRoute: null);
  }

  void setSelectedRoute(String? route) {
    state = state.copyWith(selectedRoute: route);
  }

  formatStartDate(DateTime date) {
    _startDateController.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void updatePatientId(String patientId) {
    state = state.copyWith(patientId: patientId);
    _patientIdController.text = patientId;
  }

  void populateFormForEdit(MedicationRequest prescription) {
    // Populate patient ID
    if (prescription.subject.reference?.valueString != null) {
      updatePatientId(prescription.subject.reference!.valueString!.split('/').last);
    }

    // Populate medication
    if (prescription.medicationCodeableConcept?.text != null) {
      _medicationController.text = prescription.medicationCodeableConcept!.text?.valueString ?? '';
    }

    // Populate dosage, frequency, and route from dosageInstruction
    if (prescription.dosageInstruction?.isNotEmpty == true) {
      final dosage = prescription.dosageInstruction!.first;

      // Dosage
      if (dosage.text != null) {
        _dosageController.text = dosage.text?.valueString ?? '';
      } else if (dosage.doseAndRate?.isNotEmpty == true) {
        final doseQuantity = dosage.doseAndRate!.first.doseQuantity;
        if (doseQuantity?.value?.valueString != null) {
          _dosageController.text = '${doseQuantity!.value!.valueString} ${doseQuantity.unit ?? ''}';
        }
      }

      // Frequency
      if (dosage.timing?.repeat?.frequency?.valueNum != null) {
        _frequencyController.text = dosage.timing!.repeat!.frequency!.valueNum!.toString();
      }

      // Route
      if (dosage.route?.text != null) {
        state = state.copyWith(selectedRoute: dosage.route!.text?.valueString);
      }
    }

    // Populate duration (from dispenseRequest validity period)
    if (prescription.dispenseRequest?.validityPeriod?.end != null) {
      _durationController.text = prescription.dispenseRequest!.validityPeriod!.end.toString();
    }

    // Populate instructions
    if (prescription.dosageInstruction?.isNotEmpty == true &&
        prescription.dosageInstruction!.first.patientInstruction != null) {
      _instructionsController.text = prescription.dosageInstruction!.first.patientInstruction?.valueString ?? '';
    }

    // Populate prescribing doctor
    if (prescription.requester?.display != null) {
      _prescribingDoctorController.text = prescription.requester!.display?.valueString ?? '';
    }

    // Populate start date
    if (prescription.authoredOn != null) {
      _startDateController.text = prescription.authoredOn!.toString().split(' ')[0];
    }
  }

  void _deletePrescriptionFromList(String patientId) {
    final updatedList = state.prescriptionLists.where((patient) => patient.id.toString() != patientId).toList();
    state = state.copyWith(prescriptionLists: updatedList, isDeleteLoading: false);
  }

  FutureVoid deletePrescriptionsById(String patientId, {VoidCallback? onSuccess, VoidCallback? onError}) async {
    try {
      state = state.copyWith(isDeleteLoading: true);
      final result = await _prescriptionRepository.deletePrescriptionById(patientId);
      if (result) {
        _deletePrescriptionFromList(patientId);
        onSuccess?.call();
      } else {
        state = state.copyWith(isDeleteLoading: false);
        onError?.call();
      }
    } catch (e) {
      log('Error deleting prescription by id: $e');
      // Handle exceptions
    }
  }

  // Fetch all patients by identifier
  FutureVoid fetchPrescriptionsByIdentifier() async {
    try {
      ref.invalidateSelf();
      state = state.copyWith(isLoading: true);
      final result = await _prescriptionRepository.getAllPrescriptionByIdentifier();
      if (result.isSuccess) {
        state = state.copyWith(prescriptionLists: result.safeData, isLoading: false);
        // Handle the fetched patients data as needed
      } else {
        log('Failed to fetch prescriptions: ${result.toString()}');
        state = state.copyWith(prescriptionLists: [], isLoading: false);
      }
    } catch (e) {
      log('Error fetching prescriptions by identifier: $e');
      state = state.copyWith(prescriptionLists: [], isLoading: false);

      // Handle exceptions
    }
  }

  FutureVoid submitForm({
    VoidCallback? onRouteofAdminFailed,
    required VoidCallback onPatientNotFound,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedRoute == null) {
        onRouteofAdminFailed?.call();
        return;
      }

      state = state.copyWith(isLoading: true);
      final patientId = state.patientId?.removeCharactersFromPatientId ?? '';

      final patientExists = await _patientRepository.validatePatientExists(patientId);
      if (!patientExists) {
        log('[Diagnosis] Patient/${state.patientId ?? ''} does not exist on server');
        state = state.copyWith(isLoading: false);
        onPatientNotFound.call();
        return;
      }
      try {
        final result = await _prescriptionRepository.createPrescription(
          ProjectPrescriptionEntity(
            patientID: patientId,
            medication: _medicationController.text,
            dosage: _dosageController.text,
            route: state.selectedRoute ?? '',
            frequency: _frequencyController.text,
            startDate:
                _startDateController.text.isNotEmpty ? DateTime.parse(_startDateController.text) : DateTime.now(),
            doctor: _prescribingDoctorController.text,
            duration: _durationController.text.trim(),
            instructions: _instructionsController.text,
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

  FutureVoid editPrescriptionForm({
    required MedicationRequest existingPrescription,
    VoidCallback? onRouteofAdminFailed,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (_formKey.currentState!.validate()) {
      if (state.selectedRoute == null) {
        onRouteofAdminFailed?.call();
        return;
      }
      final patientId = state.patientId?.removeCharactersFromPatientId ?? '';
      state = state.copyWith(isLoading: true);
      try {
        final result = await _prescriptionRepository.editPrescriptionById(
          existingPrescription: existingPrescription,
          updatedPrescriptionData: ProjectPrescriptionEntity(
            patientID: patientId,
            medication: _medicationController.text,
            dosage: _dosageController.text,
            route: state.selectedRoute ?? '',
            frequency: _frequencyController.text,
            startDate:
                _startDateController.text.isNotEmpty ? DateTime.parse(_startDateController.text) : DateTime.now(),
            doctor: _prescribingDoctorController.text,
            duration: _durationController.text.trim(),
            instructions: _instructionsController.text,
          ),
        );

        if (result.isSuccess) {
          log('it was successful');
          clearForm();
          onSuccess?.call();
          fetchPrescriptionsByIdentifier();
          return;
        } else {
          onError?.call();
          log('Failed to create patient: ${result.toString()}');
        }
      } catch (e) {
        log('what is the error in patient controller $e');
        // Handle errors here
        state = state.copyWith(isLoading: false);
      } finally {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get medicationController => _medicationController;
  TextEditingController get dosageController => _dosageController;
  TextEditingController get frequencyController => _frequencyController;
  TextEditingController get durationController => _durationController;
  TextEditingController get instructionsController => _instructionsController;
  TextEditingController get prescribingDoctorController => _prescribingDoctorController;
  TextEditingController get startDateController => _startDateController;
  TextEditingController get patientIdController => _patientIdController;
}

class PrescriptionsNotifierState {
  final String? selectedRoute;
  final bool isLoading;
  final String? patientId;
  final bool isDeleteLoading;
  final List<MedicationRequest> prescriptionLists;

  PrescriptionsNotifierState({
    this.selectedRoute,
    this.isLoading = false,
    this.patientId,
    this.isDeleteLoading = false,
    this.prescriptionLists = const [],
  });

  PrescriptionsNotifierState copyWith({
    String? selectedRoute,
    bool? isLoading,
    String? patientId,
    bool? isDeleteLoading,
    List<MedicationRequest>? prescriptionLists,
  }) {
    return PrescriptionsNotifierState(
      selectedRoute: selectedRoute ?? this.selectedRoute,
      isLoading: isLoading ?? this.isLoading,
      patientId: patientId ?? this.patientId,
      isDeleteLoading: isDeleteLoading ?? this.isDeleteLoading,
      prescriptionLists: prescriptionLists ?? this.prescriptionLists,
    );
  }
}
