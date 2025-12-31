import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart';

class ProjectObservationEntity {
  final String patientId;
  final DateTime observationDate;
  final String? systolicBloodPressure;
  final String? diastolicBloodPressure;
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
    this.systolicBloodPressure,
    this.diastolicBloodPressure,
    this.heartRate,
    this.temperature,
    this.respiratoryRate,
    this.oxygenSaturation,
    this.weight,
    this.height,
    this.clinicalNotes,
  });

  MapStringDynamic addObservation({Observation? existingObservation}) {
    final body = Observation(
      status: ObservationStatus.final_,
      code: CodeableConcept(
        coding: [
          Coding(
            system: FhirUri(FhirCodeProjectEnum.vitalSignsPanel.urlPath),
            code: FhirCodeProjectEnum.vitalSignsPanel.code.toFhirCode,
            display: FhirCodeProjectEnum.vitalSignsPanel.displayName.toFhirString,
          ),
        ],
      ),
      subject: Reference(reference: 'Patient/$patientId'.toFhirString),
      effectiveDateTime: observationDate.toFhirDateTime,
      component: [
        if (systolicBloodPressure != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri(FhirCodeProjectEnum.systolicBloodPressure.urlPath),
                  code: FhirCodeProjectEnum.systolicBloodPressure.code.toFhirCode,
                  display: FhirCodeProjectEnum.systolicBloodPressure.displayName.toFhirString,
                ),
              ],
            ),
            valueString: systolicBloodPressure?.toFhirString,
          ),

        if (diastolicBloodPressure != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri(FhirCodeProjectEnum.diastolicBloodPressure.urlPath),
                  code: FhirCodeProjectEnum.diastolicBloodPressure.code.toFhirCode,
                  display: FhirCodeProjectEnum.diastolicBloodPressure.displayName.toFhirString,
                ),
              ],
            ),
            valueString: diastolicBloodPressure?.toFhirString,
          ),
        if (heartRate != null)
          ObservationComponent(
            code: CodeableConcept(
              coding: [
                Coding(
                  system: FhirUri(FhirCodeProjectEnum.heartRate.urlPath),
                  code: FhirCodeProjectEnum.heartRate.code.toFhirCode,
                  display: FhirCodeProjectEnum.heartRate.displayName.toFhirString,
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
                  system: FhirUri(FhirCodeProjectEnum.bodyTemperature.urlPath),
                  code: FhirCodeProjectEnum.bodyTemperature.code.toFhirCode,
                  display: FhirCodeProjectEnum.bodyTemperature.displayName.toFhirString,
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
                  system: FhirUri(FhirCodeProjectEnum.respiratoryRate.urlPath),
                  code: FhirCodeProjectEnum.respiratoryRate.code.toFhirCode,
                  display: FhirCodeProjectEnum.respiratoryRate.displayName.toFhirString,
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
                  system: FhirUri(FhirCodeProjectEnum.oxygenSaturation.urlPath),
                  code: FhirCodeProjectEnum.oxygenSaturation.code.toFhirCode,
                  display: FhirCodeProjectEnum.oxygenSaturation.displayName.toFhirString,
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
                  system: FhirUri(FhirCodeProjectEnum.bodyWeight.urlPath),
                  code: FhirCodeProjectEnum.bodyWeight.code.toFhirCode,
                  display: FhirCodeProjectEnum.bodyWeight.displayName.toFhirString,
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
                  system: FhirUri(FhirCodeProjectEnum.bodyHeight.urlPath),
                  code: FhirCodeProjectEnum.bodyHeight.code.toFhirCode,
                  display: FhirCodeProjectEnum.bodyHeight.displayName.toFhirString,
                ),
              ],
            ),
            valueQuantity: Quantity(value: height?.toFhirDecimal, unit: 'cm'.toFhirString),
          ),
      ],
      note: clinicalNotes != null ? [Annotation(text: clinicalNotes!.toFhirMarkdown)] : null,
    );

    if (existingObservation != null) {
      // Copy over any necessary fields from existingObservation if needed
      final updatedBody = existingObservation.copyWith(
        status: body.status,
        code: body.code,
        subject: body.subject,
        component: body.component,
        note: body.note,
      );
      return updatedBody.toJson();
    }

    return body.toJson();
  }
}

enum FhirCodeProjectEnum {
  vitalSignsPanel('85353-1', 'Vital signs, weight, height, head circumference, oxygen saturation and BMI panel'),
  systolicBloodPressure('8480-6', 'Systolic Blood Pressure'),
  diastolicBloodPressure('8462-4', 'Diastolic Blood Pressure'),
  heartRate('8867-4', 'Heart Rate'),
  bodyTemperature('8310-5', 'Body Temperature'),
  respiratoryRate('9279-1', 'Respiratory Rate'),
  oxygenSaturation('2708-6', 'Oxygen Saturation'),
  bodyWeight('29463-7', 'Body Weight'),
  bodyHeight('8302-2', 'Body Height');

  final String code, displayName;
  const FhirCodeProjectEnum(this.code, this.displayName);

  static FhirCodeProjectEnum fromCode(String code) {
    return FhirCodeProjectEnum.values.firstWhere((e) => e.code == code, orElse: () => heartRate);
  }

  String get urlPath => 'http://loinc.org';
}
