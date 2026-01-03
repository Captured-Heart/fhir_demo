// ignore_for_file: public_member_api_docs, sort_constructors_first

enum FhirServerType {
  hapi('https://hapi.fhir.org/baseR4'),
  kodjin('https://demo.kodjin.com/fhir'),
  firefly('https://server.fire.ly'),
  custom('https://custom-edit-me.com');

  final String baseUrl;
  const FhirServerType(this.baseUrl);
}
