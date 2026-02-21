import 'package:admin/app/features/auth/controllers/agent_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class AgentActivateView extends StatefulWidget {
  const AgentActivateView({super.key});

  @override
  State<AgentActivateView> createState() => _AgentActivateViewState();
}

class _AgentActivateViewState extends State<AgentActivateView> {
  final AgentAuthController controller = Get.find<AgentAuthController>();
  final TextEditingController codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 56,
      height: 56,
      textStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimary,
        fontFamily: 'dijlah',
      ),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? colorScheme.surface.withOpacity(0.5)
            : theme.inputDecorationTheme.fillColor,
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? colorScheme.surface
              : Colors.transparent,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: colorScheme.secondary, width: 2),
      color: colorScheme.primary,
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration?.copyWith(
        color: colorScheme.secondary,
      ),
      textStyle: defaultPinTheme.textStyle?.copyWith(
        color: colorScheme.onSecondary,
      ),
    );

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    'تفعيل الحساب',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                      fontFamily: 'dijlah',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'أدخل كود التفعيل الذي استلمته',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onPrimary.withOpacity(0.7),
                      fontFamily: 'dijlah',
                    ),
                  ),

                  const SizedBox(height: 40),

                  // آیکون
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified_user,
                        size: 50,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // نمایش نام کاربر (از controller بگیر)
                  Obx(() {
                    final name = controller.name.value;
                    if (name.isNotEmpty) {
                      return Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'مرحباً ',
                                style: TextStyle(
                                  color: colorScheme.onPrimary.withOpacity(0.7),
                                  fontFamily: 'dijlah',
                                ),
                              ),
                              TextSpan(
                                text: name,
                                style: TextStyle(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  fontFamily: 'dijlah',
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox();
                  }),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'يرجى ادخال كود التفعيل',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        fontFamily: 'dijlah',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // فیلد کد فعال‌سازی
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Center(
                      child: Pinput(
                        length: 6,
                        controller: codeController,
                        focusNode: _codeFocusNode,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: submittedPinTheme,
                        showCursor: true,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        keyboardType: TextInputType.number,

                        onCompleted: (pin) {
                          _submitCode(pin);
                        },
                        onChanged: (value) {
                          if (value.length == 6) {
                            _submitCode(value);
                          }
                        },
                        // separator: const SizedBox(width: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Obx(() {
                    if (controller.activationCodeError.value.isNotEmpty) {
                      return Text(
                        controller.activationCodeError.value,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontFamily: 'dijlah',
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                    return const SizedBox();
                  }),

                  const SizedBox(height: 40),

                  Obx(() {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.isLoading.value
                            ? null
                            : () {
                                if (codeController.text.length == 6) {
                                  _submitCode(codeController.text);
                                } else {
                                  Get.snackbar(
                                    'خطأ',
                                    'الرجاء إدخال كود التفعيل المكون من 6 أرقام',
                                    duration: const Duration(seconds: 3),
                                    snackPosition: SnackPosition.TOP,
                                    backgroundColor: colorScheme.error,
                                    colorText: colorScheme.onError,
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    colorScheme.onSecondary,
                                  ),
                                ),
                              )
                            : Text(
                                'تفعيل الحساب',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onSecondary,
                                  fontFamily: 'dijlah',
                                ),
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitCode(String code) {
    FocusScope.of(context).unfocus();
    controller.activateAgent(code);
  }
}
