import 'dart:developer';

import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/domain/entities/project_patient_entity.dart';
import 'package:fhir_demo/src/domain/repository/fhir_repositories/patient_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientController = NotifierProvider.autoDispose<PatientNotifier, PatientNotifierState>(PatientNotifier.new);

class PatientNotifier extends AutoDisposeNotifier<PatientNotifierState> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _genderController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyContactController;
  late GlobalKey<FormState> _patientFormKey;
  late PatientRepository _patientRepository;
  @override
  build() {
    final user = CacheHelper.currentUser;
    _firstNameController = TextEditingController(text: user?.name.split(' ').first ?? '');
    _lastNameController = TextEditingController(text: user?.name.split(' ').last ?? '');
    _dateOfBirthController = TextEditingController();
    _genderController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController(text: user?.email ?? '');
    _addressController = TextEditingController();
    _emergencyContactController = TextEditingController();
    _patientFormKey = GlobalKey<FormState>();
    _patientRepository = ref.read(patientRepositoryProvider);
    return PatientNotifierState();
  }

  // -------- GETTERS --------
  TextEditingController get firstNameController => _firstNameController;
  TextEditingController get lastNameController => _lastNameController;
  TextEditingController get dateOfBirthController => _dateOfBirthController;
  TextEditingController get genderController => _genderController;
  TextEditingController get phoneController => _phoneController;
  TextEditingController get emailController => _emailController;
  TextEditingController get addressController => _addressController;
  TextEditingController get emergencyContactController => _emergencyContactController;
  GlobalKey<FormState> get patientFormKey => _patientFormKey;

  void clearForm() {
    _patientFormKey.currentState?.reset();
    _firstNameController.clear();
    _lastNameController.clear();
    _dateOfBirthController.clear();
    _genderController.clear();
    _phoneController.clear();
    _emailController.clear();
    _addressController.clear();
    _emergencyContactController.clear();
    state = state.copyWith(selectedGender: null);
  }

  formatBirthDate(DateTime date) {
    _dateOfBirthController.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void updateGender(String? gender) {
    state = state.copyWith(selectedGender: gender);
  }

  // Fetch all patients by identifier
  FutureVoid fetchPatientsByIdentifier() async {
    try {
      ref.invalidateSelf();
      state = state.copyWith(isLoading: true);
      final result = await _patientRepository.getAllPatientsByIdentifier();
      if (result.isSuccess) {
        state = state.copyWith(patientList: result.safeData, isLoading: false);
        // Handle the fetched patients data as needed
      } else {
        log('Failed to fetch patients: ${result.toString()}');
        state = state.copyWith(patientList: [], isLoading: false);
      }
    } catch (e) {
      log('Error fetching patients by identifier: $e');
      state = state.copyWith(patientList: [], isLoading: false);

      // Handle exceptions
    }
  }

  FutureVoid submitForm({
    VoidCallback? onGenderValidationFailed,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    if (_patientFormKey.currentState!.validate()) {
      if (state.selectedGender == null) {
        onGenderValidationFailed?.call();
        return;
      }

      state = state.copyWith(isLoading: true);
      try {
        final result = await _patientRepository.createPatient(
          ProjectPatientEntity(
            id: CacheHelper.currentUser?.id ?? '',
            firstName: _firstNameController.text,
            lastName: _lastNameController.text,
            dateOfBirth: DateTime.parse(_dateOfBirthController.text),
            phoneNumber: _phoneController.text,
            gender: state.selectedGender,
            email: _emailController.text.isNotEmpty ? _emailController.text : '',
            address: _addressController.text.isNotEmpty ? _addressController.text : '',
            emergencyContactNo: _emergencyContactController.text.isNotEmpty ? _emergencyContactController.text : null,
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
}

class PatientNotifierState {
  final bool isLoading;
  final String? selectedGender;
  final List<Patient> patientList;

  PatientNotifierState({this.isLoading = false, this.selectedGender, this.patientList = const []});

  PatientNotifierState copyWith({bool? isLoading, String? selectedGender, List<Patient>? patientList}) {
    return PatientNotifierState(
      isLoading: isLoading ?? this.isLoading,
      selectedGender: selectedGender ?? this.selectedGender,
      patientList: patientList ?? this.patientList,
    );
  }
}
