import 'dart:convert';
import 'package:fhir_demo/constants/fhir_server_type_enum.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/hive_helper/cache_helper.dart';
import 'package:fhir_demo/src/domain/entities/fhir_settings_entity.dart';

/// Provider for FHIR settings
final fhirSettingsProvider = NotifierProvider.autoDispose<FhirSettingsNotifier, FhirSettingsEntity>(
  FhirSettingsNotifier.new,
);

/// State notifier for managing FHIR settings
class FhirSettingsNotifier extends AutoDisposeNotifier<FhirSettingsEntity> {
  final TextEditingController _serverUrlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  FocusNode _serverUrlFocusNode = FocusNode();

  @override
  FhirSettingsEntity build() {
    final defaultState = FhirSettingsEntity(serverBaseUrl: FhirServerType.hapi.baseUrl);
    // Load saved settings asynchronously
    _loadSettings();

    return defaultState;
  }

  // ------ GETTERS ------
  TextEditingController get serverUrlController => _serverUrlController;
  TextEditingController get apiKeyController => _apiKeyController;
  FocusNode get serverUrlFocusNode => _serverUrlFocusNode;

  static const String _settingsKey = 'fhir_settings';

  /// Load settings from local storage
  Future<void> _loadSettings() async {
    try {
      final settingsBox = CacheHelper.themeLocalModel;
      final settingsJson = settingsBox.read(_settingsKey);

      if (settingsJson != null && settingsJson.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(settingsJson);
        state = FhirSettingsEntity.fromJson(decoded);
        _serverUrlController.text = state.customServerBaseUrl ?? state.serverBaseUrl;
        _apiKeyController.text = state.apiKey;
      }
    } catch (e) {
      // If loading fails, keep default settings
      print('Error loading FHIR settings: $e');
    }
  }

  /// Update server base URL
  Future<void> updateServerUrl(String url) async {
    state = state.copyWith(serverBaseUrl: url);
    await _saveSettings();
    _serverUrlFocusNode.unfocus();
  }

  /// Update API key
  Future<void> updateApiKey() async {
    state = state.copyWith(apiKey: _apiKeyController.text.trim());
    await _saveSettings();
  }

  /// Toggle authentication
  Future<void> toggleAuthentication(bool useAuth) async {
    state = state.copyWith(useAuthentication: useAuth);
    await _saveSettings();
  }

  /// Update request timeout
  Future<void> updateTimeout(int timeout) async {
    state = state.copyWith(requestTimeout: timeout);
    await _saveSettings();
  }

  /// Update server type
  Future<bool> updateServerType(FhirServerType serverType) async {
    try {
      print('[FHIR Settings] Updating server type to: ${serverType.name} with URL: ${serverType.baseUrl}');
      if (serverType == FhirServerType.custom) {
        _serverUrlController.text = serverType.baseUrl;
        _serverUrlFocusNode.requestFocus();
        _serverUrlController.text = 'https://';
      }
      state = state.copyWith(serverType: serverType.name, serverBaseUrl: serverType.baseUrl);
      await _saveSettings();
      print('[FHIR Settings] Server type updated. New state: ${state.serverBaseUrl}');
      return Future.delayed(const Duration(milliseconds: 800), () {
        return true;
      });
    } catch (e) {
      return false;
    }
  }

  /// Reset to default HAPI settings
  Future<void> resetToDefaults() async {
    state = FhirSettingsEntity(serverBaseUrl: FhirServerType.hapi.baseUrl);
    _apiKeyController.clear();
    _serverUrlController.text = state.customServerBaseUrl ?? '';
    await _saveSettings();
  }

  /// Save settings to local storage
  Future<void> _saveSettings() async {
    try {
      final settingsBox = CacheHelper.themeLocalModel;
      final settingsJson = jsonEncode(state.toJson());
      await settingsBox.write(_settingsKey, settingsJson);
    } catch (e) {
      print('Error saving FHIR settings: $e');
    }
  }

  /// Test connection to server (placeholder)
  Future<bool> testConnection() async {
    // TODO: Implement actual connection test
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}
