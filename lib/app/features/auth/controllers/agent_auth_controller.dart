import 'package:admin/app/core/constants/constants.dart';
import 'package:admin/app/core/services/agent_api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgentAuthController extends GetxController {
  final AgentApiService _apiService = AgentApiService();

  // Observables
  final isLoading = false.obs;
  final currentStep = 0.obs; // 0: register, 1: activate, 2: login, 3: 2fa
  final name = ''.obs;
  final email = ''.obs;
  final password = ''.obs;
  final activationCode = ''.obs;
  final twoFACode = ''.obs;
  final showPassword = false.obs;

  // Errors
  final nameError = ''.obs;
  final activationCodeError = ''.obs;
  final emailError = ''.obs;
  final passwordError = ''.obs;
  final twoFAError = ''.obs;

  // Success flags
  final isRegistered = false.obs;
  final isActivated = false.obs;
  final isLoggedIn = false.obs;
  final is2FAVerified = false.obs;

  // Agent data
  final agentId = Rx<int?>(null);
  final agentToken = Rx<String?>(null);

  @override
  void onInit() {
    super.onInit();
    _checkExistingAgent();
  }

  // Check if agent already completed steps
  void _checkExistingAgent() {
    final storedActivationCode = _apiService.getStoredActivationCode();
    final isAgentActivated = _apiService.isAgentActivated() ?? '';
    final agentId = _apiService.getAgentId();
    final agentToken = _apiService.getAgentToken();

    if (storedActivationCode != null) {
      activationCode.value = storedActivationCode;
      isRegistered.value = true;
      currentStep.value = 1; // Go to activation step
    }

    if (isAgentActivated.isNotEmpty) {
      isActivated.value = true;
      currentStep.value = 2; // Go to login step
    }

    if (agentId != null) {
      this.agentId.value = agentId;
    }

    if (agentToken != null) {
      this.agentToken.value = agentToken;
      is2FAVerified.value = true;
      isLoggedIn.value = true;
    }
  }

  // Step 1: Register agent with name
  // Step 1: Register agent with name
  Future<void> registerAgent(String name) async {
    if (name.isEmpty) {
      nameError.value = 'الرجاء إدخال الاسم';
      return;
    }

    nameError.value = '';
    isLoading.value = true;

    try {
      final result = await _apiService.registerAgent(name);

      if (result['success'] == true) {
        final data = result['data'];

        // Store activation code
        if (data['activation_code'] != null) {
          activationCode.value = data['activation_code'];
          await _apiService.storeActivationCode(data['activation_code']);
        }

        // Store name
        this.name.value = name;
        isRegistered.value = true;

        // Navigate to activation page automatically
        Get.offNamed('/agent/activate');

        Get.snackbar(
          'تم التسجيل بنجاح',
          'تم إرسال كود التفعيل',
          backgroundColor: Colors.green[50],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
      } else {
        nameError.value = result['error'] ?? 'فشل التسجيل';
      }
    } catch (e) {
      nameError.value = 'حدث خطأ غير متوقع: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Step 2: Activate agent with code
  // Step 2: Activate agent with code
  Future<void> activateAgent(String enteredCode) async {
    if (enteredCode.isEmpty) {
      activationCodeError.value = 'الرجاء إدخال كود التفعيل';
      return;
    }

    activationCodeError.value = '';
    isLoading.value = true;

    try {
      final result = await _apiService.activateAgent(enteredCode);

      if (result['success'] == true) {
        await _apiService.setAgentActivated(enteredCode);
        isActivated.value = true;

        // Navigate to login page automatically
        Get.offNamed('/agent/login');

        Get.snackbar(
          'تم التفعيل بنجاح',
          'يمكنك الآن تسجيل الدخول',
          backgroundColor: Colors.green[50],
          colorText: Colors.green[800],
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
      } else {
        activationCodeError.value = result['error'] ?? 'فشل التفعيل';
      }
    } catch (e) {
      activationCodeError.value = 'حدث خطأ غير متوقع: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Step 3: Login agent
  // Step 3: Login agent
  Future<void> loginAgent1(String email, String password) async {
    if (email.isEmpty) {
      emailError.value = 'الرجاء إدخال البريد الإلكتروني';
      return;
    }

    if (password.isEmpty) {
      passwordError.value = 'الرجاء إدخال كلمة المرور';
      return;
    }

    emailError.value = '';
    passwordError.value = '';
    isLoading.value = true;

    try {
      final storedActivationCode = _apiService.getStoredActivationCode();
      print('🔍 Stored Activation Code: $storedActivationCode');

      if (storedActivationCode == null || storedActivationCode.isEmpty) {
        isLoading.value = false;
        Get.snackbar(
          'خطأ',
          'لم يتم العثور على كود التفعيل. الرجاء التسجيل أولاً.',
          backgroundColor: Colors.red[50],
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      print('🔍 Attempting login with:');
      print('   Email: $email');
      print('   Activation Code: $storedActivationCode');

      final result = await _apiService.loginAgent(
        email: email,
        password: password,
        activationCode: storedActivationCode,
      );

      print('🔍 Raw API Response: $result');

      // Check if result is null
      if (result == null) {
        throw Exception('API returned null response');
      }

      // Check if success key exists
      if (!result.containsKey('success')) {
        throw Exception('Invalid API response format');
      }

      if (result['success'] == true) {
        final data = result['data'];
        print('🔍 Login response data: $data');

        // Check if data is null
        if (data == null) {
          throw Exception('API data is null');
        }

        // Check if 2FA is required based on actual response
        final requires2FA = data['requires_2fa'] ?? false;
        final agentId = data['agent_id'];
        final message = data['message'] ?? 'تم تسجيل الدخول بنجاح';
        final nextStep = data['next_step'] ?? '';

        print('🔍 Login successful:');
        print('   Message: $message');
        print('   Requires 2FA: $requires2FA');
        print('   Agent ID: $agentId');
        print('   Next Step: $nextStep');

        // Store agent id
        if (agentId != null) {
          final agentIdInt = int.tryParse(agentId.toString());
          if (agentIdInt != null) {
            this.agentId.value = agentIdInt;
            await _apiService.storeAgentId(agentIdInt);
            print('🔍 Stored Agent ID: $agentIdInt');
          }
        }

        // Store email for later use
        this.email.value = email;
        this.password.value = password;

        isLoggedIn.value = true;

        // Navigate based on response
        if (requires2FA == true && agentId != null) {
          // Navigate to 2FA page
          Get.offNamed('/agent/2fa');

          Get.snackbar(
            'تم تسجيل الدخول',
            message,
            backgroundColor: Colors.blue[50],
            colorText: Colors.blue[800],
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        } else if (nextStep == 'verify_2fa') {
          // Alternative navigation based on next_step
          Get.offNamed('/agent/2fa');

          Get.snackbar(
            'التحقق الثنائي مطلوب',
            message,
            backgroundColor: Colors.blue[50],
            colorText: Colors.blue[800],
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        } else {
          // If no 2FA required, go directly to content
          print('🔍 No 2FA required, going directly to content');
          Get.offAllNamed('/content');

          // Get.snackbar(
          //   'تم تسجيل الدخول بنجاح',
          //   message,
          //   backgroundColor: Colors.green[50],
          //   colorText: Colors.green[800],
          //   duration: const Duration(seconds: 2),
          //   snackPosition: SnackPosition.TOP,
          // );
        }
      } else {
        // Handle error response
        final errorMessage = result['error'] ?? 'فشل تسجيل الدخول';
        print('🔍 Login failed: $errorMessage');

        // Extract specific error messages
        final errorString = errorMessage.toString().toLowerCase();

        if (errorString.contains('email') || errorString.contains('بريد')) {
          emailError.value = 'البريد الإلكتروني غير صحيح';
        } else if (errorString.contains('password') ||
            errorString.contains('كلمة')) {
          passwordError.value = 'كلمة المرور غير صحيحة';
        } else if (errorString.contains('activation') ||
            errorString.contains('تفعيل')) {
          Get.snackbar(
            'خطأ في كود التفعيل',
            errorMessage,
            backgroundColor: Colors.red[50],
            colorText: Colors.red[800],
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        } else if (errorString.contains('غير مفعل') ||
            errorString.contains('not activated')) {
          Get.snackbar(
            'الحساب غير مفعل',
            'الرجاء تفعيل حسابك أولاً',
            backgroundColor: Colors.orange[50],
            colorText: Colors.orange[800],
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        } else {
          Get.snackbar(
            'خطأ',
            errorMessage,
            backgroundColor: Colors.red[50],
            colorText: Colors.red[800],
            duration: const Duration(seconds: 3),
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      print('❌ Login exception: $e');
      print('❌ Stack trace: ${e.toString()}');

      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: ${e.toString()}',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Step 4: Verify 2FA
  // Step 4: Verify 2FA
  Future<void> verify2FA(String code, {double? lat, double? lon}) async {
    if (code.isEmpty || code.length != 6) {
      twoFAError.value = 'الرجاء إدخال رمز التحقق المكون من 6 أرقام';
      return;
    }

    twoFAError.value = '';
    isLoading.value = true;

    try {
      final storedActivationCode = _apiService.getStoredActivationCode();
      if (storedActivationCode == null) {
        throw Exception('لم يتم العثور على كود التفعيل');
      }

      if (agentId.value == null) {
        throw Exception('لم يتم العثور على معرف العميل');
      }

      print('🔍 Verifying 2FA with:');
      print('   Agent ID: ${agentId.value}');
      print('   Code: $code');
      print('   Activation Code: $storedActivationCode');
      print('   Lat: $lat');
      print('   Lon: $lon');

      final result = await _apiService.verify2FA(
        agentId: agentId.value!,
        code: code,
        activationCode: storedActivationCode,
        lat: lat,
        lon: lon,
      );

      print('🔍 2FA verification raw result: $result');

      if (result == null) {
        throw Exception('API returned null response');
      }

      if (!result.containsKey('success')) {
        throw Exception('Invalid API response format');
      }

      if (result['success'] == true) {
        // ✅ ساختار واقعی: result['data'] خودش حاوی success, message, data
        final responseData =
            result['data']; // اینجا {success: true, message: ..., data: {...}}

        print('🔍 2FA verification successful, response data: $responseData');

        if (responseData == null) {
          throw Exception('API data is null');
        }

        // ✅ داده اصلی داخل responseData['data'] هست
        final mainData = responseData['data'];

        print('🔍 2FA verification details:');
        print('   Main Data: $mainData');

        // استخراج داده‌ها بر اساس response واقعی
        final token = mainData?['token'];
        final dashboardUrl = mainData?['url'];
        final message = responseData['message'] ?? 'تم التحقق بنجاح';
        final agentData = mainData?['agent'];

        print('🔍 Extracted values:');
        print(
          '   Token: ${token != null ? "Exists (${token.substring(0, 20)}...)" : "Not found"}',
        );
        print('   Dashboard URL: $dashboardUrl');
        print('   Message: $message');
        print('   Agent Data: $agentData');

        // ذخیره توکن
        if (token != null && token is String) {
          agentToken.value = token;
          await _apiService.storeAgentToken(token);
          print('✅ Stored Agent Token: ${token.substring(0, 20)}...');
        } else {
          print('⚠️ Token not found in response!');
        }

        // ذخیره URL داشبورد
        if (dashboardUrl != null && dashboardUrl is String) {
          await _apiService.storeDashboardUrl(dashboardUrl);
          print('✅ Stored Dashboard URL: $dashboardUrl');
        } else {
          print('⚠️ Dashboard URL not found in response!');
        }

        // ذخیره اطلاعات agent
        if (agentData != null && agentData is Map) {
          final agentName = agentData['name']?.toString();
          final agentEmail = agentData['email']?.toString();
          final agentIdFromResponse = agentData['id']?.toString();

          if (agentName != null && agentName.isNotEmpty && name.value.isEmpty) {
            name.value = agentName;
            print('✅ Updated agent name: $agentName');
          }

          if (agentEmail != null && agentEmail.isNotEmpty) {
            await Constants.localStorage.write('agent_email', agentEmail);
            print('✅ Stored agent email: $agentEmail');
          }
        }

        is2FAVerified.value = true;

        // انتقال به صفحه اصلی
        Get.offAllNamed('/content');

        // Get.snackbar(
        //   'تم التحقق بنجاح',
        //   message,
        //   backgroundColor: Colors.green[50],
        //   colorText: Colors.green[800],
        //   duration: const Duration(seconds: 2),
        //   snackPosition: SnackPosition.TOP,
        // );
      } else {
        final errorMessage =
            result['error'] ?? result['message'] ?? 'فشل التحقق';
        print('❌ 2FA verification failed: $errorMessage');

        twoFAError.value = errorMessage;

        Get.snackbar(
          'خطأ في التحقق',
          errorMessage,
          backgroundColor: Colors.red[50],
          colorText: Colors.red[800],
          duration: const Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      print('❌ 2FA verification exception: $e');
      print('❌ Stack trace: ${e.toString()}');

      twoFAError.value = 'حدث خطأ غير متوقع: $e';

      Get.snackbar(
        'خطأ',
        'حدث خطأ غير متوقع: ${e.toString()}',
        backgroundColor: Colors.red[50],
        colorText: Colors.red[800],
        duration: const Duration(seconds: 3),
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // اضافه به AgentAuthController
  String? getDashboardUrl() {
    return _apiService.getDashboardUrl();
  }

  // Logout agent
  Future<void> logout() async {
    final token = agentToken.value;
    if (token != null) {
      try {
        await _apiService.logoutAgent(token);
      } catch (e) {
        debugPrint('Logout error: $e');
      }
    }

    // Clear all data
    await _apiService.clearAgentData();

    // Reset state
    name.value = '';
    email.value = '';
    password.value = '';
    activationCode.value = '';
    twoFACode.value = '';
    agentId.value = null;
    agentToken.value = null;
    isRegistered.value = false;
    isActivated.value = false;
    isLoggedIn.value = false;
    is2FAVerified.value = false;
    currentStep.value = 0;

    Get.offAllNamed('/agent/login');

    Get.snackbar(
      'تم تسجيل الخروج',
      'تم تسجيل خروجك بنجاح',
      backgroundColor: Colors.blue[50],
      colorText: Colors.blue[800],
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  // Check if user should see agent auth flow
  bool shouldShowAgentAuth() {
    final token = _apiService.getAgentToken();
    return token == null;
  }

  // Go to specific step
  void goToStep(int step) {
    if (step >= 0 && step <= 3) {
      currentStep.value = step;
    }
  }

  // Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال البريد الإلكتروني';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value)) {
      return 'صيغة البريد الإلكتروني غير صحيحة';
    }

    return null;
  }

  // Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كلمة المرور';
    }

    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }

    return null;
  }

  // Validate name
  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال الاسم';
    }

    if (value.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }

    return null;
  }

  // Validate activation code
  String? validateActivationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'الرجاء إدخال كود التفعيل';
    }

    return null;
  }
}
