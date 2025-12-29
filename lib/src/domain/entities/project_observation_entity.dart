import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart';

class ProjectObservationEntity {
  // patientId, obseravtionDate, bloodPressure, heartRate, temperature, respiratoryRate, oxygenSaturation, weight, height, clinicalNotes
  final String patientId;
  final DateTime observationDate;
  final String? bloodPressure;
  final String? heartRate;
  final num? temperature;
  final String? respiratoryRate;
  final num? oxygenSaturation;
  final num? weight;
  final num? height;
  final String? clinicalNotes;

  ProjectObservationEntity({
    required this.patientId,
    required this.observationDate,
    this.bloodPressure,
    this.heartRate,
    this.temperature,
    this.respiratoryRate,
    this.oxygenSaturation,
    this.weight,
    this.height,
    this.clinicalNotes,
  });

  MapStringDynamic addObservation() {
    final body = Observation(
      status: ObservationStatus.final_,
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri('http://loinc.org'),
            code: '85353-1'.toFhirCode,
            display: 'Vital signs, weight, height, head circumference, oxygen saturation and BMI panel'.toFhirString,
          ),
        ],
      ),
      subject: Reference(reference: 'Patient/$patientId'.toFhirString),
      effectiveDateTime: observationDate.toFhirDateTime,
      component: [
        if (bloodPressure != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri('http://loinc.org'),
                  code: '85354-9'.toFhirCode,
                  display: 'Blood pressure panel'.toFhirString,
                ),
              ],
            ),
            valueString: bloodPressure?.toFhirString,
          ),
        if (heartRate != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri('http://loinc.org'),
                  code: '8867-4'.toFhirCode,
                  display: 'Heart rate'.toFhirString,
                ),
              ],
            ),
            valueString: heartRate?.toFhirString,
          ),
        if (temperature != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri('http://loinc.org'),
                  code: '8310-5'.toFhirCode,
                  display: 'Body temperature'.toFhirString,
                ),
              ],
            ),
            valueQuantity: Quantity(value: temperature?.toFhirDecimal, unit: '°C'.toFhirString),
          ),
        if (respiratoryRate != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri('http://loinc.org'),
                  code: '9279-1'.toFhirCode,
                  display: 'Respiratory rate'.toFhirString,
                ),
              ],
            ),
            valueString: respiratoryRate?.toFhirString,
          ),
        if (oxygenSaturation != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri('http://loinc.org'),
                  code: '2708-6'.toFhirCode,
                  display: 'Oxygen saturation'.toFhirString,
                ),
              ],
            ),
            valueQuantity: Quantity(value: oxygenSaturation?.toFhirDecimal, unit: '%'.toFhirString),
          ),
        if (weight != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri('http://loinc.org'),
                  code: '29463-7'.toFhirCode,
                  display: 'Body weight'.toFhirString,
                ),
              ],
            ),
            valueQuantity: Quantity(value: weight?.toFhirDecimal, unit: 'kg'.toFhirString),
          ),
        if (height != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri('http://loinc.org'),
                  code: '8302-2'.toFhirCode,
                  display: 'Body height'.toFhirString,
                ),
              ],
            ),
            valueQuantity: Quantity(value: height?.toFhirDecimal, unit: 'cm'.toFhirString),
          ),
      ],
      note: clinicalNotes != null ? [Annotation(text: clinicalNotes!.toFhirMarkdown)] : null,
    );

    return body.toJson();
  }
}
