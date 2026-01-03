// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart' as fhir;

class ProjectDiagosisEntity {
  final String patientID;
  final String diagnosis;
  final String severity;
  final String clinicalStatus;
  final DateTime onsetDate;
  final String? notes;
  final String? recorder;

  ProjectDiagosisEntity({
    required this.patientID,
    required this.diagnosis,
    required this.severity,
    required this.clinicalStatus,
    required this.onsetDate,
    this.notes,
    this.recorder,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'patientID': patientID,
      'diagnosis': diagnosis,
      'severity': severity,
      'clinicalStatus': clinicalStatus,
      'onsetDate': onsetDate.millisecondsSinceEpoch,
      'notes': notes,
      'recorder': recorder,
    };
  }

  MapStringDynamic addDiagnosis({fhir.DiagnosticReport? existingDiagnosis}) {
    final body = fhir.DiagnosticReport(
      id: fhir.FhirString(patientID),
      language: fhir.CommonLanguages('en'),
      status: fhir.DiagnosticReportStatus(clinicalStatus.toLowerCase()),
      code: fhir.CodeableConcept(text: diagnosis.toFhirString),
      subject: fhir.Reference(reference: fhir.FhirString('Patient/$patientID')),
      effectiveDateTime: onsetDate.toFhirDateTime,
      presentedForm:
          notes != null
              ? [
                fhir.Attachment(
                  title: fhir.FhirString(notes),
                  contentType: fhir.FhirCode('text/plain'),
                  data: fhir.FhirBase64Binary(base64Encode(utf8.encode(notes!))),
                ),
              ]
              : null,
      performer: recorder != null ? [fhir.Reference(display: fhir.FhirString(recorder!))] : null,
      identifier: [fhir.Identifier(value: ApiConstants.projectIdentifier.toFhirString)],
      conclusion: fhir.FhirString(severity),
    );
    if (existingDiagnosis != null) {
      // Copy over any necessary fields from existingDiagnosis if needed
      final updatedBody = existingDiagnosis.copyWith(
        language: body.language,
        status: body.status,
        code: body.code,
        subject: body.subject,
        presentedForm: body.presentedForm,
        performer: body.performer,
        identifier: body.identifier,
        conclusion: body.conclusion,
      );

      return updatedBody.toJson();
    }
    return body.toJson();
  }

  factory ProjectDiagosisEntity.fromMap(Map<String, dynamic> map) {
    return ProjectDiagosisEntity(
      patientID: map['patientID'] as String,
      diagnosis: map['diagnosis'] as String,
      severity: map['severity'] as String,
      clinicalStatus: map['clinicalStatus'] as String,
      onsetDate: DateTime.parse(map['onsetDate'] as String),
      notes: map['notes'] != null ? map['notes'] as String : null,
      recorder: map['recorder'] != null ? map['recorder'] as String : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory ProjectDiagosisEntity.fromJson(String source) =>
      ProjectDiagosisEntity.fromMap(json.decode(source) as Map<String, dynamic>);
}
