import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:html' as html;

import 'package:forsatech/notification_Web_Service.dart'; // استيراد مكتبة الويب

/// For web notifications

class PushNotifications {
  static final _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    try {
      // Request notification permissions
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔐 User granted permission: ${settings.authorizationStatus}');

      if (!kIsWeb) {
        // Initialize local notifications for mobile
        const AndroidInitializationSettings androidInitializationSettings =
            AndroidInitializationSettings('@mipmap/ic_launcher');

        const InitializationSettings initializationSettings =
            InitializationSettings(android: androidInitializationSettings);

        await _flutterLocalNotificationsPlugin.initialize(
          initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            debugPrint('🔔 Notification clicked: ${response.payload}');
            // Handle notification click if needed
          },
        );
      }

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        debugPrint('📥 Foreground message received');
        debugPrint('📦 Data: ${message.data}');

        if (message.notification != null) {
          debugPrint('📝 Notification Title: ${message.notification?.title}');
          debugPrint('📝 Notification Body: ${message.notification?.body}');

          try {
            if (kIsWeb) {
              showWebNotification(
                title: message.notification?.title ?? 'New Notification',
                body: message.notification?.body ?? 'You have a new message',
                data: message.data,
              );
            } else {
              showSimpleNotification(
                title: message.notification?.title ?? 'New Notification',
                body: message.notification?.body ?? 'You have a new message',
                payload: message.data.toString(),
              );
            }
          } catch (e) {
            debugPrint('❌ Error showing notification: $e');
          }
        }
      });

      // Handle notification when the app is opened from terminated state
      RemoteMessage? initialMessage =
          await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      // Handle notification when app is opened from background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessageHandler);

      // Get FCM token
      await getFCMToken();
    } catch (e) {
      debugPrint('❌ Error initializing push notifications: $e');
    }
  }

  /// Background message handler
  static Future<void> _firebaseBackgroundMessageHandler(
      RemoteMessage message) async {
    debugPrint('🌙 Background message received: ${message.messageId}');
    // Optionally handle/store notification here
  }

  /// When notification is clicked and app is opened
  static Future<void> _handleMessage(RemoteMessage message) async {
    debugPrint('📨 Notification clicked with data: ${message.data}');
    Fluttertoast.showToast(
      msg: message.notification?.title ?? 'Notification opened',
      toastLength: Toast.LENGTH_SHORT,
    );
  }

  /// Show a simple local notification on mobile
  static Future<void> showSimpleNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'default_channel_id',
      'Default',
      channelDescription: 'Default notification channel',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformDetails,
      payload: payload,
    );
  }

  /// Show notification on web
  static void showWebNotification({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    if (html.Notification.supported) {
      html.Notification.requestPermission().then((permission) {
        if (permission == 'granted') {
          html.Notification(title, body: body);
        } else {
          debugPrint('❌ Notification permission not granted.');
        }
      });
    } else {
      debugPrint('❌ Notifications not supported in this browser.');
    }
  }

  /// Get the FCM token
  static Future<void> getFCMToken() async {
  try {
    String? token = await _firebaseMessaging.getToken();
    debugPrint('📲 FCM Token: $token');
    if (token != null) {
      // إنشاء instance من خدمة FCM ويب سيرفيس
      final fcmService = FcmWebService();
      await fcmService.sendFcmToken(token);
    }
  } catch (e) {
    debugPrint('❌ Failed to get/send FCM token: $e');
  }
}
}
