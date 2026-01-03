/// Model class for FHIR server settings
class FhirSettingsEntity {
  final String serverBaseUrl;
  final String? customServerBaseUrl;

  final String apiKey;
  final bool useAuthentication;
  final int requestTimeout;
  final String serverType; // 'HAPI', 'Azure', 'AWS', 'Custom'

  const FhirSettingsEntity({
    required this.serverBaseUrl,
    this.customServerBaseUrl,
    this.apiKey = '',
    this.useAuthentication = false,
    this.requestTimeout = 30,
    this.serverType = 'HAPI',
  });

  FhirSettingsEntity copyWith({
    String? serverBaseUrl,
    String? customServerBaseUrl,
    String? apiKey,
    bool? useAuthentication,
    int? requestTimeout,
    String? serverType,
  }) {
    return FhirSettingsEntity(
      serverBaseUrl: serverBaseUrl ?? this.serverBaseUrl,
      customServerBaseUrl: customServerBaseUrl ?? this.customServerBaseUrl,
      apiKey: apiKey ?? this.apiKey,
      useAuthentication: useAuthentication ?? this.useAuthentication,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      serverType: serverType ?? this.serverType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverBaseUrl': serverBaseUrl,
      'customServerBaseUrl': customServerBaseUrl,
      'apiKey': apiKey,
      'useAuthentication': useAuthentication,
      'requestTimeout': requestTimeout,
      'serverType': serverType,
    };
  }

  factory FhirSettingsEntity.fromJson(Map<String, dynamic> json) {
    return FhirSettingsEntity(
      serverBaseUrl: json['serverBaseUrl'] as String? ?? '',
      customServerBaseUrl: json['customServerBaseUrl'] as String?,
      apiKey: json['apiKey'] as String? ?? '',
      useAuthentication: json['useAuthentication'] as bool? ?? false,
      requestTimeout: json['requestTimeout'] as int? ?? 30,
      serverType: json['serverType'] as String? ?? 'HAPI',
    );
  }
}
