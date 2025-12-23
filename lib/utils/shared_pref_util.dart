import 'dart:convert';

import 'package:fhir_demo/constants/extension.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SharedKeys {
  patientInstructionDontShowAgain,
  diagnosisInstructionDontShowAgain,
  observationInstructionDontShowAgain,
  prescriptionInstructionDontShowAgain,
  appointmentInstructionDontShowAgain,
  laboratoryInstructionDontShowAgain,
}

class SharedPrefsUtil {
  static SharedPreferences? _preferences;

  // Initialize SharedPreferences instance
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  // Set methods
  static Future<void> setString({required String key, required String value}) async {
    'key: $key, value: $value'.logError(name: 'setString sharedPref');
    await _preferences?.setString(key, value);
  }

  static Future<void> setBool({required String key, required bool value}) async {
    'key: $key, value: $value'.logError(name: 'setBool sharedPref');

    await _preferences?.setBool(key, value);
  }

  static Future<void> setInt({required String key, required int value}) async {
    ' key: $key, value: $value'.logError(name: 'setInt sharedPref');

    await _preferences?.setInt(key, value);
  }

  static Future<void> setDouble({required String key, required double value}) async {
    ' key: $key, value: $value'.logError(name: 'setInt sharedPref');

    await _preferences?.setDouble(key, value);
  }

  static Future<void> setStringList({required String key, required List<String> value}) async {
    ' key: $key, value: $value'.logError(name: 'setStringList sharedPref');

    await _preferences?.setStringList(key, value);
  }

  static Future<void> setObject({required String key, required Object value}) async {
    ' key: $key, value: $value'.logError(name: 'setStringListFromString sharedPref');

    final jsonString = json.encode(value);
    await _preferences?.setString(key, jsonString);
  }

  // Get methods
  static String? getString({required String key}) {
    return _preferences?.getString(key);
  }

  static bool getBool({required String key}) {
    return _preferences?.getBool(key) ?? false;
  }

  static int? getInt({required String key}) {
    return _preferences?.getInt(key);
  }

  static double? getDouble({required String key}) {
    return _preferences?.getDouble(key);
  }

  static List<String>? getStringList({required String key}) {
    return _preferences?.getStringList(key);
  }

  static T? getObject<T>({required String key, required T Function(Map<String, dynamic>) fromMap}) {
    final jsonString = _preferences?.getString(key);
    if (jsonString != null) {
      final Map<String, dynamic> map = json.decode(jsonString) as Map<String, dynamic>;
      return fromMap(map);
    }
    return null;
  }

  static bool containsKey({required String key}) {
    return _preferences?.containsKey(key) ?? false;
  }

  // Remove methods
  static Future<void> remove({required String key}) async {
    ' key: $key'.logError(name: 'remove sharedPref');

    await _preferences?.remove(key);
  }

  // Clear all stored data
  static Future<void> clearAll() async {
    await _preferences?.clear();
  }
}
