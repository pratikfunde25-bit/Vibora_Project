import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  Future<void> init() async {
    // 1. Request Permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // 2. Get Token for Firebase Console Testing
    String? token = await _fcm.getToken();
    if (kDebugMode) {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('[FCM TOKEN]: $token');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    }

    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();
    
    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap
      },
    );

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showImmediate(
          id: message.hashCode,
          title: message.notification!.title ?? 'New Alert',
          body: message.notification!.body ?? '',
        );
      }
    });
  }

  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) return;

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'event_reminders',
          'Event Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> showImmediate({
    required int id,
    required String title,
    required String body,
  }) async {
    await _notifications.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'immediate_alerts',
          'Immediate Alerts',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleEventReminders(String eventId, String eventTitle, DateTime startTime) async {
    // 30 Minutes Before
    final thirtyMinBefore = startTime.subtract(const Duration(minutes: 30));
    await scheduleReminder(
      id: eventId.hashCode + 30,
      title: 'Event Starting Soon!',
      body: '$eventTitle starts in 30 minutes. Get ready!',
      scheduledDate: thirtyMinBefore,
    );

    // 10 Minutes Before
    final tenMinBefore = startTime.subtract(const Duration(minutes: 10));
    await scheduleReminder(
      id: eventId.hashCode + 10,
      title: 'Hurry Up!',
      body: '$eventTitle starts in 10 minutes at the venue.',
      scheduledDate: tenMinBefore,
    );
  }
}
