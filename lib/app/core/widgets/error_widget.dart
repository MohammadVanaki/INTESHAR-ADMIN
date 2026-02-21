import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class CustomErrorWidget {
  static void initialize() {
    ErrorWidget.builder = (FlutterErrorDetails details) {
      final theme = Theme.of(Get.context!);
      final colorScheme = theme.colorScheme;

      return Material(
        child: Container(
          color: colorScheme.primary,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/svgs/error.svg',
                  width: Get.width * 0.7,
                ),
                const Gap(20),
                Text(
                  'حدث خطأ أثناء عملية الطلب.!',
                  style: TextStyle( 
                    fontSize: 16,
                    color: colorScheme.onPrimary,
                    fontFamily: 'dijlah',
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    };
  }
}
