import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DeviceService {
  static DeviceService? _instance;
  static DeviceService get instance => _instance ??= DeviceService._();

  DeviceService._();

  final Connectivity _connectivity = Connectivity();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<void> initialize() async {
    // Service initialized, can be extended for future setup needs
  }

  Future<bool> get isConnected async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.any((connection) => connection != ConnectivityResult.none);
    } catch (e) {
      return false;
    }
  }

  Stream<List<ConnectivityResult>> get connectivityStream =>
      _connectivity.onConnectivityChanged;

  Future<bool> get hasWifiConnection async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.wifi);
    } catch (e) {
      return false;
    }
  }

  Future<bool> get hasMobileConnection async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> get deviceInfo async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'systemVersion': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        };
      } else {
        return {
          'platform': Platform.operatingSystem,
          'isPhysicalDevice': true,
        };
      }
    } catch (e) {
      return {
        'platform': Platform.operatingSystem,
        'error': e.toString(),
      };
    }
  }

  Future<bool> get isLowEndDevice async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.sdkInt < 23; // Android 6.0
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final model = iosInfo.model.toLowerCase();
        return model.contains('iphone 6') ||
            model.contains('iphone 5') ||
            model.contains('ipad mini');
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> get supportsAdvancedFeatures async {
    try {
      final connected = await isConnected;
      final lowEnd = await isLowEndDevice;
      return connected && !lowEnd;
    } catch (e) {
      return false;
    }
  }

  Future<int> get recommendedCacheExpiry async {
    try {
      final hasWifi = await hasWifiConnection;
      final lowEnd = await isLowEndDevice;

      if (lowEnd) {
        return 60 * 60 * 1000; // 1 hour for low-end devices
      } else if (hasWifi) {
        return 30 * 60 * 1000; // 30 minutes on WiFi
      } else {
        return 45 * 60 * 1000; // 45 minutes on mobile
      }
    } catch (e) {
      return 30 * 60 * 1000; // Default 30 minutes
    }
  }
}
