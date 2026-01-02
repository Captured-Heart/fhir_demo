import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/constants/typedefs.dart';
import 'package:fhir_r4/fhir_r4.dart';

class ProjectLabResultEntity {
  final String patientID;
  final String testName;
  final String testCode;
  final DateTime testDate;
  final String resultValue;
  final String unit;
  final String? referenceRange;
  final String status;
  final String? interpretation;
  final String? specimenType;
  final String? laboratory;
  final String? notes;

  ProjectLabResultEntity({
    required this.patientID,
    required this.testName,
    required this.testCode,
    required this.testDate,
    required this.resultValue,
    required this.unit,
    this.referenceRange,
    required this.status,
    this.interpretation,
    this.specimenType,
    this.laboratory,
    this.notes,
  });

  MapStringDynamic addLabResult({DiagnosticReport? existingLabResult}) {
    final body = DiagnosticReport(
      status: DiagnosticReportStatus.values.firstWhere(
        (e) => e.valueString?.toLowerCase() == status.toLowerCase(),
        orElse: () => DiagnosticReportStatus.final_,
      ),
      code: CodeableConcept(coding: [Coding(code: testCode.toFhirCode, display: testName.toFhirString)]),
      subject: Reference(reference: 'Patient/$patientID'.toFhirString),
      effectiveDateTime: testDate.toFhirDateTime,
      issued: DateTime.now().toFhirInstant,
      result: [Reference(display: '$resultValue $unit'.toFhirString)],
      conclusion: notes?.toFhirString,
      conclusionCode: interpretation != null ? [CodeableConcept(text: interpretation?.toFhirString)] : null,
      specimen: specimenType != null ? [Reference(display: specimenType?.toFhirString)] : null,
      performer: laboratory != null ? [Reference(display: laboratory?.toFhirString)] : null,
      identifier: [Identifier(value: ApiConstants.projectIdentifierLabResult.toFhirString)],
      presentedForm: referenceRange != null ? [Attachment(data: referenceRange?.toFhirBase64Binary)] : null,
    );
    if (existingLabResult != null) {
      final updatedBody = existingLabResult.copyWith(
        status: body.status,
        code: body.code,
        subject: body.subject,
        issued: body.issued,
        result: body.result,
        conclusion: body.conclusion,
        conclusionCode: body.conclusionCode,
        specimen: body.specimen,
        performer: body.performer,
      );
      return updatedBody.toJson();
    }
    return body.toJson();
  }
}
