import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppVersionController extends GetxController {
  var version = ''.obs;
  var buildNumber = ''.obs;

  @override
  void onInit() {
    super.onInit();
    getAppVersion();
  }

  Future<void> getAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version.value = packageInfo.version;
    buildNumber.value = packageInfo.buildNumber;
  }
}
