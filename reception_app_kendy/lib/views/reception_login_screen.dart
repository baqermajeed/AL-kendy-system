import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reception_app_kendy/core/constants/app_colors.dart';
import 'package:reception_app_kendy/core/constants/app_strings.dart';
import 'package:reception_app_kendy/core/widgets/custom_text_field.dart';
import 'package:reception_app_kendy/core/widgets/back_button_widget.dart';
import 'package:reception_app_kendy/controllers/auth_controller.dart';

class ReceptionLoginScreen extends StatefulWidget {
  const ReceptionLoginScreen({super.key});

  @override
  State<ReceptionLoginScreen> createState() => _ReceptionLoginScreenState();
}

class _ReceptionLoginScreenState extends State<ReceptionLoginScreen> {
  final AuthController _authController = Get.find<AuthController>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    SizedBox(height: 56.h),
                    SizedBox(height: 12.h),
                    SizedBox(
                      height: 250.h,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            child: Opacity(
                              opacity: 0.85,
                              child: Image.asset(
                                'assets/images/tooth_logo.png',
                                width: 280.w,
                                height: 280.h,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.medical_services_outlined,
                                    size: 180.sp,
                                    color: AppColors.primary
                                        .withValues(alpha: 0.3),
                                  );
                                },
                              ),
                            ),
                          ),
                          Image.asset(
                            'assets/images/logo.png',
                            width: 140.w,
                            height: 140.h,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 140.w,
                                height: 140.h,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryLight
                                      .withValues(alpha: 0.3),
                                ),
                                child: Icon(
                                  Icons.local_hospital,
                                  size: 70.sp,
                                  color: AppColors.primary,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      AppStrings.receptionLogin,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      labelText: AppStrings.receptionUsername,
                      hintText: 'اسم المستخدم',
                      controller: _usernameController,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: AppStrings.password,
                      hintText: '••••••••',
                      controller: _passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 24.h),
                    Obx(
                      () => Container(
                        width: double.infinity,
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: _authController.isLoading.value
                              ? AppColors.textHint
                              : AppColors.secondary,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _authController.isLoading.value
                                ? null
                                : () async {
                                    if (_usernameController.text.isEmpty ||
                                        _passwordController.text.isEmpty) {
                                      Get.snackbar(
                                        'خطأ',
                                        'يرجى إدخال اسم المستخدم وكلمة المرور',
                                        snackPosition: SnackPosition.TOP,
                                      );
                                      return;
                                    }
                                    await _authController.loginReception(
                                      username:
                                          _usernameController.text.trim(),
                                      password: _passwordController.text,
                                    );
                                  },
                            borderRadius: BorderRadius.circular(16.r),
                            child: Center(
                              child: _authController.isLoading.value
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.white),
                                      ),
                                    )
                                  : Text(
                                      AppStrings.login,
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.white,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(top: 16.h, left: 16, child: BackButtonWidget()),
          ],
        ),
      ),
    );
  }
}
