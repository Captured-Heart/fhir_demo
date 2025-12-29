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

  void populateFormForEdit(Patient patient) {
    // Populate name fields
    if (patient.name?.isNotEmpty == true) {
      final name = patient.name!.first;
      if (name.given?.isNotEmpty == true) {
        _firstNameController.text = name.given!.first.valueString ?? '';
      }
      if (name.family != null) {
        _lastNameController.text = name.family?.valueString ?? '';
      }
    }

    // Populate birth date
    if (patient.birthDate != null) {
      _dateOfBirthController.text = patient.birthDate!.toString().split(' ')[0];
    }

    // Populate gender
    if (patient.gender != null) {
      final gender = patient.gender!.valueString ?? '';
      _genderController.text = gender;
      state = state.copyWith(selectedGender: gender.substring(0, 1).toUpperCase() + gender.substring(1));
    }

    // Populate contact information
    if (patient.telecom != null && patient.telecom!.isNotEmpty) {
      for (var contact in patient.telecom!) {
        if (contact.system?.valueString == 'phone' && contact.value != null) {
          _phoneController.text = contact.value?.valueString ?? '';
        } else if (contact.system?.valueString == 'email' && contact.value != null) {
          _emailController.text = contact.value?.valueString ?? '';
        } else if (contact.system?.valueString == 'other' && contact.value != null) {
          _emergencyContactController.text = contact.value?.valueString ?? '';
        }
      }
    }

    // Populate address
    if (patient.address?.isNotEmpty == true) {
      final address = patient.address!.first;
      final addressParts = <String>[];
      if (address.line?.isNotEmpty == true) {
        addressParts.addAll(address.line?.map((line) => line.valueString ?? '').toList() ?? []);
      }
      if (address.city != null) addressParts.add(address.city?.valueString ?? '');
      if (address.state != null) addressParts.add(address.state?.valueString ?? '');
      if (address.postalCode != null) addressParts.add(address.postalCode?.valueString ?? '');
      if (address.text != null && address.text!.valueString?.isNotEmpty == true) {
        addressParts.add(address.text!.valueString ?? '');
      }
      _addressController.text = addressParts.join(', ');
    }
  }

  void _deletePatientFromList(String patientId) {
    final updatedList = state.patientList.where((patient) => patient.id.toString() != patientId).toList();
    state = state.copyWith(patientList: updatedList, isDeleteLoading: false);
  }

  FutureVoid deletePatientById(String patientId, {VoidCallback? onSuccess, VoidCallback? onError}) async {
    try {
      state = state.copyWith(isDeleteLoading: true);
      final result = await _patientRepository.deletePatientById(patientId);
      if (result) {
        log('Patient deleted successfully');
        _deletePatientFromList(patientId);
        onSuccess?.call();
      } else {
        log('Failed to delete patient with id: $patientId');
        state = state.copyWith(isDeleteLoading: false);
        onError?.call();
      }
    } catch (e) {
      log('Error deleting patient by id: $e');
      // Handle exceptions
    }
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

  FutureVoid editPatientForm({
    required Patient existingPatient,
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
        final result = await _patientRepository.editPatientById(
          existingPatient: existingPatient,
          patientData: ProjectPatientEntity(
            id: existingPatient.id.toString(),
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
          fetchPatientsByIdentifier();
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
}

class PatientNotifierState {
  final bool isLoading;
  final bool isDeleteLoading;

  final String? selectedGender;
  final List<Patient> patientList;

  PatientNotifierState({
    this.isLoading = false,
    this.isDeleteLoading = false,
    this.selectedGender,
    this.patientList = const [],
  });

  PatientNotifierState copyWith({
    bool? isLoading,
    bool? isDeleteLoading,
    String? selectedGender,
    List<Patient>? patientList,
  }) {
    return PatientNotifierState(
      isLoading: isLoading ?? this.isLoading,
      isDeleteLoading: isDeleteLoading ?? this.isDeleteLoading,
      selectedGender: selectedGender ?? this.selectedGender,
      patientList: patientList ?? this.patientList,
    );
  }
}
