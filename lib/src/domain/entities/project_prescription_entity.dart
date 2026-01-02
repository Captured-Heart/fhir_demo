import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart';

class ProjectPrescriptionEntity {
  // patientID, medication, dosage, frequency, startDate, endDate, notes, prescriber
  final String patientID;
  final String medication;
  final String dosage;
  final String route;
  final String frequency;
  final DateTime startDate;
  final String duration;
  final String doctor;
  final String? instructions;

  ProjectPrescriptionEntity({
    required this.patientID,
    required this.medication,
    required this.dosage,
    required this.route,
    required this.frequency,
    required this.startDate,
    required this.doctor,
    required this.duration,
    this.instructions,
  });

  MapStringDynamic addPrescription({MedicationRequest? existingPrescription}) {
    final body = MedicationRequest(
      status: MedicationrequestStatus.active,
      intent: MedicationRequestIntent.order,
      medicationX: CodeableConcept(text: medication.toFhirString),
      subject: Reference(reference: 'Patient/$patientID'.toFhirString),
      dosageInstruction: [
        Dosage(
          text: instructions?.toFhirString,
          route: CodeableConcept(text: route.toFhirString),
          doseAndRate: [DosageDoseAndRate(doseQuantity: Quantity(value: FhirDecimal(dosage), unit: 'mg'.toFhirString))],
          timing: Timing(
            repeat: TimingRepeat(
              frequency: FhirPositiveInt(int.tryParse(frequency)),
              duration: FhirDecimal(duration),
              durationUnit: UnitsOfTime.d,
            ),
          ),
        ),
      ],
      authoredOn: startDate.toFhirDateTime,
      performer: Reference(display: doctor.toFhirString),
      performerType: CodeableConcept(text: 'Doctor'.toFhirString),
      identifier: [Identifier(value: ApiConstants.projectIdentifier.toFhirString)],
    );

    if (existingPrescription != null) {
      final updatedPrescription = existingPrescription.copyWith(
        status: body.status,
        medicationX: body.medicationX,
        subject: body.subject,
        dosageInstruction: body.dosageInstruction,
        authoredOn: body.authoredOn,
        performer: body.performer,
        performerType: body.performerType,
      );
      return updatedPrescription.toJson();
    }

    return body.toJson();
  }
}
