// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:fhir_demo/constants/nav_routes.dart';
import 'package:fhir_demo/src/presentation/widgets/layouts/device_responsive_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ResultState { idle, loading }

@immutable
class Result<T> {
  final T data;
  final Map<String, dynamic> meta;
  final ResultState state;

  bool get isLoading => state == ResultState.loading;

  const Result({required this.data, this.meta = const {}, required this.state});

  factory Result.initial({required T data, Map<String, dynamic> meta = const {}}) {
    return Result(data: data, state: ResultState.idle, meta: meta);
  }

  Result<T> copyWith({T? data, Map<String, dynamic>? meta, ResultState? state}) {
    return Result<T>(data: data ?? this.data, meta: meta ?? this.meta, state: state ?? this.state);
  }

  @override
  bool operator ==(covariant Result<T> other) {
    if (identical(this, other)) return true;

    return other.data == data && mapEquals(other.meta, meta) && other.state == state;
  }

  @override
  int get hashCode => data.hashCode ^ meta.hashCode ^ state.hashCode;
}

final uiServiceProvider = Provider<UIService>((ref) {
  return UIService(ref);
});

class UIService {
  final Ref ref;

  BuildContext? _mainContext;

  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<bool> customDrawerNotifier = ValueNotifier<bool>(false);
  final ValueNotifier<OverlayEntry?> _currentOverlay = ValueNotifier<OverlayEntry?>(null);
  final ValueNotifier<DeviceDetails?> _deviceDetails = ValueNotifier<DeviceDetails?>(null);

  // Cache for device details to avoid repeated calculations
  DeviceDetails? _cachedDeviceDetails;
  Size? _cachedSize;

  // Debouncing timer for resize events
  DateTime? _lastResizeTime;
  static const _resizeDebounceMs = 150;

  bool get hasOverlay => _currentOverlay.value != null;
  ValueNotifier<OverlayEntry?> get currentOverlay => _currentOverlay;

  DeviceDetails? get deviceType => _deviceDetails.value;

  ValueNotifier<DeviceDetails?> get deviceTypeNotifier => _deviceDetails;

  bool get isMobileDevice => _deviceDetails.value?.isMobile ?? true;

  bool get isTabletDevice => _deviceDetails.value?.isTablet ?? false;

  bool get isComputerDevice => _deviceDetails.value?.isComputer ?? false;

  bool get isComputerOrTabletDevice => isComputerDevice || isTabletDevice;

  BuildContext? get mainContext {
    final mobileContext = navigatorKey.currentContext;
    // ref.read(appRouterServiceProvider).mainBuildContext;

    return _mainContext ?? mobileContext;
  }

  /// Sets device type with caching and debouncing for performance
  void setDeviceType(BuildContext context, DeviceDetails details) {
    _mainContext = context;

    // Get current size for caching
    final currentSize = MediaQuery.sizeOf(context);

    // Check if we can use cached device details (same size)
    if (_cachedSize != null &&
        _cachedSize!.width == currentSize.width &&
        _cachedSize!.height == currentSize.height &&
        _cachedDeviceDetails != null) {
      // Size hasn't changed, use cached details
      if (_deviceDetails.value != _cachedDeviceDetails) {
        _deviceDetails.value = _cachedDeviceDetails;
      }
      return;
    }

    // Debounce resize events (especially important for web)
    final now = DateTime.now();
    if (_lastResizeTime != null) {
      final timeSinceLastResize = now.difference(_lastResizeTime!).inMilliseconds;
      if (timeSinceLastResize < _resizeDebounceMs) {
        // Too soon, skip this update
        return;
      }
    }

    // Update cache and device details
    _lastResizeTime = now;
    _cachedSize = currentSize;
    _cachedDeviceDetails = details;
    _deviceDetails.value = details;
    unsetOverlay();
  }

  /// Force refresh device type (useful after orientation changes)
  void forceRefreshDeviceType(BuildContext context) {
    _cachedSize = null;
    _cachedDeviceDetails = null;
    _lastResizeTime = null;
    final size = MediaQuery.sizeOf(context);
    setDeviceType(context, DeviceDetails.fromSize(size));
  }

  void openDrawer({bool value = true, Function()? onDone}) {
    customDrawerNotifier.value = value;
    if (onDone != null) {
      Future.delayed(const Duration(milliseconds: 400), onDone);
    }
  }

  UIService(this.ref);

  bool get isLoading => _isLoading.value;
  ValueNotifier<bool> get uiLoading => _isLoading;

  void _startLoading([bool value = true]) => _isLoading.value = value;

  void _stopLoading() => _isLoading.value = false;

  Future<T?> runFuture<T>(Future Function() future, {Function(dynamic)? onError}) async {
    if (isLoading == false) {
      try {
        _startLoading();

        T response = await future();
        _stopLoading();
        return response;
      } catch (error) {
        _stopLoading();

        if (onError != null) {
          onError(error);
        }
      }
    }
    return null;
  }

  OverlayEntry createOverlay(OverlayEntry entry) {
    _currentOverlay.value = entry;
    return entry;
  }

  void unsetOverlay() {
    _currentOverlay.value?.remove();
    _currentOverlay.value = null;
  }
}
