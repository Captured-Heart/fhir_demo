import 'dart:developer';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';
import 'package:fhir_demo/src/domain/entities/project_lab_result_entity.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final labResultsRepositoryProvider = Provider<LabResultsRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return LabResultsRepositoryImpl(networkCallsRepository);
});

abstract class LabResultsRepository {
  Future<ApiResponse> createLabResults(ProjectLabResultEntity labResultsData);
  Future<Map<String, dynamic>?> getLabResultsById(String labResultsId);
  Future<ApiResponse<List<DiagnosticReport>>> getAllLabResultsByIdentifier();
  Future<Map<String, dynamic>?> editLabResultsById(String labResultsId);
  Future<bool> deleteLabResultsById(String labResultsId);
  Future<List<Map<String, dynamic>>> searchLabResults();
}

class LabResultsRepositoryImpl implements LabResultsRepository {
  final NetworkCallsRepository networkCallsRepository;
  LabResultsRepositoryImpl(this.networkCallsRepository);

  @override
  Future<ApiResponse> createLabResults(ProjectLabResultEntity labResultsData) async {
    try {
      final response = await networkCallsRepository.post(ApiUrl.fhirLabResult.url, data: labResultsData.addLabResult());
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
  Future<bool> deleteLabResultsById(String labResultsId) async {
    try {
      final response = await networkCallsRepository.delete('${ApiUrl.fhirLabResult.url}/$labResultsId');
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
  Future<Map<String, dynamic>?> editLabResultsById(String labResultsId) async {
    // TODO: implement editLabResultsById
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>?> getLabResultsById(String labResultsId) async {
    // TODO: implement getLabResultsById
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> searchLabResults() async {
    // TODO: implement searchLabResults
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<DiagnosticReport>>> getAllLabResultsByIdentifier() async {
    try {
      final response = await networkCallsRepository.get(
        ApiUrl.fhirLabResult.url,
        queryParameters: {'identifier': ApiConstants.projectIdentifier},
      );
      inspect(response.data);
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final patients = data['entry'] as List<dynamic>? ?? [];
        log('Number of Prescription retrieved: ${patients.length}');
        final patientMaps = patients.map((entry) => entry['resource'] as Map<String, dynamic>).toList();
        final prescriptionData = patientMaps.map((e) => DiagnosticReport.fromJson(e)).toList();

        return ApiResponse.success(prescriptionData);
      } else {
        return ApiResponse.error('Failed to create patient: ${response.statusCode} ${response.errorMessage}');
      }
    } catch (e) {
      log('Error in createPatient: $e');
      return ApiResponse.error(e.toString());
    }
  }
}
