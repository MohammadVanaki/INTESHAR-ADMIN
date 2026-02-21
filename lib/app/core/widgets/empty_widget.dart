import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: Get.width * .5,
              height: Get.width * .5,
              child: SvgPicture.asset(
                'assets/svg/empty.svg',
                width: Get.width * .5,
                height: Get.width * .5,
                colorFilter: ColorFilter.mode(
                  colorScheme.secondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
            Gap(20),
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontFamily: 'dijlah',
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(10),
          ],
        ),
      ),
    );
  }
}
