import 'package:admin/app/features/auth/views/agent_2fa_view.dart';
import 'package:admin/app/features/auth/views/agent_activate_view.dart';
import 'package:admin/app/features/auth/views/agent_login_view.dart';
import 'package:admin/app/features/auth/views/agent_register_view.dart';
import 'package:admin/app/features/load_content/views/content_view.dart';
import 'package:admin/app/features/splash/views/splash_view.dart';
import 'package:get/get.dart';

class Routes {
  // Existing routes
  static const String splash = '/splash';
  static const String login = '/login';
  static const String otp = '/otp';
  static const String content = '/content';

  // Agent auth routes
  static const String agentRegister = '/agent/register';
  static const String agentActivate = '/agent/activate';
  static const String agentLogin = '/agent/login';
  static const String agent2FA = '/agent/2fa';

  static final List<GetPage> pages = [
    GetPage(name: splash, page: () => const SplashView()),
    GetPage(name: content, page: () => const ContentView()),

    // Agent auth pages
    GetPage(name: agentRegister, page: () => const AgentRegisterView()),
    GetPage(name: agentActivate, page: () => const AgentActivateView()),
    GetPage(name: agentLogin, page: () => const AgentLoginView()),
    GetPage(name: agent2FA, page: () => const Agent2FAView()),
  ];
}
