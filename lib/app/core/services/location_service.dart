import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class LocationService {
  // درخواست مجوز موقعیت مکانی - فقط پرمیژن
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // بررسی وضعیت مجوز
  static Future<bool> checkLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  // دریافت موقعیت مکانی فعلی - اجباری
  static Future<Position?> getCurrentPosition() async {
    try {
      final hasPermission = await checkLocationPermission();

      if (!hasPermission) {
        final granted = await requestLocationPermission();
        if (!granted) {
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      print('❌ Error getting current position: $e');
      return null;
    }
  }

  // دریافت موقعیت مکانی به همراه اطلاعات کامل
  static Future<Map<String, dynamic>> getLocationData() async {
    try {
      final position = await getCurrentPosition();

      if (position != null) {
        return {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'altitude': position.altitude,
          'speed': position.speed,
          'speed_accuracy': position.speedAccuracy,
          'heading': position.heading,
          'timestamp': position.timestamp?.toIso8601String(),
        };
      }

      return {
        'latitude': null,
        'longitude': null,
        'error': 'موقعیت مکانی در دسترس نیست',
      };
    } catch (e) {
      print('❌ Error getting location data: $e');
      return {'latitude': null, 'longitude': null, 'error': e.toString()};
    }
  }

  // دیالوگ خطای موقعیت مکانی - فقط وقتی واقعاً خطا داریم
  static Future<void> showLocationErrorDialog(
    BuildContext context, {
    required VoidCallback onRetry,
  }) async {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.primary,
        title: Text(
          'الموقع مطلوب',
          style: TextStyle(
            color: colorScheme.error,
            fontFamily: 'dijlah',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_off, size: 50, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'لا يمكن المتابعة بدون تحديد الموقع',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontFamily: 'dijlah',
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'يرجى التأكد من تفعيل خدمة الموقع والضغط على إعادة المحاولة',
              style: TextStyle(
                color: colorScheme.onPrimary.withOpacity(0.7),
                fontFamily: 'dijlah',
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.secondary,
            ),
            child: Text(
              'إعادة المحاولة',
              style: TextStyle(
                color: colorScheme.onSecondary,
                fontFamily: 'dijlah',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
