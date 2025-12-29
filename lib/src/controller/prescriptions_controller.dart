// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:fhir_demo/src/domain/repository/fhir_repositories/prescription_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final prescriptionsController = NotifierProvider.autoDispose<PrescriptionsNotifier, PrescriptionsNotifierState>(
  PrescriptionsNotifier.new,
);

class PrescriptionsNotifier extends AutoDisposeNotifier<PrescriptionsNotifierState> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _patientIdController;
  late TextEditingController _medicationController;
  late TextEditingController _dosageController;
  late TextEditingController _frequencyController;
  late TextEditingController _durationController;
  late TextEditingController _instructionsController;
  late TextEditingController _prescribingDoctorController;
  late TextEditingController _startDateController;
  late PrescriptionRepository _prescriptionRepository;

  @override
  build() {
    _prescriptionRepository = ref.read(prescriptionRepositoryProvider);
    _formKey = GlobalKey<FormState>();
    _patientIdController = TextEditingController();
    _medicationController = TextEditingController();
    _dosageController = TextEditingController();
    _frequencyController = TextEditingController();
    _durationController = TextEditingController();
    _instructionsController = TextEditingController();
    _prescribingDoctorController = TextEditingController();
    _startDateController = TextEditingController();

    return PrescriptionsNotifierState();
  }

  void clearForm() {
    _formKey.currentState?.reset();
    _patientIdController.clear();
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

  void populateFormForEdit(MedicationRequest prescription) {
    // Populate patient ID
    if (prescription.subject.reference?.valueString != null) {
      _patientIdController.text = prescription.subject.reference!.valueString!.split('/').last;
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

  // -------- GETTERS --------
  // -------- GETTERS --------
  GlobalKey<FormState> get formKey => _formKey;
  TextEditingController get patientIdController => _patientIdController;
  TextEditingController get medicationController => _medicationController;
  TextEditingController get dosageController => _dosageController;
  TextEditingController get frequencyController => _frequencyController;
  TextEditingController get durationController => _durationController;
  TextEditingController get instructionsController => _instructionsController;
  TextEditingController get prescribingDoctorController => _prescribingDoctorController;
  TextEditingController get startDateController => _startDateController;
}

class PrescriptionsNotifierState {
  final String? selectedRoute;
  final bool isLoading;

  PrescriptionsNotifierState({this.selectedRoute, this.isLoading = false});

  PrescriptionsNotifierState copyWith({String? selectedRoute, bool? isLoading}) {
    return PrescriptionsNotifierState(
      selectedRoute: selectedRoute ?? this.selectedRoute,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
