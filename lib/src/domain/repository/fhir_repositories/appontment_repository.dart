import 'dart:developer';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/api_url.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';
import 'package:fhir_demo/src/domain/entities/project_appointment_entities.dart';
import 'package:fhir_demo/src/domain/repository/network/network_calls_repository.dart';
import 'package:fhir_demo/utils/url_launcher_method.dart';
import 'package:fhir_r4/fhir_r4.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appointmentRepositoryProvider = Provider<AppointmentRepository>((ref) {
  final networkCallsRepository = ref.watch(networkCallsRepositoryProvider);
  return AppointmentRepositoryImpl(networkCallsRepository);
});

abstract class AppointmentRepository {
  Future<ApiResponse> createAppointment(ProjectAppointmentEntity appointmentData);
  Future<Map<String, dynamic>?> getAppointmentById(String appointmentId);
  Future<ApiResponse<List<Appointment>>> getAllAppointmentByIdentifier();
  Future<ApiResponse> editAppointmentById({
    required ProjectAppointmentEntity appointmentData,
    required Appointment existingAppointment,
  });
  Future<bool> deleteAppointmentById(String appointmentId);
  Future<List<Map<String, dynamic>>> searchAppointment();
  Future<void> openAppointmentInBrowser(Appointment appointment);
}

class AppointmentRepositoryImpl implements AppointmentRepository {
  final NetworkCallsRepository networkCallsRepository;
  AppointmentRepositoryImpl(this.networkCallsRepository);

  @override
  Future<ApiResponse> createAppointment(ProjectAppointmentEntity appointmentData) async {
    try {
      final response = await networkCallsRepository.post(
        ApiUrl.fhirAppointment.url,
        data: appointmentData.addAppointment(),
      );
      inspect(response);
      if (response.isSuccess) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(
          'Failed to create appointment: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in createAppointment: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<bool> deleteAppointmentById(String appointmentId) async {
    try {
      final response = await networkCallsRepository.delete('${ApiUrl.fhirAppointment.url}/$appointmentId');
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
  Future<ApiResponse> editAppointmentById({
    required ProjectAppointmentEntity appointmentData,
    required Appointment existingAppointment,
  }) async {
    try {
      final response = await networkCallsRepository.put(
        '${ApiUrl.fhirAppointment.url}/${existingAppointment.id}',
        data: appointmentData.addAppointment(existingAppointment: existingAppointment),
      );
      inspect(response);
      if (response.isSuccess) {
        return ApiResponse.success(response);
      } else {
        return ApiResponse.error(
          'Failed to edit appointment: ${response.statusCode} ${response.errorMessage}',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      log('Error in editAppointment: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<Map<String, dynamic>?> getAppointmentById(String appointmentId) async {
    // TODO: implement getAppointmentById
    throw UnimplementedError();
  }

  @override
  Future<List<Map<String, dynamic>>> searchAppointment() async {
    // TODO: implement searchAppointment
    throw UnimplementedError();
  }

  @override
  Future<ApiResponse<List<Appointment>>> getAllAppointmentByIdentifier() async {
    try {
      final response = await networkCallsRepository.get(
        ApiUrl.fhirAppointment.url,
        queryParameters: {'identifier': ApiConstants.projectIdentifier},
      );
      inspect(response.data);
      if (response.isSuccess) {
        final data = response.data as Map<String, dynamic>;
        final appointments = data['entry'] as List<dynamic>? ?? [];
        log('Number of Appointments retrieved: ${appointments.length}');
        final appointmentMaps =
            appointments.map((entry) {
              final link = entry['fullUrl'] as String?;
              final resource = entry['resource'] as Map<String, dynamic>?;
              return {'fullUrl': link, 'resource': resource};
            }).toList();
        final appointmentData =
            appointmentMaps.map((e) {
              final resource = e['resource'] as Map<String, dynamic>;
              final link = e['fullUrl'] as String?;
              final data = Appointment.fromJson(resource);
              final finalData = data.copyWith(basedOn: [Reference(reference: link?.toFhirString)]);
              return finalData;
            }).toList();

        return ApiResponse.success(appointmentData);
      } else {
        return ApiResponse.error('Failed to retrieve appointments: ${response.statusCode} ${response.errorMessage}');
      }
    } catch (e) {
      log('Error in retrieveAppointments: $e');
      return ApiResponse.error(e.toString());
    }
  }

  @override
  Future<void> openAppointmentInBrowser(Appointment appointment) async {
    try {
      final link = appointment.basedOn?.first.reference?.valueString;
      if (link != null) {
        return await UrlLauncherOptions.launchWeb(link, launchModeEXT: kIsWeb);
      } else {
        log('No valid URL found for appointment ${appointment.id}');
        return;
      }
    } catch (e) {
      log('Error opening appointment in browser: $e');
      return;
    }
  }
}
