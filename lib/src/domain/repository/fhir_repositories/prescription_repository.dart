import 'dart:developer';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';
import 'package:fhir_demo/src/domain/entities/project_prescription_entity.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final prescriptionRepositoryProvider = Provider<PrescriptionRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return PrescriptionRepositoryImpl(networkCallsRepository);
});

abstract class PrescriptionRepository {
  Future<ApiResponse> createPrescription(ProjectPrescriptionEntity prescriptionData);
  Future<Map<String, dynamic>?> getPrescriptionById(String prescriptionId);
  Future<ApiResponse<List<MedicationRequest>>> getAllPrescriptionByIdentifier();
  Future<ApiResponse> editPrescriptionById({
    required MedicationRequest existingPrescription,
    required ProjectPrescriptionEntity updatedPrescriptionData,
  });
  Future<bool> deletePrescriptionById(String prescriptionId);
  Future<List<Map<String, dynamic>>> searchDiagnoses();
}

class PrescriptionRepositoryImpl implements PrescriptionRepository {
  final NetworkCallsRepository networkCallsRepository;
  PrescriptionRepositoryImpl(this.networkCallsRepository);

  @override
  Future<ApiResponse> createPrescription(ProjectPrescriptionEntity prescriptionData) async {
    try {
      final response = await networkCallsRepository.post(
        ApiUrl.fhirPrescription.url,
        data: prescriptionData.addPrescription(),
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
  Future<bool> deletePrescriptionById(String prescriptionId) async {
    try {
      final response = await networkCallsRepository.delete('${ApiUrl.fhirPrescription.url}/$prescriptionId');
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
  Future<ApiResponse> editPrescriptionById({
    required MedicationRequest existingPrescription,
    required ProjectPrescriptionEntity updatedPrescriptionData,
  }) async {
    try {
      final response = await networkCallsRepository.put(
        '${ApiUrl.fhirPrescription.url}/${existingPrescription.id}',
        data: updatedPrescriptionData.addPrescription(existingPrescription: existingPrescription),
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
  Future<Map<String, dynamic>?> getPrescriptionById(String prescriptionId) async {
    // TODO: implement getPrescriptionById
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> searchDiagnoses() async {
    // TODO: implement searchDiagnoses
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<MedicationRequest>>> getAllPrescriptionByIdentifier() async {
    try {
      final response = await networkCallsRepository.get(
        ApiUrl.fhirPrescription.url,
        queryParameters: {'identifier': ApiConstants.projectIdentifier},
      );
      inspect(response.data);
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final patients = data['entry'] as List<dynamic>? ?? [];
        log('Number of Prescription retrieved: ${patients.length}');
        final patientMaps = patients.map((entry) => entry['resource'] as Map<String, dynamic>).toList();
        final prescriptionData = patientMaps.map((e) => MedicationRequest.fromJson(e)).toList();

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
