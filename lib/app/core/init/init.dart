import 'dart:async';
import 'dart:io';

import 'package:admin/app/core/constants/constants.dart';
import 'package:admin/app/core/services/firebase_notification_service.dart';
import 'package:admin/app/core/services/get_version.dart';
import 'package:admin/app/core/widgets/error_widget.dart';
import 'package:admin/app/features/auth/controllers/agent_auth_controller.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// import 'package:flutter_foreground_task/flutter_foreground_task.dart';

Future<void> init() async {
  await GetStorage.init();
  CustomErrorWidget.initialize();


  

  bool hasInternet = await checkInternetConnection();
  if (hasInternet) {
    // try {
    //   await Firebase.initializeApp().timeout(
    //     const Duration(seconds: 5),
    //     onTimeout: () {
    //       print('Firebase initialization timed out');
    //       return Future.error(
    //         TimeoutException(
    //           'Firebase initialization timed out',
    //           const Duration(seconds: 5),
    //         ),
    //       );
    //     },
    //   );

    //   // فقط اگر Firebase با موفقیت initialize شد
    //   if (Firebase.apps.isNotEmpty) {
    //     FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);
    //     await FirebaseNotificationService().initializeNotifications();
    //   }
    // } catch (e) {
    //   print('Firebase initialization failed: $e');
    // }
  } else {
    print('No internet - Skipping Firebase initialization');
  }

  Get.put(AppVersionController());
  Get.put(AgentAuthController());
}

// تابع چک کردن اتصال به اینترنت
Future<bool> checkInternetConnection() async {
  try {
    final result = await InternetAddress.lookup(
      'google.com',
    ).timeout(const Duration(seconds: 3));
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } catch (e) {
    return false;
  }
}
