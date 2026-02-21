import 'package:admin/app/features/auth/controllers/agent_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgentLoginView extends StatefulWidget {
  const AgentLoginView({super.key});

  @override
  State<AgentLoginView> createState() => _AgentLoginViewState();
}

class _AgentLoginViewState extends State<AgentLoginView> {
  final AgentAuthController controller = Get.find<AgentAuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.primary,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              alignment: Alignment.center,
              constraints: const BoxConstraints(maxWidth: 500),
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // عنوان
                    Text(
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.secondary,
                        fontFamily: 'dijlah',
                      ),
                    ),

                    const SizedBox(height: 12),

                    Text(
                      'أدخل بيانات حسابك',
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
                        child: Image.asset(
                          'assets/images/inteshar-ag-app-co.png',
                          width: 150,
                          height: 150,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // فیلد ایمیل
                    Text(
                      'البريد الإلكتروني',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimary,
                        fontFamily: 'dijlah',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Obx(() {
                      return TextFormField(
                        controller: emailController,
                        focusNode: _emailFocusNode,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimary,
                          fontFamily: 'dijlah',
                        ),
                        decoration: InputDecoration(
                          hintText: 'example@email.com',
                          hintStyle: TextStyle(
                            color: colorScheme.onPrimary.withOpacity(0.5),
                            fontFamily: 'dijlah',
                          ),
                          prefixIcon: Icon(
                            Icons.email_outlined,
                            color: colorScheme.secondary,
                          ),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? colorScheme.surface.withOpacity(0.5)
                              : theme.inputDecorationTheme.fillColor,
                          border: theme.inputDecorationTheme.border,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: controller.emailError.value.isNotEmpty
                                  ? theme.colorScheme.error
                                  : Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          errorText: controller.emailError.value.isNotEmpty
                              ? controller.emailError.value
                              : null,
                          errorStyle: TextStyle(
                            fontFamily: 'dijlah',
                            color: theme.colorScheme.error,
                          ),
                        ),
                        validator: controller.validateEmail,
                        onChanged: (value) {
                          if (controller.emailError.value.isNotEmpty) {
                            controller.emailError.value = '';
                          }
                        },
                        onFieldSubmitted: (_) {
                          FocusScope.of(
                            context,
                          ).requestFocus(_passwordFocusNode);
                        },
                      );
                    }),

                    const SizedBox(height: 20),

                    // فیلد رمز عبور
                    Text(
                      'كلمة المرور',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimary,
                        fontFamily: 'dijlah',
                      ),
                    ),

                    const SizedBox(height: 8),

                    Obx(() {
                      return TextFormField(
                        controller: passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: !controller.showPassword.value,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimary,
                          fontFamily: 'dijlah',
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل كلمة المرور',
                          hintStyle: TextStyle(
                            color: colorScheme.onPrimary.withOpacity(0.5),
                            fontFamily: 'dijlah',
                          ),
                          prefixIcon: Icon(
                            Icons.lock_outline,
                            color: colorScheme.secondary,
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              controller.showPassword.toggle();
                            },
                            icon: Icon(
                              controller.showPassword.value
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: colorScheme.onPrimary.withOpacity(0.6),
                            ),
                          ),
                          filled: true,
                          fillColor: theme.brightness == Brightness.dark
                              ? colorScheme.surface.withOpacity(0.5)
                              : theme.inputDecorationTheme.fillColor,
                          border: theme.inputDecorationTheme.border,
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: controller.passwordError.value.isNotEmpty
                                  ? theme.colorScheme.error
                                  : Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: colorScheme.secondary,
                              width: 2,
                            ),
                          ),
                          errorText: controller.passwordError.value.isNotEmpty
                              ? controller.passwordError.value
                              : null,
                          errorStyle: TextStyle(
                            fontFamily: 'dijlah',
                            color: theme.colorScheme.error,
                          ),
                        ),
                        validator: controller.validatePassword,
                        onChanged: (value) {
                          if (controller.passwordError.value.isNotEmpty) {
                            controller.passwordError.value = '';
                          }
                        },
                        onFieldSubmitted: (_) {
                          _submitForm();
                        },
                      );
                    }),

                    const SizedBox(height: 8),

                    const SizedBox(height: 40),

                    // دکمه ورود
                    Obx(() {
                      return SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: controller.isLoading.value
                              ? null
                              : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colorScheme.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
                                  'تسجيل الدخول',
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

                    const SizedBox(height: 20),

                    // توضیحات
                    Center(
                      child: Text(
                        'يجب أن يكون حسابك مفعلاً مسبقاً',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onPrimary.withOpacity(0.5),
                          fontFamily: 'dijlah',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      controller.loginAgent1(
        emailController.text.trim(),
        passwordController.text,
      );
    }
  }
}
