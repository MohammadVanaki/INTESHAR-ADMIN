import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class Constants {
  static const String appTitle = 'وسامة';
  static String fcmToken = '';
  static final GetStorage localStorage = GetStorage();
  static BoxDecoration containerBoxDecoration(BuildContext context) =>
      BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 1, offset: Offset(0, 1)),
        ],
        borderRadius: BorderRadius.circular(5),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.primary.withAlpha(100),
            width: 5,
          ),
        ),
      );
}
