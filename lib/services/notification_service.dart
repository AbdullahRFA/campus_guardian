// import 'package:campus_guardian/services/database_service.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
//
//   // 1. Initialize Notification Settings
//   static Future<void> initialize() async {
//     // Request Permission (Critical for iOS & Android 13+)
//     NotificationSettings settings = await _firebaseMessaging.requestPermission(
//       alert: true,
//       badge: true,
//       sound: true,
//     );
//
//     if (settings.authorizationStatus == AuthorizationStatus.authorized) {
//       print('User granted permission');
//     }
//
//     // Initialize Local Notifications (For foreground display)
//     const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initSettings = InitializationSettings(android: androidSettings);
//
//     await _localNotifications.initialize(initSettings);
//
//     // Create a High Importance Channel for Android
//     const AndroidNotificationChannel channel = AndroidNotificationChannel(
//       'high_importance_channel', // id matching AndroidManifest
//       'High Importance Notifications', // title
//       importance: Importance.max,
//     );
//
//     await _localNotifications
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(channel);
//
//     // Retrieve and Save Token
//     final token = await _firebaseMessaging.getToken();
//     if (token != null) {
//       print("FCM Token: $token");
//       await _saveTokenToDatabase(token);
//     }
//
//     // Listen for Token Refreshes
//     _firebaseMessaging.onTokenRefresh.listen(_saveTokenToDatabase);
//
//     // Listen for Foreground Messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       RemoteNotification? notification = message.notification;
//       AndroidNotification? android = message.notification?.android;
//
//       if (notification != null && android != null) {
//         _localNotifications.show(
//           notification.hashCode,
//           notification.title,
//           notification.body,
//           NotificationDetails(
//             android: AndroidNotificationDetails(
//               channel.id,
//               channel.name,
//               icon: android.smallIcon,
//             ),
//           ),
//         );
//       }
//     });
//   }
//
//   // 2. Helper to Save Token to Firestore
//   static Future<void> _saveTokenToDatabase(String token) async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user != null) {
//       // We use the DatabaseService to update the user's profile
//       // Note: You need to ensure updateUserProfile exists or use direct Firestore here.
//       // For safety, let's use direct Firestore or add a specific method in DatabaseService.
//       await DatabaseService(uid: user.uid).saveUserToken(token);
//     }
//   }
// }