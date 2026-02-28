class PatientModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String gender;
  final int age;
  final String city;
  final String? visitType;
  final String? imageUrl;
  final List<String> doctorIds;
  final List<String>? treatmentHistory;

  PatientModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.gender,
    required this.age,
    required this.city,
    this.visitType,
    this.imageUrl,
    this.doctorIds = const [],
    this.treatmentHistory,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    List<String> doctorIds = [];
    if (json['doctor_ids'] != null) {
      doctorIds = List<String>.from(json['doctor_ids']);
    } else if (json['doctorIds'] != null) {
      doctorIds = List<String>.from(json['doctorIds']);
    } else {
      if (json['primary_doctor_id'] != null) {
        doctorIds.add(json['primary_doctor_id'].toString());
      }
      if (json['secondary_doctor_id'] != null) {
        doctorIds.add(json['secondary_doctor_id'].toString());
      }
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
      treatmentHistory: json['treatment_type'] != null
          ? [json['treatment_type'].toString()]
          : null,
    );
  }
}
