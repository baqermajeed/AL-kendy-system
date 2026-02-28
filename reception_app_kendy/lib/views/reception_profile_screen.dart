import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reception_app_kendy/core/constants/app_colors.dart';
import 'package:reception_app_kendy/core/constants/app_strings.dart';
import 'package:reception_app_kendy/core/widgets/custom_button.dart';
import 'package:reception_app_kendy/core/widgets/back_button_widget.dart';
import 'package:reception_app_kendy/controllers/auth_controller.dart';
import 'package:reception_app_kendy/core/utils/image_utils.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReceptionProfileScreen extends StatelessWidget {
  const ReceptionProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.onboardingBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                child: Row(
                  textDirection: TextDirection.ltr,
                  children: [
                    const BackButtonWidget(),
                    Expanded(
                      child: Center(
                        child: Text(
                          AppStrings.receptionProfile,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 40.w),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Obx(() {
                final user = authController.currentUser.value;
                final validUrl = ImageUtils.convertToValidUrl(user?.imageUrl);
                final hasImage =
                    validUrl != null && ImageUtils.isValidImageUrl(validUrl);

                return CircleAvatar(
                  radius: 60.r,
                  backgroundColor: AppColors.primaryLight,
                  child: ClipOval(
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: validUrl!,
                            width: 120.r,
                            height: 120.r,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration.zero,
                            fadeOutDuration: Duration.zero,
                            memCacheWidth: 240,
                            memCacheHeight: 240,
                            placeholder: (context, url) => Container(
                              color: AppColors.primaryLight,
                              child: Center(
                                child: Icon(
                                  Icons.person,
                                  size: 60.sp,
                                  color: AppColors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.person,
                              size: 60.sp,
                              color: AppColors.white,
                            ),
                          )
                        : Icon(
                            Icons.person,
                            size: 60.sp,
                            color: AppColors.white,
                          ),
                  ),
                );
              }),
              SizedBox(height: 32.h),
              Obx(() {
                final user = authController.currentUser.value;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.divider,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          user?.name ?? 'موظف الاستقبال',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        AppStrings.receptionUsername,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.divider,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          user?.phoneNumber ?? user?.name ?? 'reception_user',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        AppStrings.phoneNumber,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.divider,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          user?.phoneNumber ?? 'غير محدد',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'المنصب',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.divider,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          'موظف استقبال',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      SizedBox(height: 32.h),
                      CustomButton(
                        text: AppStrings.logout,
                        onPressed: () async {
                          await authController.logout();
                        },
                        backgroundColor: AppColors.error,
                        width: double.infinity,
                        icon: Icon(
                          Icons.exit_to_app,
                          color: AppColors.white,
                          size: 20.sp,
                        ),
                      ),
                      SizedBox(height: 32.h),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
