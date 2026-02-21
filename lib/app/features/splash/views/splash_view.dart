import 'package:admin/app/features/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SplashController());

    return Scaffold(
      body: Obx(
        () => Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/splash.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: controller.isLoading.value
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.secondary,
                        ),
                        strokeWidth: 2,
                      ),
                    ),
                    Gap(20),

                    Text(
                      'جارٍ التحميل...',
                      style: TextStyle(
                        fontFamily: 'dijlah',
                        // استفاده از رنگ secondary از تم
                        color: Theme.of(context).colorScheme.secondary,
                        fontSize: 16,
                      ),
                    ),

                    Gap(50),
                  ],
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
