import 'package:admin/app/core/constants/constants.dart';
import 'package:admin/app/core/services/agent_api_service.dart';
import 'package:admin/app/features/auth/views/agent_register_view.dart';
import 'package:admin/app/features/load_content/views/content_view.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final isLoading = true.obs;
  final AgentApiService agentApiService = AgentApiService();

  @override
  void onInit() {
    super.onInit();
    startTimer();
  }

  void startTimer() async {
    await Future.delayed(const Duration(seconds: 3));
    isLoading.value = false;
    _checkAuthStatus();
  }

  void _checkAuthStatus() async {
    // 1. اول چک کن ایا agent کاملاً لاگین کرده (توکن + دشبورد URL)
    final agentToken = agentApiService.getAgentToken();
    final dashboardUrl = agentApiService.getDashboardUrl();

    print('🔍 Agent Token: ${agentToken != null ? "✅ Exists" : "❌ Not found"}');
    print('🔍 Dashboard URL: ${dashboardUrl ?? "❌ Not found"}');

    if (agentToken != null && dashboardUrl != null) {
      print('✅ Agent fully authenticated → ContentView');
      Get.offAll(() => const ContentView());
      return;
    }

    // 2. بعد چک کن ایا agent قبلاً ثبت‌نام کرده (کد فعال‌سازی داره)
    final activationCode = agentApiService.getStoredActivationCode();
    final isAgentActivated = agentApiService.isAgentActivated();
    final agentId = agentApiService.getAgentId();

    print(
      '🔍 Activation Code: ${activationCode != null ? "✅ Exists" : "❌ Not found"}',
    );
    print('🔍 Is Activated: ${isAgentActivated ?? "null"}');
    print('🔍 Agent ID: ${agentId ?? "null"}');

    // اگه کد فعال‌سازی داره ولی فعال نشده
    if (activationCode != null && isAgentActivated == null) {
      print('📝 Agent registered but not activated → ActivateView');
      Get.offAllNamed('/agent/activate');
      return;
    }

    // اگه فعال شده ولی توکن نداره
    if (activationCode != null &&
        isAgentActivated != null &&
        isAgentActivated.isNotEmpty &&
        agentToken == null) {
      print('🔑 Agent activated but no token → LoginView');
      Get.offAllNamed('/agent/login');
      return;
    }

    // 3. چک کردن یوزر معمولی
    final isUserLoggedIn = Constants.localStorage.read('isLoggedIn') ?? false;
    final userToken = Constants.localStorage.read('auth_token');

    if (isUserLoggedIn && userToken != null) {
      print('👤 Regular user logged in → ContentView');
      Get.offAll(() => const ContentView());
      return;
    }

    // 4. هیچکدوم از موارد بالا نبود → برو به صفحه ثبت‌نام
    print('🆕 No authentication found → AgentRegisterView');
    Get.offAll(() => const AgentRegisterView());
  }
}
