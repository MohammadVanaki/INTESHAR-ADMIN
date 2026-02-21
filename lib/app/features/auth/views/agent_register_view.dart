import 'package:admin/app/features/auth/controllers/agent_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgentRegisterView extends StatefulWidget {
  const AgentRegisterView({super.key});

  @override
  State<AgentRegisterView> createState() => _AgentRegisterViewState();
}

class _AgentRegisterViewState extends State<AgentRegisterView> {
  final AgentAuthController controller = Get.find<AgentAuthController>();
  final TextEditingController nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    _nameFocusNode.dispose();
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

                    // لوگو و عنوان
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: colorScheme.secondary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(60),
                            ),
                            child: Icon(
                              Icons.person_add,
                              size: 60,
                              color: colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'تسجيل الوكيل',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.secondary,
                              fontFamily: 'dijlah',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'أدخل اسمك لبدء عملية التسجيل',
                            style: TextStyle(
                              fontSize: 16,
                              color: colorScheme.onPrimary.withOpacity(0.7),
                              fontFamily: 'dijlah',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 48),

                    // فیلد اسم
                    Text(
                      'الاسم الكامل',
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
                        controller: nameController,
                        focusNode: _nameFocusNode,
                        keyboardType: TextInputType.name,
                        textInputAction: TextInputAction.done,
                        style: TextStyle(
                          fontSize: 16,
                          color: colorScheme.onPrimary,
                          fontFamily: 'dijlah',
                        ),
                        decoration: InputDecoration(
                          hintText: 'أدخل اسمك الكامل',
                          hintStyle: TextStyle(
                            color: colorScheme.onPrimary.withOpacity(0.5),
                            fontFamily: 'dijlah',
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline,
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
                              color: controller.nameError.value.isNotEmpty
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
                          errorText: controller.nameError.value.isNotEmpty
                              ? controller.nameError.value
                              : null,
                          errorStyle: TextStyle(
                            fontFamily: 'dijlah',
                            color: theme.colorScheme.error,
                          ),
                        ),
                        validator: controller.validateName,
                        onChanged: (value) {
                          if (controller.nameError.value.isNotEmpty) {
                            controller.nameError.value = '';
                          }
                        },
                        onFieldSubmitted: (_) {
                          _submitForm();
                        },
                      );
                    }),

                    const SizedBox(height: 8),

                    Text(
                      'سوف نرسل كود التفعيل لك بعد التسجيل',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary.withOpacity(0.5),
                        fontFamily: 'dijlah',
                      ),
                    ),

                    const SizedBox(height: 40),

                    // دکمه ادامه
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
                                  'متابعة',
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
      ),
    );
  }

  void _submitForm() {
    FocusScope.of(context).unfocus();
    print('Submitting form with name: ${nameController.text.trim()}');
    if (_formKey.currentState!.validate()) {
      controller.registerAgent(nameController.text.trim());
    }
  }
}
