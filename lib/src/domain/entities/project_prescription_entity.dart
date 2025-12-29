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
    this.instructions,
  });

  MapStringDynamic addPrescription() {
    final body = MedicationRequest(
      status: MedicationrequestStatus(true.toString()),
      intent: MedicationRequestIntent.order,
      medicationX: CodeableConcept(text: medication.toFhirString),
      subject: Reference(reference: 'Patient/$patientID'.toFhirString),

      dosageInstruction: [
        Dosage(
          text: instructions?.toFhirString,
          route: CodeableConcept(text: route.toFhirString),
          doseAndRate: [DosageDoseAndRate(doseQuantity: Quantity(value: FhirDecimal(dosage)))],
          timing: Timing(repeat: TimingRepeat(frequency: FhirPositiveInt(int.tryParse(frequency)))),
        ),
      ],
      authoredOn: startDate.toFhirDateTime,
      requester: Reference(display: doctor.toFhirString),
    );

    return body.toJson();
  }
}
