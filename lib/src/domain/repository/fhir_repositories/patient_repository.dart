import 'dart:developer';

import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/project_patient_entity.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_demo/src/domain/repository/results_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return PatientRepositoryImpl(networkCallsRepository);
});

abstract class PatientRepository {
  Future<RepoResult> createPatient(ProjectPatientEntity patientData);
  Future<Map<String, dynamic>?> getPatientById(String patientId);
  Future<Map<String, dynamic>?> editPatientById(String patientId);
  Future<Map<String, dynamic>?> deletePatientById(String patientId);
  Future<List<Map<String, dynamic>>> searchPatients();
}

class PatientRepositoryImpl implements PatientRepository {
  final NetworkCallsRepository networkCallsRepository;
  PatientRepositoryImpl(this.networkCallsRepository);

  @override
  Future<RepoResult> createPatient(ProjectPatientEntity patientData) async {
    try {
      final response = await networkCallsRepository.post(ApiUrl.hapiPatient.url, data: patientData.toMap());
      inspect(response);
      return RepoResult.success(response);
    } catch (e) {
      return RepoResult.error(e.toString());
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
}
