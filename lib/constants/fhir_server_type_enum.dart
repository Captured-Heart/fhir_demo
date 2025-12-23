enum FhirServerType {
  hapi('https://hapi.fhir.org/baseR4'),
  kodjin('https://demo.kodjin.com/fhir'),
  firefly('https://server.fire.ly'),
  custom('');

  final String baseUrl;
  const FhirServerType(this.baseUrl);
}
