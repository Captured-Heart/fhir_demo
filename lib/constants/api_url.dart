enum ApiUrl {
  hapiPatient('/Patient/'),
  hapiPatientSearch('/Patient/_search'),
  hapiPatientHistory('/Patient/_history/');

  final String url;
  const ApiUrl(this.url);
}

enum FhirServerType {
  hapi('https://hapi.fhir.org/baseR4'),
  azure('https://azure.fhir.server/baseR4'),
  aws('https://aws.fhir.server/baseR4'),
  custom('');

  final String baseUrl;
  const FhirServerType(this.baseUrl);
}
