import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:fhir_demo/constants/api_constants.dart';
import 'package:fhir_demo/src/controller/fhir_settings_controller.dart';
import 'package:fhir_demo/src/domain/repository/network/token_repository.dart';

final dioRepositoryProvider = Provider<DioRepository>((ref) {
  final tokenRepository = ref.read(tokenRepositoryProvider);
  final fhirSettings = ref.watch(fhirSettingsProvider);
  final repository = DioRepositoryImpl(tokenRepository, fhirSettings.serverBaseUrl);

  print('[DIO Provider] Creating DioRepository with base URL: ${fhirSettings.serverBaseUrl}');

  // Initialize eagerly
  repository.initialize();

  ref.listen<String>(fhirSettingsProvider.select((settings) => settings.serverBaseUrl), (previous, next) {
    print('[DIO Provider] Base URL changed from $previous to $next');
    if (previous != next) {
      repository.updateBaseUrl(next);
    }
  });

  return repository;
});

abstract class DioRepository {
  Future<void> initialize();

  // Configuration Methods
  void updateHeaders(Map<String, dynamic> headers);
  void addHeader(String key, dynamic value);
  void removeHeader(String key);
  Map<String, dynamic> getCurrentHeaders();

  // HTTP Methods
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  });

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });
}

class DioRepositoryImpl extends DioRepository {
  late Dio _dio;
  bool _isInitialized = false;
  final TokenRepository _tokenService;
  String _baseUrl;

  DioRepositoryImpl(this._tokenService, this._baseUrl);

  Dio get dio => _dio;

  /// Get current base URL
  String get baseUrl => _baseUrl;

  /// Update base URL dynamically
  void updateBaseUrl(String newBaseUrl) {
    if (_baseUrl == newBaseUrl) return;

    _baseUrl = newBaseUrl;

    if (_isInitialized) {
      _dio.options.baseUrl = newBaseUrl;
      print('[DIO] Base URL updated to: $newBaseUrl');
    } else {
      print('[DIO] Dio not initialized yet. Base URL will be: $newBaseUrl on initialization');
    }
  }

  /// Update request timeout dynamically
  void updateTimeout(int timeoutSeconds) {
    if (_isInitialized) {
      final duration = Duration(seconds: timeoutSeconds);
      _dio.options.connectTimeout = duration;
      _dio.options.receiveTimeout = duration;
      _dio.options.sendTimeout = duration;
      print('[DIO] Timeout updated to: ${timeoutSeconds}s');
    }
  }

  /// Update all headers at once
  @override
  void updateHeaders(Map<String, dynamic> headers) {
    if (_isInitialized) {
      _dio.options.headers.addAll(headers);
      print('[DIO] Headers updated: ${headers.keys.join(", ")}');
    }
  }

  /// Add or update a single header
  @override
  void addHeader(String key, dynamic value) {
    if (_isInitialized) {
      _dio.options.headers[key] = value;
      print('[DIO] Header added/updated: $key = $value');
    }
  }

  /// Remove a specific header
  @override
  void removeHeader(String key) {
    if (_isInitialized) {
      _dio.options.headers.remove(key);
      print('[DIO] Header removed: $key');
    }
  }

  /// Get current headers
  @override
  Map<String, dynamic> getCurrentHeaders() {
    return _isInitialized ? Map<String, dynamic>.from(_dio.options.headers) : {};
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: ApiConstants.defaultHeaders,
      ),
    );

    await _setupInterceptors();
    _isInitialized = true;
    print('[DIO] Initialized with base URL: $_baseUrl');
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  //! ---------- ADD AUTH TOKENS -----------------
  /// Add authentication token to requests
  Future<void> _addAuthToken(RequestOptions options) async {
    try {
      final token = await _tokenService.getValidToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('[AUTH] Failed to add token: $e');
    }
  }

  //! ------  SET UP INTERCEPTORS ---------------
  ///? I setup all interceptors for security, retry, and logging
  Future<void> _setupInterceptors() async {
    // 1. Token Interceptor - i automatically adds auth tokens in request
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          await _addAuthToken(options);
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          handler.next(response);
        },
        onError: (error, handler) async {
          await _handleError(error, handler);
        },
      ),
    );

    // 2. Retry Interceptor - Handles network failures and retries
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: (message) => print('[RETRY] $message'),
        retries: ApiConstants.maxRetries,
        retryDelays: ApiConstants.retryDelays,
        retryEvaluator: (error, attempt) {
          // Retry on network errors, timeouts, and server errors
          if (error.type == DioExceptionType.connectionTimeout ||
              error.type == DioExceptionType.sendTimeout ||
              error.type == DioExceptionType.receiveTimeout ||
              error.type == DioExceptionType.connectionError) {
            print('[RETRY] Network error, attempt $attempt');
            return true;
          }

          if (error.response?.statusCode != null) {
            final statusCode = error.response!.statusCode!;
            // i can also retry here based on any status code
            if (statusCode >= 500 && statusCode < 600) {
              print('[RETRY] Server error $statusCode, attempt $attempt');
              return true;
            }
          }

          return false;
        },
      ),
    );

    // 3. Logging Interceptor - i am logging requests and responses in development mode
    if (ApiConstants.isDevelopment) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
          error: true,
          logPrint: (object) => print('[DIO] $object'),
        ),
      );
    }
  }

  //! --------- LOG THE RESPONSES ------------------
  void _logResponse(Response response) {
    if (ApiConstants.isDevelopment) {
      print('[API] ${response.requestOptions.method} ${response.requestOptions.path} - ${response.statusCode}');
    }
  }

  // ! ------------ HANDLE ERRORS ---------------
  Future<void> _handleError(DioException error, ErrorInterceptorHandler handler) async {
    print('[ERROR] ${error.type}: ${error.message}');

    // checkk if token is expired
    if (error.response?.statusCode == 401) {
      try {
        final refreshed = await _tokenService.refreshToken();
        if (refreshed) {
          final options = error.requestOptions;
          await _addAuthToken(options);
          final response = await _dio.fetch(options);
          handler.resolve(response);
          return;
        } else {
          // if i can't refresh the token, i clear it and ask user to login again
          await _tokenService.clearTokens();
          handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: 'Authentication failed. Please login again.',
              type: DioExceptionType.unknown,
            ),
          );
          return;
        }
      } catch (e) {
        print('[AUTH] Token refresh failed: $e');
      }
    }

    // Handle network connectivity issues
    if (error.type == DioExceptionType.connectionError) {
      final hasConnection = await _checkConnectivity();
      if (!hasConnection) {
        handler.reject(
          DioException(
            requestOptions: error.requestOptions,
            error: 'No internet connection. Please check your network.',
            type: DioExceptionType.connectionError,
          ),
        );
        return;
      }
    }

    handler.next(error);
  }

  // leveraging on the InternetConnectionChecker package because it not just check the connectivity status but also checks for poor data connection
  Future<bool> _checkConnectivity() async {
    try {
      return InternetConnection().hasInternetAccess;
    } catch (e) {
      return false;
    }
  }

  // HTTP Methods Implementation
  @override
  Future<Response<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    return await _dio.get<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    return await _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  @override
  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    await _ensureInitialized();
    return await _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}
