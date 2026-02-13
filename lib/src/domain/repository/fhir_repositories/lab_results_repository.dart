import 'dart:developer';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';
import 'package:fhir_demo/src/domain/entities/project_lab_result_entity.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_demo/utils/url_launcher_method.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final labResultsRepositoryProvider = Provider<LabResultsRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return LabResultsRepositoryImpl(networkCallsRepository);
});

abstract class LabResultsRepository {
  Future<ApiResponse> createLabResults(ProjectLabResultEntity labResultsData);
  Future<Map<String, dynamic>?> getLabResultsById(String labResultsId);
  Future<ApiResponse<List<DiagnosticReport>>> getAllLabResultsByIdentifier();
  Future<ApiResponse> editLabResultsById({
    required ProjectLabResultEntity labResultsData,
    required DiagnosticReport existingLabResults,
  });
  Future<bool> deleteLabResultsById(String labResultsId);
  Future<List<Map<String, dynamic>>> searchLabResults();
  Future<void> openLabResultsInBrowser(DiagnosticReport labResults);
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
          'Failed to create lab result: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in createLabResult: $e');
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
  Future<ApiResponse> editLabResultsById({
    required ProjectLabResultEntity labResultsData,
    required DiagnosticReport existingLabResults,
  }) async {
    try {
      final response = await networkCallsRepository.put(
        '${ApiUrl.fhirLabResult.url}/${existingLabResults.id}',
        data: labResultsData.addLabResult(existingLabResult: existingLabResults),
      );
      if (response.isSuccess) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(
          'Failed to create lab result: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in createLabResult: $e');
      return ApiResponse.error(e.toString());
    }
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
        queryParameters: {'identifier': ApiConstants.projectIdentifierLabResult},
      );
      inspect(response.data);
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final patients = data['entry'] as List<dynamic>? ?? [];
        log('Number of Prescription retrieved: ${patients.length}');
        final patientMaps =
            patients.map((entry) {
              final link = entry['fullUrl'] as String?;
              final resource = entry['resource'] as Map<String, dynamic>?;
              return {'fullUrl': link, 'resource': resource};
            }).toList();

        //
        final prescriptionData =
            patientMaps.map((e) {
              final resource = e['resource'] as Map<String, dynamic>;
              final link = e['fullUrl'] as String?;
              final data = DiagnosticReport.fromJson(resource);
              final finalData = data.copyWith(basedOn: [Reference(reference: FhirString(link ?? ''))]);
              return finalData;
            }).toList();

        return ApiResponse.success(prescriptionData);
      } else {
        return ApiResponse.error('Failed to create lab result: ${response.statusCode} ${response.errorMessage}');
      }
    } catch (e) {
      log('Error in createLabResult: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<void> openLabResultsInBrowser(DiagnosticReport labResults) async {
    try {
      final link = labResults.basedOn?.first.reference?.valueString;
      if (link != null) {
        return await UrlLauncherOptions.launchWeb(link, launchModeEXT: kIsWeb);
      } else {
        log('No valid URL found for patient ${labResults.id}');
        return;
      }
    } catch (e) {
      log('Error opening patient in browser: $e');
      return;
    }
  }
}
