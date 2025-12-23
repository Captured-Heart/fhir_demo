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
  Future<Map<String, dynamic>?> editPatientById(String patientId);
  Future<Map<String, dynamic>?> deletePatientById(String patientId);
  Future<List<Map<String, dynamic>>> searchPatients();
}

class PatientRepositoryImpl implements PatientRepository {
  final NetworkCallsRepository networkCallsRepository;
  PatientRepositoryImpl(this.networkCallsRepository);

  @override
  Future<ApiResponse> createPatient(ProjectPatientEntity patientData) async {
    try {
      final response = await networkCallsRepository.post(ApiUrl.hapiPatient.url, data: patientData.addPatient());
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
  Future<Map<String, dynamic>?> deletePatientById(String patientId) async {
    // TODO: implement deletePatientById
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> editPatientById(String patientId) async {
    // TODO: implement editPatientById
    throw UnimplementedError();
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
        ApiUrl.hapiPatient.url,
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
}
