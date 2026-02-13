import 'dart:developer';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';
import 'package:fhir_demo/src/domain/entities/project_observation_entity.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_demo/utils/url_launcher_method.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final observationRepositoryProvider = Provider<ObservationRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return ObservationRepositoryImpl(networkCallsRepository);
});

abstract class ObservationRepository {
  Future<ApiResponse> createObservation(ProjectObservationEntity observationData);
  Future<Map<String, dynamic>?> getObservationById(String observationId);
  Future<ApiResponse<List<Observation>>> getAllObservationByIdentifier();
  Future<ApiResponse> editObservationById({
    required ProjectObservationEntity observationData,
    required Observation existingObservation,
  });
  Future<bool> deleteObservationById(String observationId);
  Future<List<Map<String, dynamic>>> searchObservation();
  Future<void> openObservationInBrowser(Observation observation);
}

class ObservationRepositoryImpl implements ObservationRepository {
  final NetworkCallsRepository networkCallsRepository;
  ObservationRepositoryImpl(this.networkCallsRepository);

  @override
  Future<ApiResponse> createObservation(ProjectObservationEntity observationData) async {
    try {
      final response = await networkCallsRepository.post(
        ApiUrl.fhirObservation.url,
        data: observationData.addObservation(),
      );
      inspect(response);
      if (response.isSuccess) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(
          'Failed to create Observation: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in createObservation: $e');
      inspect(e);

      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<bool> deleteObservationById(String observationId) async {
    try {
      final response = await networkCallsRepository.delete('${ApiUrl.fhirObservation.url}/$observationId');
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
  Future<ApiResponse> editObservationById({
    required ProjectObservationEntity observationData,
    required Observation existingObservation,
  }) async {
    try {
      final response = await networkCallsRepository.put(
        '${ApiUrl.fhirObservation.url}/${existingObservation.id}',
        data: observationData.addObservation(existingObservation: existingObservation),
      );
      if (response.isSuccess) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(
          'Failed to create Observation: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in createObservation: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getObservationById(String observationId) async {
    // TODO: implement getObservationById
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> searchObservation() async {
    // TODO: implement searchObservation
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<Observation>>> getAllObservationByIdentifier() async {
    try {
      final response = await networkCallsRepository.get(
        ApiUrl.fhirObservation.url,
        queryParameters: {'identifier': ApiConstants.projectIdentifier},
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
        final prescriptionData =
            patientMaps.map((e) {
              final resource = e['resource'] as Map<String, dynamic>;
              final link = e['fullUrl'] as String?;
              final data = Observation.fromJson(resource);
              final finalData = data.copyWith(basedOn: [Reference(reference: link != null ? FhirString(link) : null)]);
              return finalData;
            }).toList();

        return ApiResponse.success(prescriptionData);
      } else {
        return ApiResponse.error('Failed to create Observation: ${response.statusCode} ${response.errorMessage}');
      }
    } catch (e) {
      log('Error in createObservation: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<void> openObservationInBrowser(Observation observation) async {
    try {
      final link = observation.basedOn?.first.reference?.valueString;
      if (link != null) {
        return await UrlLauncherOptions.launchWeb(link, launchModeEXT: kIsWeb);
      } else {
        log('No valid URL found for patient ${observation.id}');
        return;
      }
    } catch (e) {
      log('Error opening patient in browser: $e');
      return;
    }
  }
}
