class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String userType;
  final String? imageUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.userType,
    this.imageUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final role = json['role'] ?? json['userType'] ?? '';
    final mappedUserType = _mapRoleToUserType(role.toString());
    final rawId = json['user_id'] ?? json['id'];
    return UserModel(
      id: rawId?.toString() ?? '',
      name: json['name'] ?? '',
      phoneNumber: json['phone'] ?? json['phoneNumber'] ?? '',
      userType: mappedUserType,
      imageUrl: json['imageUrl'] ?? json['image_url'],
    );
  }

  static String _mapRoleToUserType(String role) {
    switch (role.toLowerCase()) {
      case 'patient':
        return 'patient';
      case 'doctor':
        return 'doctor';
      case 'receptionist':
        return 'receptionist';
      case 'call_center':
        return 'call_center';
      case 'admin':
        return 'admin';
      default:
        return role.isNotEmpty ? role : 'patient';
    }
  }
}
