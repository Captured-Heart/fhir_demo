import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecureStorageHelper {
  static FlutterSecureStorage? _secureStorage;
  static SharedPreferences? _prefs;

  static FlutterSecureStorage get _instance {
    _secureStorage ??= const FlutterSecureStorage(
      aOptions: AndroidOptions(
        //TODO: CONFIGURE FOR BOIOMETRIC AUTHENTICATION IF NEEDED
        // biometricPromptTitle: 'Authenticate',
        // biometricPromptSubtitle: 'Please authenticate to proceed',
        // enforceBiometrics: false,
      ),
    );
    return _secureStorage!;
  }

  static Future<SharedPreferences> get _prefsInstance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Set methods
  static Future<void> setString({required String key, required String value}) async {
    if (kIsWeb) {
      // Use SharedPreferences on web
      final prefs = await _prefsInstance;
      await prefs.setString(key, value);
    } else {
      // Use FlutterSecureStorage on mobile/desktop
      await _instance.write(key: key, value: value);
    }
  }

  // Get methods
  static Future<String?> getString({required String key}) async {
    if (kIsWeb) {
      // Use SharedPreferences on web
      try {
        final prefs = await _prefsInstance;
        return prefs.getString(key);
      } catch (e) {
        if (kDebugMode) {
          print('[SecureStorage] Web storage error: $e');
        }
        return null;
      }
    } else {
      // Use FlutterSecureStorage on mobile/desktop
      try {
        return await _instance.read(key: key);
      } catch (e) {
        if (kDebugMode) {
          print('[SecureStorage] Secure storage error: $e');
        }
        return null;
      }
    }
  }

  // Remove methods
  static Future<void> remove({required String key}) async {
    if (kIsWeb) {
      final prefs = await _prefsInstance;
      await prefs.remove(key);
    } else {
      await _instance.delete(key: key);
    }
  }

  // Clear all
  static Future<void> clear() async {
    if (kIsWeb) {
      final prefs = await _prefsInstance;
      await prefs.clear();
    } else {
      await _instance.deleteAll();
    }
  }
}
