import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:easy_localization/easy_localization.dart';
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return; 

    tz.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      print("✅ Часовой пояс: $timeZoneName");
    } catch (e) {
      print("⚠️ Ошибка пояса: $e, используем UTC");
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print("📱 Нажали на уведомление: ${response.payload}");
      },
    );

    _isInitialized = true;
    print("✅ NotificationService инициализирован!");
  }

  Future<bool> requestPermissions() async {
    bool granted = false;

    if (Platform.isIOS) {
      granted = await flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
              ) ??
          false;
      print("📱 iOS разрешение: $granted");
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      granted = await android?.requestNotificationsPermission() ?? false;
      print("📱 Android POST_NOTIFICATIONS: $granted");

      await android?.requestExactAlarmsPermission();
      print("📱 Android EXACT_ALARM запрошен");
    }

    return granted;
  }

  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? android =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      final enabled = await android?.areNotificationsEnabled() ?? false;
      print("🔍 Уведомления включены: $enabled");
      return enabled;
    }
    return true; 
  }

  Future<void> scheduleNotification(
    int id,
    String title,
    String body,
    int hour,
    int minute,
  ) async {
    final enabled = await areNotificationsEnabled();
    if (!enabled) {
      print("⚠️ Уведомления выключены, запрашиваем...");
      final granted = await requestPermissions();
      if (!granted) {
        print("❌ Пользователь отказал в разрешении!");
        return;
      }
    }

    final scheduledDate = _nextInstanceOfTime(hour, minute);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'med_alarm_channel_v2',       
          'Напоминания о лекарствах'.tr(),   
          channelDescription: 'Уведомления о приёме лекарств'.tr(),
          importance: Importance.max,    
          priority: Priority.high,    
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,        
          category: AndroidNotificationCategory.alarm,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("🔔 Уведомление #$id запланировано на: $scheduledDate");
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
    print("🗑️ Уведомление #$id отменено");
  }

  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("\u274C Все уведомления отменены");
  }
  
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    print("🗑️ Все уведомления отменены");
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    print("⏰ Заведено на: $scheduledDate (сейчас: $now)");
    return scheduledDate;
  }
}