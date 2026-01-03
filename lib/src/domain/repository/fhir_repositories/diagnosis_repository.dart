import 'dart:developer';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';
import 'package:fhir_demo/src/domain/entities/project_diagnosis_entity.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final diagnosisRepositoryProvider = Provider<DiagnosisRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return DiagnosisRepositoryImpl(networkCallsRepository);
});

abstract class DiagnosisRepository {
  Future<ApiResponse> createDiagnosis(ProjectDiagosisEntity diagnosisData);
  Future<Map<String, dynamic>?> getDiagnosisById(String diagnosisId);
  Future<ApiResponse<List<DiagnosticReport>>> getAllDiagnosesByIdentifier();
  Future<ApiResponse> editDiagnosisById({
    required ProjectDiagosisEntity diagnosisData,
    required DiagnosticReport existingDiagnosis,
  });
  Future<bool> deleteDiagnosisById(String diagnosisId);
  Future<List<Map<String, dynamic>>> searchDiagnoses();
}

class DiagnosisRepositoryImpl implements DiagnosisRepository {
  final NetworkCallsRepository networkCallsRepository;
  DiagnosisRepositoryImpl(this.networkCallsRepository);

  @override
  Future<ApiResponse> createDiagnosis(ProjectDiagosisEntity diagnosisData) async {
    try {
      final response = await networkCallsRepository.post(
        ApiUrl.fhirDiagnosticReport.url,
        data: diagnosisData.addDiagnosis(),
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
  Future<bool> deleteDiagnosisById(String diagnosisId) async {
    try {
      final response = await networkCallsRepository.delete('${ApiUrl.fhirDiagnosticReport.url}/$diagnosisId');
      log(response.toString());
      if (response.isSuccess) {
        log('i am success');
        return true;
      } else {
        return false;
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ApiResponse> editDiagnosisById({
    required ProjectDiagosisEntity diagnosisData,
    required DiagnosticReport existingDiagnosis,
  }) async {
    try {
      final response = await networkCallsRepository.put(
        '${ApiUrl.fhirDiagnosticReport.url}/${existingDiagnosis.id}',
        data: diagnosisData.addDiagnosis(existingDiagnosis: existingDiagnosis),
      );
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
  Future<Map<String, dynamic>?> getDiagnosisById(String diagnosisId) async {
    // TODO: implement getDiagnosisById
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> searchDiagnoses() async {
    // TODO: implement searchDiagnoses
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<DiagnosticReport>>> getAllDiagnosesByIdentifier() async {
    try {
      final response = await networkCallsRepository.get(
        ApiUrl.fhirDiagnosticReport.url,
        queryParameters: {'identifier': ApiConstants.projectIdentifier},
      );
      inspect(response.data);
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final patients = data['entry'] as List<dynamic>? ?? [];
        log('Number of diagnosis retrieved: ${patients.length}');
        final patientMaps = patients.map((entry) => entry['resource'] as Map<String, dynamic>).toList();
        final diagnosisData = patientMaps.map((e) => DiagnosticReport.fromJson(e)).toList();

        return ApiResponse.success(diagnosisData);
      } else {
        return ApiResponse.error('Failed to create patient: ${response.statusCode} ${response.errorMessage}');
      }
    } catch (e) {
      log('Error in createPatient: $e');
      return ApiResponse.error(e.toString());
    }
  }
}
