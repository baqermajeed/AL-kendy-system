import 'dart:io';
import 'package:dio/dio.dart' show FormData, MultipartFile;
import 'package:reception_app_kendy/core/network/api_constants.dart';
import 'package:reception_app_kendy/core/network/api_exception.dart';
import 'package:reception_app_kendy/models/patient_model.dart';
import 'package:reception_app_kendy/models/doctor_model.dart';
import 'package:reception_app_kendy/models/gallery_image_model.dart';
import 'package:reception_app_kendy/services/api_service.dart';
import 'package:http_parser/http_parser.dart';

class PatientService {
  final _api = ApiService();

  MediaType? _guessImageType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return MediaType('image', 'png');
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return MediaType('image', 'jpeg');
    return null;
  }

  PatientModel _mapToPatient(Map<String, dynamic> json) {
    List<String> doctorIds = [];
    if (json['doctor_ids'] != null) {
      doctorIds = List<String>.from(json['doctor_ids']);
    } else if (json['doctorIds'] != null) {
      doctorIds = List<String>.from(json['doctorIds']);
    } else {
      if (json['primary_doctor_id'] != null) doctorIds.add(json['primary_doctor_id'].toString());
      if (json['secondary_doctor_id'] != null) doctorIds.add(json['secondary_doctor_id'].toString());
    }
    return PatientModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      city: json['city'] ?? '',
      visitType: json['visit_type'] ?? json['visitType'],
      imageUrl: json['imageUrl'] ?? json['image_url'],
      doctorIds: doctorIds,
      treatmentHistory: json['treatment_type'] != null ? [json['treatment_type'].toString()] : null,
    );
  }

  Future<PatientModel> createPatientForReception({
    required String name,
    required String phoneNumber,
    required String gender,
    required int age,
    required String city,
    String? visitType,
  }) async {
    final response = await _api.post(
      ApiConstants.receptionCreatePatient,
      data: {
        'name': name,
        'phone': phoneNumber,
        'gender': gender,
        'age': age,
        'city': city,
        if (visitType != null) 'visit_type': visitType,
      },
    );
    if (response.statusCode == 200) return _mapToPatient(response.data as Map<String, dynamic>);
    throw ApiException('فشل إضافة المريض');
  }

  Future<PatientModel?> uploadPatientImageForReception({
    required String patientId,
    File? imageFile,
  }) async {
    if (imageFile == null) return null;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(RegExp(r'[/\\]')).last,
        contentType: _guessImageType(imageFile.path),
      ),
    });
    final response = await _api.post(
      ApiConstants.receptionUploadPatientImage(patientId),
      formData: formData,
    );
    if (response.statusCode == 200) {
      final data = response.data;
      if (data is Map) {
        final map = Map<String, dynamic>.from(data);
        if (map['patient'] != null) return _mapToPatient(Map<String, dynamic>.from(map['patient']));
        return _mapToPatient(map);
      }
    }
    return null;
  }

  Future<List<PatientModel>> getAllPatients({int skip = 0, int limit = 50}) async {
    final response = await _api.get(
      ApiConstants.receptionPatients,
      queryParameters: {'skip': skip, 'limit': limit},
    );
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => _mapToPatient(Map<String, dynamic>.from(e))).toList();
    }
    throw ApiException('فشل جلب قائمة المرضى');
  }

  Future<List<PatientModel>> searchPatients({
    required String searchQuery,
    int skip = 0,
    int limit = 50,
  }) async {
    final response = await _api.get(
      ApiConstants.receptionPatients,
      queryParameters: {'skip': skip, 'limit': limit, 'search': searchQuery},
    );
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => _mapToPatient(Map<String, dynamic>.from(e))).toList();
    }
    throw ApiException('فشل البحث');
  }

  Future<List<DoctorModel>> getAllDoctors() async {
    final response = await _api.get(ApiConstants.receptionDoctors);
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => DoctorModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw ApiException('فشل جلب الأطباء');
  }

  Future<List<DoctorModel>> getPatientDoctors(String patientId) async {
    final response = await _api.get(ApiConstants.receptionPatientDoctors(patientId));
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data.map((e) => DoctorModel.fromJson(Map<String, dynamic>.from(e))).toList();
    }
    throw ApiException('فشل جلب أطباء المريض');
  }

  Future<bool> assignPatientToDoctors(String patientId, List<String> doctorIds) async {
    final response = await _api.post(
      '${ApiConstants.receptionAssignPatient}?patient_id=$patientId',
      data: doctorIds,
    );
    return response.statusCode == 200;
  }

  Future<List<GalleryImageModel>> getReceptionPatientGallery(String patientId) async {
    final response = await _api.get(ApiConstants.receptionPatientGallery(patientId));
    if (response.statusCode == 200) {
      final data = response.data as List;
      return data
          .map((e) => GalleryImageModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    throw ApiException('فشل جلب المعرض');
  }

  Future<GalleryImageModel> uploadReceptionGalleryImage({
    required String patientId,
    required File imageFile,
    String? note,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split(RegExp(r'[/\\]')).last,
      ),
      if (note != null && note.isNotEmpty) 'note': note,
    });
    final response = await _api.post(
      ApiConstants.receptionPatientGallery(patientId),
      formData: formData,
    );
    if (response.statusCode == 200) {
      return GalleryImageModel.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
    }
    throw ApiException('فشل رفع الصورة');
  }
}
