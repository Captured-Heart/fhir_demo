import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:fhir_demo/src/domain/entities/api_response.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fhir_demo/constants/dio_exception_handler.dart';
import 'package:fhir_demo/src/domain/repository/network/connectivity_repository.dart';
import 'package:fhir_demo/src/domain/repository/network/dio_repository.dart';

final networkCallsRepositoryProvider = Provider<NetworkCallsRepository>((ref) {
  final dioRepository = ref.watch(dioRepositoryProvider);
  final connectivityRepository = ref.read(connectivityRepositoryProvider);
  return NetworkCallsRepositoryImplementation(dioRepository, connectivityRepository);
});

abstract class NetworkCallsRepository {
  // Header Management
  void updateHeaders(Map<String, dynamic> headers);
  void addHeader(String key, dynamic value);
  void removeHeader(String key);
  Map<String, dynamic> getCurrentHeaders();

  // sends a GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  });

  // sends a POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });
  // sends a  PUT  request
  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  });
}

class NetworkCallsRepositoryImplementation implements NetworkCallsRepository {
  final DioRepository _dioRepository;
  final ConnectivityRepository _connectivityRepository;

  NetworkCallsRepositoryImplementation(this._dioRepository, this._connectivityRepository);

  // Header Management Methods
  @override
  void updateHeaders(Map<String, dynamic> headers) {
    _dioRepository.updateHeaders(headers);
  }

  @override
  void addHeader(String key, dynamic value) {
    _dioRepository.addHeader(key, value);
  }

  @override
  void removeHeader(String key) {
    _dioRepository.removeHeader(key);
  }

  @override
  Map<String, dynamic> getCurrentHeaders() {
    return _dioRepository.getCurrentHeaders();
  }

  @override
  Future<ApiResponse<T>> get<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return await _connectivityRepository.executeWithConnectivityCheck<T>(
      networkCall: () async {
        try {
          final response = await _dioRepository.get<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onReceiveProgress: onReceiveProgress,
          );
          // Handle successful response
          if (response.statusCode == 200) {
            return ApiResponse.success(response.data as T, statusCode: response.statusCode);
          } else {
            return ApiResponse.error('Failed to load data', statusCode: response.statusCode);
          }
        } catch (e) {
          return DioExceptionHandler.handleDioException<T>(e);
        }
      },
      operationName: 'GET $path',
    );
  }

  @override
  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return await _connectivityRepository.executeWithConnectivityCheck<T>(
      networkCall: () async {
        try {
          final response = await _dioRepository.post<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          return ApiResponse.success(response.data as T, statusCode: response.statusCode);
        } catch (e) {
          log('what is the error $e');
          return DioExceptionHandler.handleDioException<T>(e);
        }
      },
      operationName: 'POST $path',
    );
  }

  @override
  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return await _connectivityRepository.executeWithConnectivityCheck<T>(
      networkCall: () async {
        try {
          final response = await _dioRepository.put<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
            onSendProgress: onSendProgress,
            onReceiveProgress: onReceiveProgress,
          );
          return ApiResponse.success(response.data as T, statusCode: response.statusCode);
        } catch (e) {
          return DioExceptionHandler.handleDioException<T>(e);
        }
      },
      operationName: 'PUT $path',
    );
  }
}
