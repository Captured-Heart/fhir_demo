import 'dart:developer';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';
import 'package:fhir_demo/src/domain/entities/project_patient_entity.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return PatientRepositoryImpl(networkCallsRepository);
});

abstract class PatientRepository {
  Future<ApiResponse> createPatient(ProjectPatientEntity patientData);
  Future<Map<String, dynamic>?> getPatientById(String patientId);
  Future<ApiResponse<List<Patient>>> getAllPatientsByIdentifier();
  Future<ApiResponse> editPatientById({required ProjectPatientEntity patientData, required Patient existingPatient});
  Future<bool> deletePatientById(String patientId);
  Future<List<Map<String, dynamic>>> searchPatients();
  Future<bool> validatePatientExists(String patientId);
}

class PatientRepositoryImpl implements PatientRepository {
  final NetworkCallsRepository networkCallsRepository;
  PatientRepositoryImpl(this.networkCallsRepository);

  @override
  Future<ApiResponse> createPatient(ProjectPatientEntity patientData) async {
    try {
      final response = await networkCallsRepository.post(ApiUrl.fhirPatient.url, data: patientData.addPatient());
      inspect(response);
      if (response.isSuccess) {
        final data = Patient.fromJson(response.data as Map<String, dynamic>);
        return ApiResponse.success(data);
      } else {
        return ApiResponse.error(
          'Failed to create patient: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in createPatient: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<bool> deletePatientById(String patientId) async {
    try {
      final response = await networkCallsRepository.delete('${ApiUrl.fhirPatient.url}/$patientId');
      log(response.toString());
      if (response.isSuccess) {
        log('i am success');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      log('Error in deletePatientById: $e');
      return false;
    }
  }

  @override
  Future<ApiResponse> editPatientById({
    required ProjectPatientEntity patientData,
    required Patient existingPatient,
  }) async {
    try {
      final response = await networkCallsRepository.put(
        '${ApiUrl.fhirPatient.url}/${existingPatient.id}',
        data: patientData.addPatient(existingPatient: existingPatient),
      );
      inspect(response);
      if (response.isSuccess) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(
          'Failed to create patient: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in createPatient: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getPatientById(String patientId) async {
    // TODO: implement getPatientById
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> searchPatients() async {
    // TODO: implement searchPatients
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<Patient>>> getAllPatientsByIdentifier() async {
    try {
      final response = await networkCallsRepository.get(
        ApiUrl.fhirPatient.url,
        queryParameters: {'identifier': ApiConstants.projectIdentifier},
      );
      inspect(response.data);
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final patients = data['entry'] as List<dynamic>? ?? [];
        log('Number of patients retrieved: ${patients.length}');
        final patientMaps = patients.map((entry) => entry['resource'] as Map<String, dynamic>).toList();
        final patientData = patientMaps.map((e) => Patient.fromJson(e)).toList();

        return ApiResponse.success(patientData);
      } else {
        return ApiResponse.error('Failed to create patient: ${response.statusCode} ${response.errorMessage}');
      }
    } catch (e) {
      log('Error in createPatient: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<bool> validatePatientExists(String patientId) async {
    try {
      final response = await networkCallsRepository.get('${ApiUrl.fhirPatient.url}/$patientId');
      log('[Patient Validation] Checking if Patient/$patientId exists: ${response.isSuccess}');
      return response.isSuccess;
    } catch (e) {
      log('[Patient Validation] Error checking patient existence: $e');
      return false;
    }
  }
}
