import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:reception_app_kendy/core/constants/app_colors.dart';
import 'package:reception_app_kendy/core/constants/app_strings.dart';
import 'package:reception_app_kendy/core/widgets/custom_text_field.dart';
import 'package:reception_app_kendy/core/widgets/back_button_widget.dart';
import 'package:reception_app_kendy/models/patient_model.dart';
import 'package:reception_app_kendy/services/patient_service.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final PatientService _patientService = PatientService();
  final ImagePicker _imagePicker = ImagePicker();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _ageController = TextEditingController();

  String? _selectedGender;
  String? _selectedVisitType = AppStrings.newPatient;
  String? _selectedCity;
  File? _pickedImage;
  bool _isLoading = false;

  static const List<String> _cities = [
    'بغداد', 'البصرة', 'النجف الاشرف', 'كربلاء', 'الموصل', 'أربيل',
    'السليمانية', 'ديالى', 'الديوانية', 'المثنى', 'كركوك', 'واسط',
    'ميسان', 'الأنبار', 'ذي قار', 'بابل', 'دهوك', 'صلاح الدين',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  bool _validate() {
    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('خطأ', 'أدخل اسم المريض');
      return false;
    }
    final phone = _phoneController.text.trim();
    if (!RegExp(r'^07\d{9}$').hasMatch(phone)) {
      Get.snackbar('خطأ', 'رقم الهاتف يجب أن يبدأ بـ 07 ويتكون من 11 رقماً');
      return false;
    }
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 1 || age > 150) {
      Get.snackbar('خطأ', 'أدخل عمراً صحيحاً');
      return false;
    }
    if (_selectedGender == null) {
      Get.snackbar('خطأ', 'اختر الجنس');
      return false;
    }
    if (_selectedCity == null) {
      Get.snackbar('خطأ', 'اختر المدينة');
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    if (!_validate() || _isLoading) return;
    setState(() => _isLoading = true);
    try {
      final created = await _patientService.createPatientForReception(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        gender: _selectedGender!,
        age: int.parse(_ageController.text.trim()),
        city: _selectedCity!,
        visitType: _selectedVisitType,
      );
      if (_pickedImage != null) {
        await _patientService.uploadPatientImageForReception(
          patientId: created.id,
          imageFile: _pickedImage!,
        );
      }
      Get.snackbar('نجح', 'تمت إضافة المريض');
      Get.back();
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file != null) setState(() => _pickedImage = File(file.path));
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
                    GestureDetector(
                      onTap: _pickImage,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            radius: 60.r,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: _pickedImage != null
                                ? FileImage(_pickedImage!)
                                : null,
                            child: _pickedImage == null
                                ? Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.person,
                                        size: 52.sp,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        'إضافة صورة المريض',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 10.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 4.h,
                            right: 4.w,
                            child: Container(
                              width: 34.w,
                              height: 34.w,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt,
                                color: AppColors.white,
                                size: 18.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'اضافة مريض',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      labelText: AppStrings.name,
                      hintText: 'الاسم',
                      controller: _nameController,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: AppStrings.phoneNumber,
                      hintText: '07xxxxxxxxx',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      maxLength: 11,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      labelText: AppStrings.age,
                      hintText: 'العمر',
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.gender,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                                AppStrings.male,
                                textDirection: TextDirection.rtl),
                            value: 'male',
                            groupValue: _selectedGender,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                                AppStrings.female,
                                textDirection: TextDirection.rtl),
                            value: 'female',
                            groupValue: _selectedGender,
                            onChanged: (v) =>
                                setState(() => _selectedGender = v),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.visitType,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                                AppStrings.newPatient,
                                textDirection: TextDirection.rtl),
                            value: AppStrings.newPatient,
                            groupValue: _selectedVisitType,
                            onChanged: (v) =>
                                setState(() => _selectedVisitType = v),
                            activeColor: AppColors.primary,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: Text(
                                AppStrings.returningPatient,
                                textDirection: TextDirection.rtl),
                            value: AppStrings.returningPatient,
                            groupValue: _selectedVisitType,
                            onChanged: (v) =>
                                setState(() => _selectedVisitType = v),
                            activeColor: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        AppStrings.city,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(20.r)),
                          ),
                          builder: (ctx) => Container(
                            padding: EdgeInsets.symmetric(vertical: 16.h),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _cities.length,
                              itemBuilder: (_, i) {
                                final city = _cities[i];
                                return ListTile(
                                  title: Text(
                                    city,
                                    textAlign: TextAlign.right,
                                  ),
                                  onTap: () {
                                    setState(() => _selectedCity = city);
                                    Navigator.pop(ctx);
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 16.h),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.divider.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(Icons.arrow_drop_down,
                                color: AppColors.textSecondary),
                            Text(
                              _selectedCity ?? AppStrings.selectCity,
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: _selectedCity != null
                                    ? AppColors.textPrimary
                                    : AppColors.textHint,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Container(
                      width: double.infinity,
                      height: 50.h,
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? AppColors.textHint
                            : AppColors.secondary,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _isLoading ? null : _submit,
                          borderRadius: BorderRadius.circular(16.r),
                          child: Center(
                            child: _isLoading
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.h,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.white),
                                    ),
                                  )
                                : Text(
                                    AppStrings.addButton,
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
                    SizedBox(height: 32.h),
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
