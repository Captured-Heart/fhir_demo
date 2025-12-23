enum ApiUrl {
  hapiPatient('/Patient'),
  hapiPatientSearch('/Patient/_search'),
  hapiPatientHistory('/Patient/_history/');

  final String url;
  const ApiUrl(this.url);
}
