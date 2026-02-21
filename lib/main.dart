import 'dart:io';

import 'package:admin/app/config/connectivity_controller.dart';
import 'package:admin/app/config/theme.dart';
import 'package:admin/app/core/constants/constants.dart';
import 'package:admin/app/core/init/init.dart';
import 'package:admin/app/core/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:admin/app/core/services/firebase_notification_service.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:google_api_availability/google_api_availability.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    //connectivity controller
    // Constants.localStorage.remove('agent_activation_code');
    Get.put(ConnectivityController());
    return Padding(
      padding: EdgeInsets.only(
        bottom: Platform.isAndroid
            ? MediaQuery.of(context).viewPadding.bottom
            : 0,
      ),
      child: MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(1.0)),
        child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          locale: const Locale('ar'),
          title: Constants.appTitle,
          themeMode: ThemeMode.light,
          darkTheme: MyThemes.darkTheme,
          theme: MyThemes.lightTheme,
          initialRoute: Routes.splash,
          getPages: Routes.pages,
        ),
      ),
    );
  }
}

// Future<void> checkGooglePlayServices() async {
//   GooglePlayServicesAvailability availability = await GoogleApiAvailability
//       .instance
//       .checkGooglePlayServicesAvailability();

//   if (availability != GooglePlayServicesAvailability.success) {
//     debugPrint('Google Play Services not available: $availability');

//     showGooglePlayServicesError(availability);
//   } else {
//     debugPrint('Google Play Services is available.');

//     try {
//       await Firebase.initializeApp().timeout(const Duration(seconds: 5));
//     } catch (e) {
//       debugPrint('Firebase init failed or timed out: $e');
//     }

//     FirebaseMessaging.onBackgroundMessage(handleFirebaseBackgroundMessage);

//     await FirebaseNotificationService().initializeNotifications();
//   }
// }

// void showGooglePlayServicesError(GooglePlayServicesAvailability availability) {
//   debugPrint(
//     'Google Play Services is not available: ${availability.toString()}',
//   );
// }
