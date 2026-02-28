class GalleryImageModel {
  final String id;
  final String patientId;
  final String? doctorId;
  final String imagePath;
  final String? note;
  final String createdAt;

  GalleryImageModel({
    required this.id,
    required this.patientId,
    this.doctorId,
    required this.imagePath,
    this.note,
    required this.createdAt,
  });

  factory GalleryImageModel.fromJson(Map<String, dynamic> json) {
    return GalleryImageModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id'] ?? '',
      doctorId: json['doctor_id']?.toString() ??
          json['doctorId']?.toString() ??
          json['user_id']?.toString(),
      imagePath: json['image_path'] ?? '',
      note: json['note'],
      createdAt: json['created_at'] ?? '',
    );
  }
}
