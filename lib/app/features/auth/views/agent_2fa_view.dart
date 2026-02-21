import 'package:admin/app/core/services/location_service.dart';
import 'package:admin/app/features/auth/controllers/agent_auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

class Agent2FAView extends StatefulWidget {
  const Agent2FAView({super.key});

  @override
  State<Agent2FAView> createState() => _Agent2FAViewState();
}

class _Agent2FAViewState extends State<Agent2FAView> {
  final AgentAuthController controller = Get.find<AgentAuthController>();
  final TextEditingController codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  // Location data
  double? _latitude;
  double? _longitude;
  bool _isGettingLocation = false;
  bool _locationError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _codeFocusNode.requestFocus();
      _requestLocation();
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _requestLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationError = false;
    });

    try {
      final position = await LocationService.getCurrentPosition();

      if (position != null) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationError = false;
        });

        print('📍 Location obtained: $_latitude, $_longitude');

        // ✅ فقط یک اسنک بار خیلی ساده و سریع
        if (mounted) {
          // Get.snackbar(
          //   'تم تحديد الموقع',
          //   '',
          //   backgroundColor: Colors.green,
          //   colorText: Colors.white,
          //   duration: const Duration(seconds: 1),
          //   snackPosition: SnackPosition.TOP,
          //   margin: const EdgeInsets.all(8),
          //   borderRadius: 8,
          // );
        }
      } else {
        // ❌ اگر نتونستیم موقعیت بگیریم، خطا نشون می‌دیم
        setState(() {
          _locationError = true;
        });

        if (mounted) {
          await LocationService.showLocationErrorDialog(
            context,
            onRetry: () {
              Navigator.pop(context);
              _requestLocation();
            },
          );
        }
      }
    } catch (e) {
      print('❌ Location error: $e');
      setState(() {
        _locationError = true;
      });

      if (mounted) {
        await LocationService.showLocationErrorDialog(
          context,
          onRetry: () {
            Navigator.pop(context);
            _requestLocation();
          },
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  // دکمه موقعیت - ساده و بدون گزینه تغییر
  Widget _buildLocationStatus() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isGettingLocation) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: colorScheme.surface.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  colorScheme.secondary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'جاري تحديد الموقع...',
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontFamily: 'dijlah',
              ),
            ),
          ],
        ),
      );
    }

    if (_locationError) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(Icons.error, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  'فشل تحديد الموقع',
                  style: TextStyle(color: Colors.red, fontFamily: 'dijlah'),
                ),
              ],
            ),
            TextButton.icon(
              onPressed: _requestLocation,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('إعادة المحاولة'),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
            ),
          ],
        ),
      );
    }

    if (_latitude != null && _longitude != null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, color: Colors.green, size: 16),
            const SizedBox(width: 8),
            Text(
              'تم تحديد الموقع',
              style: TextStyle(
                color: Colors.green,
                fontFamily: 'dijlah',
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
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
                  const SizedBox(height: 40),

                  // عنوان
                  Text(
                    'التحقق الثنائي',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                      fontFamily: 'dijlah',
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'أدخل رمز التحقق المكون من 6 أرقام',
                    style: TextStyle(
                      fontSize: 16,
                      color: colorScheme.onPrimary.withOpacity(0.7),
                      fontFamily: 'dijlah',
                    ),
                  ),

                  const SizedBox(height: 30),

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
                        Icons.security,
                        size: 50,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  Obx(() {
                    final email = controller.email.value;
                    if (email.isNotEmpty) {
                      return Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'تم الإرسال إلى ',
                                style: TextStyle(
                                  color: colorScheme.onPrimary.withOpacity(0.7),
                                  fontFamily: 'dijlah',
                                ),
                              ),
                              TextSpan(
                                text: email,
                                style: TextStyle(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                      'يرجى إدخال رمز التحقق المرسل إلى تطبيق Google Authenticator لإكمال عملية التحقق',
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onPrimary.withOpacity(0.7),
                        fontFamily: 'dijlah',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // فیلد کد 2FA
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
                          if (value.length == 6 &&
                              _latitude != null &&
                              _longitude != null) {
                            _submitCode(value);
                          }
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Obx(() {
                    if (controller.twoFAError.value.isNotEmpty) {
                      return Text(
                        controller.twoFAError.value,
                        style: TextStyle(
                          color: theme.colorScheme.error,
                          fontFamily: 'dijlah',
                        ),
                        textAlign: TextAlign.center,
                      );
                    }
                    return const SizedBox();
                  }),

                  const SizedBox(height: 30),

                  // دکمه تأیید - فقط وقتی موقعیت داریم فعال میشه
                  Obx(() {
                    final isLocationReady =
                        _latitude != null && _longitude != null;
                    final isCodeValid = codeController.text.length == 6;
                    final isButtonEnabled =
                        !controller.isLoading.value &&
                        isLocationReady &&
                        isCodeValid;

                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: isButtonEnabled
                            ? () => _submitCode(codeController.text)
                            : null,
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
                                'تأكيد',
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

    controller.verify2FA(code, lat: _latitude, lon: _longitude);
  }
}
