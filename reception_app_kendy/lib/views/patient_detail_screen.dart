import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reception_app_kendy/core/constants/app_colors.dart';
import 'package:reception_app_kendy/core/constants/app_strings.dart';
import 'package:reception_app_kendy/core/utils/image_utils.dart';
import 'package:reception_app_kendy/core/widgets/back_button_widget.dart';
import 'package:reception_app_kendy/models/patient_model.dart';
import 'package:reception_app_kendy/models/doctor_model.dart';
import 'package:reception_app_kendy/models/gallery_image_model.dart';
import 'package:reception_app_kendy/services/patient_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

// ظل البطاقات - مطابق للفرونت
const List<BoxShadow> kPatientFileShadow = [
  BoxShadow(
    color: Color(0x14000000),
    blurRadius: 12,
    offset: Offset(0, 6),
  ),
];

class PatientDetailScreen extends StatefulWidget {
  final PatientModel patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  final PatientService _patientService = PatientService();
  final ImagePicker _imagePicker = ImagePicker();

  final RxList<GalleryImageModel> _galleryImages = <GalleryImageModel>[].obs;
  final RxBool _galleryLoading = false.obs;
  final RxList<DoctorModel> _patientDoctors = <DoctorModel>[].obs;
  final RxBool _isLoadingDoctors = false.obs;

  @override
  void initState() {
    super.initState();
    _loadGallery();
    _loadPatientDoctors();
  }

  Future<void> _loadGallery() async {
    _galleryLoading.value = true;
    try {
      final list =
          await _patientService.getReceptionPatientGallery(widget.patient.id);
      _galleryImages.value = list;
    } catch (_) {}
    _galleryLoading.value = false;
  }

  Future<void> _loadPatientDoctors() async {
    _isLoadingDoctors.value = true;
    try {
      final doctors =
          await _patientService.getPatientDoctors(widget.patient.id);
      _patientDoctors.value = doctors;
    } catch (_) {
      _patientDoctors.clear();
    } finally {
      _isLoadingDoctors.value = false;
    }
  }

  Future<void> _addImage() async {
    final XFile? file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (file == null) return;
    try {
      Get.snackbar('', 'جاري رفع الصورة...');
      await _patientService.uploadReceptionGalleryImage(
        patientId: widget.patient.id,
        imageFile: File(file.path),
      );
      _loadGallery();
      Get.snackbar('نجح', 'تمت إضافة الصورة');
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    }
  }

  void _showTransferDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _SelectDoctorDialog(
        patient: widget.patient,
        patientService: _patientService,
        onDone: () {
          Navigator.of(ctx).pop();
          _loadPatientDoctors();
          Get.snackbar('نجح', 'تم التحويل');
        },
      ),
    );
  }

  void _showQrCodeDialog(BuildContext context, String patientId) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'رمز المريض',
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: QrImageView(
                  data: patientId,
                  version: QrVersions.auto,
                  size: 180.w,
                  backgroundColor: Colors.white,
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('إغلاق', style: TextStyle(color: AppColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;

    return Scaffold(
      backgroundColor: const Color(0xFFF4FEFF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NestedScrollView(
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return <Widget>[
                    // الهيدر - مطابق للفرونت
                    SliverAppBar(
                      backgroundColor: const Color(0xFFF4FEFF),
                      pinned: false,
                      floating: false,
                      expandedHeight: 0,
                      toolbarHeight: 80.h,
                      automaticallyImplyLeading: false,
                      flexibleSpace: Container(
                        color: const Color(0xFFF4FEFF),
                        padding: EdgeInsets.symmetric(
                          horizontal: 24.w,
                          vertical: 16.h,
                        ),
                        child: Row(
                          textDirection: ui.TextDirection.ltr,
                          children: [
                            const BackButtonWidget(),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'ملف المريض',
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 48.w),
                          ],
                        ),
                      ),
                    ),
                    // بطاقة بيانات المريض - مطابقة 100% للفرونت
                    SliverToBoxAdapter(
                      child: Container(
                        height: 156.h,
                        padding: EdgeInsets.zero,
                        margin: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: kPatientFileShadow,
                        ),
                        child: Row(
                          children: [
                            _buildPatientImage(patient),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  left: 0.w,
                                  top: 6.h,
                                  bottom: 6.h,
                                ),
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        'الاسم : ${patient.name}',
                                        style: GoogleFonts.cairo(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF649FCC),
                                        ),
                                        textAlign: TextAlign.right,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              _detailRow(
                                                  'العمر : ${patient.age} سنة'),
                                              SizedBox(height: 4.h),
                                              _detailRow(
                                                'الجنس: ${patient.gender == 'male' ? 'ذكر' : patient.gender == 'female' ? 'أنثى' : patient.gender}',
                                              ),
                                              SizedBox(height: 4.h),
                                              _detailRow(
                                                  'رقم الهاتف : ${patient.phoneNumber}'),
                                              SizedBox(height: 4.h),
                                              _detailRow(
                                                  'المدينة : ${patient.city}'),
                                              SizedBox(height: 4.h),
                                              _detailRow(
                                                'نوع العلاج : ${patient.treatmentHistory != null && patient.treatmentHistory!.isNotEmpty ? patient.treatmentHistory!.last : 'لا يوجد'}',
                                              ),
                                            ],
                                          ),
                                        ),
                                        Column(
                                          children: [
                                            GestureDetector(
                                              onTap: () =>
                                                  _showQrCodeDialog(
                                                      context, patient.id),
                                              child: Container(
                                                width: 70.w,
                                                height: 70.w,
                                                padding: EdgeInsets.all(0.w),
                                                decoration: BoxDecoration(
                                                  color: AppColors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: QrImageView(
                                                  data: patient.id,
                                                  version: QrVersions.auto,
                                                  size: 54.w,
                                                  backgroundColor:
                                                      Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // قسم الأطباء المعالجين - مطابق للفرونت
                    SliverToBoxAdapter(
                      child: _buildDoctorsSection(),
                    ),
                    // قسم المعرض (صور المريض)
                    SliverToBoxAdapter(
                      child: _buildGallerySection(),
                    ),
                  ];
                },
                body: Container(color: const Color(0xFFF4FEFF)),
              ),
            ),
            // زر التحويل في الأسفل - مطابق للفرونت
            Padding(
              padding: EdgeInsets.all(24.w),
              child: Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: ElevatedButton(
                  onPressed: _showTransferDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                  child: Text(
                    'تحويل',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientImage(PatientModel patient) {
    final validUrl = ImageUtils.convertToValidUrl(patient.imageUrl);
    return Container(
      width: 110.w,
      height: 156.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.r),
        child: validUrl != null && ImageUtils.isValidImageUrl(validUrl)
            ? CachedNetworkImage(
                imageUrl: validUrl,
                fit: BoxFit.cover,
                width: 110.w,
                height: 156.h,
                placeholder: (context, url) => _avatarPlaceholder(),
                errorWidget: (context, url, error) => _avatarPlaceholder(),
              )
            : _avatarPlaceholder(),
      ),
    );
  }

  Widget _avatarPlaceholder() {
    return Container(
      width: 110.w,
      height: 156.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Icon(
        Icons.person,
        color: AppColors.white,
        size: 40.sp,
      ),
    );
  }

  Widget _detailRow(String text) {
    return Align(
      alignment: Alignment.centerRight,
      child: Text(
        text,
        style: GoogleFonts.cairo(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF505558),
        ),
        textAlign: TextAlign.right,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDoctorsSection() {
    return Obx(() {
      if (_isLoadingDoctors.value) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
        );
      }

      return Container(
        margin: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'الاطباء المعالجون',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            if (_patientDoctors.isEmpty)
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'لم يتم تحويله الى طبيب حتى الان',
                      style: TextStyle(
                          fontSize: 14.sp, color: AppColors.error),
                      textAlign: TextAlign.right,
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.info_outline,
                      color: AppColors.error,
                      size: 20.sp,
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _patientDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = _patientDoctors[index];
                  final doctorName = doctor.name ?? 'طبيب';
                  final doctorInitials = doctorName.isNotEmpty
                      ? doctorName
                          .split(' ')
                          .map((n) => n.isNotEmpty ? n[0] : '')
                          .take(2)
                          .join()
                      : 'ط';

                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.only(
                      left: 0.w,
                      top: 10.w,
                      bottom: 10.w,
                      right: 0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.w,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.r),
                            child: _buildDoctorImage(doctor, doctorInitials),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                              left: 0.w,
                              top: 12.w,
                              bottom: 12.w,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'د. $doctorName',
                                    style: TextStyle(
                                      fontSize: 17.sp,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                                SizedBox(height: 6.h),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    'الاختصاص : طبيب اسنان',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      );
    });
  }

  Widget _buildDoctorImage(DoctorModel doctor, String initials) {
    final url = ImageUtils.convertToValidUrl(doctor.imageUrl);
    if (url != null && ImageUtils.isValidImageUrl(url)) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: 80.w,
        height: 80.w,
        placeholder: (context, url) => _doctorAvatarPlaceholder(initials),
        errorWidget: (context, url, error) =>
            _doctorAvatarPlaceholder(initials),
      );
    }
    return _doctorAvatarPlaceholder(initials);
  }

  Widget _doctorAvatarPlaceholder(String initials) {
    return Container(
      width: 80.w,
      height: 80.w,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: TextStyle(
            color: AppColors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildGallerySection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.patientPhotos,
                style: GoogleFonts.cairo(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              GestureDetector(
                onTap: _addImage,
                child: Text(
                  AppStrings.addImage,
                  style: GoogleFonts.cairo(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (_galleryLoading.value) {
              return Container(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              );
            }
            if (_galleryImages.isEmpty) {
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 32.h),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: kPatientFileShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.divider,
                      ),
                      child: Icon(
                        Icons.photo_library_outlined,
                        size: 50.sp,
                        color: AppColors.textHint,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا توجد صور',
                      style: TextStyle(
                          fontSize: 16.sp, color: AppColors.textHint),
                    ),
                  ],
                ),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8.w,
                mainAxisSpacing: 8.h,
                childAspectRatio: 1.0,
              ),
              itemCount: _galleryImages.length,
              itemBuilder: (context, index) {
                final image = _galleryImages[index];
                final imageUrl =
                    ImageUtils.convertToValidUrl(image.imagePath);
                return GestureDetector(
                  onTap: () {
                    if (imageUrl != null &&
                        ImageUtils.isValidImageUrl(imageUrl)) {
                      showDialog(
                        context: context,
                        builder: (ctx) => Dialog(
                          child: CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      );
                    }
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: imageUrl != null &&
                            ImageUtils.isValidImageUrl(imageUrl)
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.divider,
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: AppColors.divider,
                              child: Icon(
                                Icons.broken_image,
                                color: AppColors.textHint,
                                size: 30.sp,
                              ),
                            ),
                          )
                        : Container(
                            color: AppColors.divider,
                            child: Icon(
                              Icons.broken_image,
                              color: AppColors.textHint,
                              size: 30.sp,
                            ),
                          ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _SelectDoctorDialog extends StatefulWidget {
  final PatientModel patient;
  final PatientService patientService;
  final VoidCallback onDone;

  const _SelectDoctorDialog({
    required this.patient,
    required this.patientService,
    required this.onDone,
  });

  @override
  State<_SelectDoctorDialog> createState() => _SelectDoctorDialogState();
}

class _SelectDoctorDialogState extends State<_SelectDoctorDialog> {
  List<DoctorModel> _doctors = [];
  final Set<String> _selectedIds = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadDoctors();
  }

  Future<void> _loadDoctors() async {
    try {
      final list = await widget.patientService.getAllDoctors();
      setState(() {
        _doctors = list;
        _selectedIds.addAll(widget.patient.doctorIds);
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      Get.snackbar('خطأ', e.toString());
    }
  }

  Future<void> _save() async {
    if (_selectedIds.isEmpty) {
      Get.snackbar('تنبيه', 'اختر طبيباً واحداً على الأقل');
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.patientService.assignPatientToDoctors(
        widget.patient.id,
        _selectedIds.toList(),
      );
      widget.onDone();
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.selectDoctor,
              style: GoogleFonts.cairo(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.4),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _doctors.length,
                  itemBuilder: (ctx, i) {
                    final d = _doctors[i];
                    final isSelected = _selectedIds.contains(d.id);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (v) {
                        setState(() {
                          if (v == true) {
                            _selectedIds.add(d.id);
                          } else {
                            _selectedIds.remove(d.id);
                          }
                        });
                      },
                      title: Text(
                        d.name ?? d.phone,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.cairo(),
                      ),
                      secondary: d.imageUrl != null &&
                              ImageUtils.isValidImageUrl(
                                  ImageUtils.convertToValidUrl(d.imageUrl))
                          ? CircleAvatar(
                              radius: 20.r,
                              backgroundImage: NetworkImage(
                                  ImageUtils.convertToValidUrl(d.imageUrl)!),
                            )
                          : CircleAvatar(
                              radius: 20.r,
                              backgroundColor: AppColors.primaryLight,
                              child: Text(
                                (d.name?.isNotEmpty == true ? d.name![0] : 'د'),
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                      activeColor: AppColors.primary,
                    );
                  },
                ),
              ),
            SizedBox(height: 16.h),
            Row(
              children: [
                TextButton(
                  onPressed: _saving ? null : () => Navigator.pop(context),
                  child: Text(AppStrings.cancel,
                      style: TextStyle(color: AppColors.primary)),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: AppColors.white,
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(AppColors.white),
                          ),
                        )
                      : Text(AppStrings.save),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
