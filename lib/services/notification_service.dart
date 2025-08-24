import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_initialized) return;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('🔔 [Notifications] ✅ Initialized successfully');
  }

  /// Handle notification tap
  static void _onNotificationTap(NotificationResponse notificationResponse) {
    debugPrint(
        '🔔 [Notifications] 👆 Notification tapped: ${notificationResponse.payload}');
    // TODO: Handle navigation to specific content based on payload
  }

  /// Request permissions for notifications
  static Future<bool> requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      final bool? granted = await androidImplementation?.requestNotificationsPermission();
      return granted ?? false;
    } else if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      final bool? granted = await _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return granted ?? false;
    }
    return true; // For other platforms, assume granted
  }

  /// Show a notification for favourite team changes
  static Future<void> showFavouriteTeamUpdate({
    required String teamName,
    required String changeType,
    required String details,
    String? competitionName,
    String? divisionName,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'favourite_updates',
      'Favourite Team Updates',
      channelDescription: 'Notifications for changes to your favourite teams',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: iosNotificationDetails,
    );

    final String title = 'Update: $teamName';
    final String body = '$changeType: $details';

    // Create payload for navigation
    final String payload = 'team_update:$teamName:$competitionName:$divisionName';

    await _notificationsPlugin.show(
      DateTime.now().millisecond, // Use timestamp as unique ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint(
        '🔔 [Notifications] 📱 Sent notification for $teamName: $changeType');
  }

  /// Show a notification for fixture changes
  static Future<void> showFixtureUpdate({
    required String homeTeam,
    required String awayTeam,
    required String changeType,
    String? competitionName,
    String? divisionName,
    String? newScore,
    DateTime? matchTime,
  }) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'fixture_updates',
      'Match Updates',
      channelDescription: 'Notifications for match score and status updates',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iosNotificationDetails,
      macOS: iosNotificationDetails,
    );

    final String title = '$homeTeam vs $awayTeam';
    String body = changeType;
    
    if (newScore != null) {
      body += ': $newScore';
    }

    // Create payload for navigation
    final String payload = 'fixture_update:$homeTeam:$awayTeam:$competitionName:$divisionName';

    await _notificationsPlugin.show(
      DateTime.now().millisecond + 1, // Use timestamp as unique ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );

    debugPrint(
        '🔔 [Notifications] 📱 Sent notification for $homeTeam vs $awayTeam: $changeType');
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
    debugPrint('🔔 [Notifications] 🧹 Cancelled all notifications');
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _notificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      return await androidImplementation?.areNotificationsEnabled() ?? false;
    }
    return true; // For other platforms, assume enabled
  }
}