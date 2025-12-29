enum ApiUrl {
  fhirPatient('/Patient'),
  fhirDiagnosticReport('/DiagnosticReport'),
  fhirPrescription('/MedicationRequest'),
  fhirObservation('/Observation'),
  fhirAppointment('/Appointment'),
  fhirLabResult('/DiagnosticReport'),
  fhirPatientSearch('/Patient/_search'),
  fhirPatientHistory('/Patient/_history/');

  final String url;
  const ApiUrl(this.url);
}
