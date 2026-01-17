import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../services/device_service.dart';

final deviceServiceProvider = Provider<DeviceService>((ref) {
  return DeviceService.instance;
});

final connectivityProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.connectivityStream;
});

final isConnectedProvider = FutureProvider<bool>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.isConnected;
});

final deviceInfoProvider = FutureProvider<Map<String, dynamic>>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.deviceInfo;
});

final isLowEndDeviceProvider = FutureProvider<bool>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.isLowEndDevice;
});

final supportsAdvancedFeaturesProvider = FutureProvider<bool>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.supportsAdvancedFeatures;
});

final recommendedCacheExpiryProvider = FutureProvider<int>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.recommendedCacheExpiry;
});

final hasWifiConnectionProvider = FutureProvider<bool>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.hasWifiConnection;
});

final hasMobileConnectionProvider = FutureProvider<bool>((ref) {
  final deviceService = ref.watch(deviceServiceProvider);
  return deviceService.hasMobileConnection;
});
