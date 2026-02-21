import 'package:admin/app/core/services/agent_api_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class WebViewController extends GetxController {
  var isLoading = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;
  var isWebViewControllerActive = false.obs;
  var canGoBack = false.obs;
  var canGoForward = false.obs;
  var currentUrl = ''.obs;
  var authToken1 = ''.obs;

  InAppWebViewController? webViewController;

  // دریافت URL از API یا استفاده از URL پیش‌فرض
  String get initialUrl {
    final agentApiService = AgentApiService();
    final dashboardUrl = agentApiService.getDashboardUrl();

    // اگر URL داشبورد وجود داشت از آن استفاده کن
    if (dashboardUrl != null && dashboardUrl.isNotEmpty) {
      print('🌐 Using dashboard URL: $dashboardUrl');
      return dashboardUrl;
    }

    // در غیر این صورت از URL پیش‌فرض استفاده کن
    print('🌐 Using default URL: http://v2.inteshar.net');
    return 'https://v2.inteshar.net';
  }

  // دریافت توکن احراز هویت
  String? get authToken {
    final agentApiService = AgentApiService();
    return agentApiService.getAgentToken();
  }

  void checkNavigationState() async {
    if (webViewController != null) {
      canGoBack.value = await webViewController!.canGoBack();
      canGoForward.value = await webViewController!.canGoForward();

      final url = await webViewController!.getUrl();
      currentUrl.value = url?.toString() ?? '';
    }
  }

  void setWebViewController(InAppWebViewController controller) {
    webViewController = controller;
    isWebViewControllerActive.value = true;
    checkNavigationState();
  }

  void startLoading() {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
  }

  void finishLoading() {
    isLoading.value = false;
    hasError.value = false;
    checkNavigationState();
  }

  void setError(String message) {
    isLoading.value = false;
    hasError.value = true;
    errorMessage.value = message;
  }

  void retry() {
    if (!isWebViewControllerActive.value || webViewController == null) return;
    startLoading();
    webViewController?.reload();
  }

  void goBack() async {
    if (!isWebViewControllerActive.value || webViewController == null) return;

    bool canBack = await webViewController!.canGoBack();
    if (canBack) {
      await webViewController!.goBack();
      Future.delayed(const Duration(milliseconds: 300), () {
        checkNavigationState();
      });
    } else {
      Get.back();
    }
  }

  void goForward() async {
    if (!isWebViewControllerActive.value || webViewController == null) return;

    bool canForward = await webViewController!.canGoForward();
    if (canForward) {
      await webViewController!.goForward();
      Future.delayed(const Duration(milliseconds: 300), () {
        checkNavigationState();
      });
    }
  }

  @override
  void onClose() {
    if (webViewController != null) {
      webViewController?.dispose();
    }
    isWebViewControllerActive.value = false;
    webViewController = null;
    super.onClose();
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   Get.snackbar(
  //     'تم تسجيل الدخول بنجاح',
  //     'تم تسجيل الدخول بنجاح إلى لوحة التحكم',
  //     backgroundColor: Colors.green[50],
  //     colorText: Colors.green[800],
  //     duration: const Duration(seconds: 2),
  //     snackPosition: SnackPosition.TOP,
  //   );
  // }
}
