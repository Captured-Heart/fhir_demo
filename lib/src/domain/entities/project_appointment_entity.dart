import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart';

class ProjectAppointmentEntity {
  final String patientId;
  final String doctor;
  final String appointmentType;
  final DateTime appointmentDate;
  final String appointmentTime;
  final String status;
  final String reasonForVisit;
  final String? location;
  final String? notes;

  ProjectAppointmentEntity({
    required this.patientId,
    required this.doctor,
    required this.appointmentType,
    required this.appointmentDate,
    required this.appointmentTime,
    required this.status,
    required this.reasonForVisit,
    this.location,
    this.notes,
  });

  MapStringDynamic addAppointment() {
    final body = Appointment(
      status: AppointmentStatus.values.firstWhere(
        (e) => e.valueString?.toLowerCase() == status.toLowerCase(),
        orElse: () => AppointmentStatus.cancelled,
      ),
      participant: [
        AppointmentParticipant(
          actor: Reference(reference: 'Patient/$patientId'.toFhirString),
          status: ParticipationStatus.accepted,
        ),
        AppointmentParticipant(
          actor: Reference(reference: 'Practitioner/$doctor'.toFhirString),
          status: ParticipationStatus.accepted,
        ),
      ],
      appointmentType: CodeableConcept(text: appointmentType.toFhirString),
      start: appointmentDate.toFhirInstant,
      end: appointmentDate.add(const Duration(hours: 1)).toFhirInstant,
      description: reasonForVisit.toFhirString,
      comment: notes?.toFhirString,
      slot: location != null ? [Reference(display: location?.toFhirString)] : null,
    );
    return body.toJson();
  }
}
