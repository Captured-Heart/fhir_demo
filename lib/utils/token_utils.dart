import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:fhir_demo/constants/extension.dart';
import 'package:fhir_demo/constants/secure_storage_helper.dart';
import 'package:fhir_demo/utils/shared_pref_util.dart';

class TokenUtils {
  static final TokenUtils _instance = TokenUtils._();
  factory TokenUtils() => _instance;
  TokenUtils._();

  /// Generate hash for token integrity check
  String _generateTokenHash(String token) {
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // store tokens securely
  Future<void> storeTokens({required String accessToken, String? refreshToken}) async {
    try {
      final tokenHash = _generateTokenHash(accessToken);

      SecureStorageHelper.setString(key: SharedKeys.accessToken.name, value: accessToken);
      SecureStorageHelper.setString(key: SharedKeys.tokenHash.name, value: tokenHash);

      if (refreshToken != null) {
        SecureStorageHelper.setString(key: SharedKeys.refreshToken.name, value: refreshToken);
      }
    } catch (e) {
      '[TOKEN] Error storing tokens: $e'.logError(name: 'TOKEN');
      throw Exception('Failed to store authentication tokens');
    }
  }

  // get access token
  Future<String?> getAccessToken() async {
    try {
      final token = await SecureStorageHelper.getString(key: SharedKeys.accessToken.name);
      'Retrieved encrypted access token: ${token != null ? "exists" : "null"}'.logError(name: 'TOKEN');
      if (token == null) return null;

      // Validate token integrity
      final storedHash = await SecureStorageHelper.getString(key: SharedKeys.tokenHash.name);
      final currentHash = _generateTokenHash(token);
      if (storedHash != currentHash) {
        '[TOKEN] Token integrity check failed'.logError(name: 'TOKEN');
        // since both tokens are not equal, we clear the stored tokens
        await clearTokens();
        return null;
      }

      return token;
    } catch (e) {
      '[TOKEN] Error retrieving access token: $e'.logError(name: 'TOKEN');
      await clearTokens();
      return null;
    }
  }

  // get refresh token
  Future<String?> getRefreshToken() async {
    try {
      final token = await SecureStorageHelper.getString(key: SharedKeys.refreshToken.name);
      if (token == null) return null;

      'what is decrypted refresh token: $token'.logError(name: 'TOKEN');
      return token;
    } catch (e) {
      '[TOKEN] Error retrieving refresh token: $e'.logError(name: 'TOKEN');
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        SecureStorageHelper.remove(key: SharedKeys.accessToken.name),
        SecureStorageHelper.remove(key: SharedKeys.refreshToken.name),
        SecureStorageHelper.remove(key: SharedKeys.tokenHash.name),
      ]);
      '[TOKEN] All tokens cleared'.logError(name: 'TOKEN');
    } catch (e) {
      '[TOKEN] Error clearing tokens: $e'.logError(name: 'TOKEN');
    }
  }
}
