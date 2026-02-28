import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reception_app_kendy/core/constants/app_colors.dart';
import 'package:reception_app_kendy/core/utils/image_utils.dart';
import 'package:reception_app_kendy/controllers/auth_controller.dart';
import 'package:reception_app_kendy/models/patient_model.dart';
import 'package:reception_app_kendy/services/patient_service.dart';
import 'package:reception_app_kendy/views/patient_detail_screen.dart';
import 'package:reception_app_kendy/views/add_patient_screen.dart';
import 'package:reception_app_kendy/views/reception_profile_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ReceptionHomeScreen extends StatefulWidget {
  const ReceptionHomeScreen({super.key});

  @override
  State<ReceptionHomeScreen> createState() => _ReceptionHomeScreenState();
}

class _ReceptionHomeScreenState extends State<ReceptionHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;
  final AuthController _authController = Get.find<AuthController>();
  final PatientService _patientService = PatientService();
  final RxList<PatientModel> _patients = <PatientModel>[].obs;
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _searchQuery.value = _searchController.text;
    });
    _loadPatients();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPatients() async {
    _isLoading.value = true;
    try {
      final list = await _patientService.getAllPatients();
      _patients.value = list;
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      _isLoading.value = false;
    }
  }

  List<PatientModel> _getFilteredPatients() {
    final q = _searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return _patients;
    return _patients
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.phoneNumber.contains(q) ||
            p.city.toLowerCase().contains(q))
        .toList();
  }

  void _openAddPatient() async {
    await Get.to(() => const AddPatientScreen());
    _loadPatients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.receptionHomeBackground,
      body: SafeArea(
        child: Column(
          children: [
            // Header - مطابق للفرونت
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Get.to(() => const ReceptionProfileScreen()),
                    child: Obx(() {
                      final user = _authController.currentUser.value;
                      final imageUrl = user?.imageUrl;
                      final validImageUrl =
                          ImageUtils.convertToValidUrl(imageUrl);

                      return Container(
                        width: 50.w,
                        height: 50.w,
                        padding: EdgeInsets.all(1.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF5B97D0),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              offset: const Offset(0, 4),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundColor: AppColors.primary,
                          child: (validImageUrl != null &&
                                  ImageUtils.isValidImageUrl(validImageUrl))
                              ? ClipOval(
                                  child: CachedNetworkImage(
                                    imageUrl: validImageUrl,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fadeInDuration: Duration.zero,
                                    fadeOutDuration: Duration.zero,
                                    placeholder: (context, url) =>
                                        Container(color: AppColors.primary),
                                    errorWidget: (context, url, error) => Icon(
                                      Icons.person,
                                      color: AppColors.white,
                                      size: 20.sp,
                                    ),
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  color: AppColors.white,
                                  size: 20.sp,
                                ),
                        ),
                      );
                    }),
                  ),
                  Text(
                    'الصفحة الرئيسية',
                    style: GoogleFonts.cairo(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF505558),
                    ),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          // QR/Barcode - إن وُجدت شاشة ماسح ضوئي يمكن التوجيه لها
                        },
                        child: Image.asset(
                          'assets/images/barcode.png',
                          width: 30.sp,
                          height: 30.sp,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.qr_code_scanner,
                            color: AppColors.primary,
                            size: 30.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      GestureDetector(
                        onTap: _openAddPatient,
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.person_add,
                            color: AppColors.primary,
                            size: 30.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search Bar with Calendar Icon
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 45.h,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            width: 1,
                            color: const Color(0x80649FCC),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.divider.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _searchQuery.value = value,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          decoration: InputDecoration(
                            hintText: 'ابحث عن مريض...',
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            prefixIconConstraints: const BoxConstraints(
                                minWidth: 0, minHeight: 0),
                            prefixIcon: Padding(
                              padding: EdgeInsetsDirectional.only(start: 12.w),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.search,
                                    color: AppColors.textSecondary,
                                    size: 24.sp,
                                  ),
                                  SizedBox(width: 8.w),
                                  Container(
                                    width: 1.5.w,
                                    height: 24.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0x80649FCC),
                                      borderRadius: BorderRadius.circular(2.r),
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () {
                      // المواعيد - إن وُجدت شاشة مواعيد
                    },
                    child: Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.divider.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.calendar_today_outlined,
                            color: AppColors.primary,
                            size: 24.sp,
                          ),
                        ),
                        Positioned(
                          right: 8.w,
                          top: 8.h,
                          child: Container(
                            width: 8.w,
                            height: 8.h,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h, top: 8.h),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'جميع المرضى',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.cairo(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                    Obx(() {
                      final allPatients = _getFilteredPatients();

                      if (_isLoading.value) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.h),
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }

                      if (allPatients.isEmpty) {
                        return Container(
                          padding: EdgeInsets.all(32.h),
                          alignment: Alignment.center,
                          child: Text(
                            'لا يوجد مرضى',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: allPatients.length,
                        itemBuilder: (context, index) {
                          final patient = allPatients[index];
                          return _buildPatientCard(patient);
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientCard(PatientModel patient) {
    return GestureDetector(
      onTap: () async {
        await Get.to(() => PatientDetailScreen(patient: patient));
        _loadPatients();
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.only(left: 20.w, right: 0.w, top: 2.h, bottom: 2.h),
        constraints: BoxConstraints(minHeight: 72.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Transform.translate(
                  offset: Offset(-8.w, 0),
                  child: Container(
                    width: 55.w,
                    height: 60.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: Builder(
                        builder: (context) {
                          final imageUrl = patient.imageUrl;
                          final validImageUrl =
                              ImageUtils.convertToValidUrl(imageUrl);

                          if (validImageUrl != null &&
                              ImageUtils.isValidImageUrl(validImageUrl)) {
                            return CachedNetworkImage(
                              imageUrl: validImageUrl,
                              fit: BoxFit.cover,
                              width: 55.w,
                              height: 60.h,
                              fadeInDuration: Duration.zero,
                              fadeOutDuration: Duration.zero,
                              memCacheWidth: 160,
                              memCacheHeight: 170,
                              placeholder: (context, url) => Container(
                                width: 55.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.white,
                                  size: 30.sp,
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 55.w,
                                height: 60.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.r),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.primary,
                                      AppColors.secondary,
                                    ],
                                  ),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.white,
                                  size: 30.sp,
                                ),
                              ),
                            );
                          }

                          return Container(
                            width: 55.w,
                            height: 60.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.r),
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.primary,
                                  AppColors.secondary,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.person,
                              color: AppColors.white,
                              size: 30.sp,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      textDirection: TextDirection.rtl,
                      children: [
                        RichText(
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                            children: [
                              TextSpan(
                                text: 'الاسم : ',
                                style: GoogleFonts.cairo(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF505558),
                                ),
                              ),
                              TextSpan(
                                text: patient.name,
                                style: GoogleFonts.cairo(
                                  color: AppColors.primary,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'العمر : ${patient.age} سنة',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF505558),
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'نوع العلاج : ${patient.treatmentHistory != null && patient.treatmentHistory!.isNotEmpty ? patient.treatmentHistory!.last : 'لا يوجد'}',
                          style: GoogleFonts.cairo(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF505558),
                          ),
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            if (patient.doctorIds.isEmpty)
              Positioned(
                right: 8.w,
                top: 8.h,
                child: Container(
                  width: 12.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.white, width: 2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
