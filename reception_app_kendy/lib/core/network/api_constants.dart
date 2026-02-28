class ApiConstants {
  static const String _defaultBaseUrl = 'https://alkendysys.farahdent.com';

  static const String _apiHostOverride = String.fromEnvironment(
    'API_HOST',
    defaultValue: '',
  );
  static const String _apiBaseUrlOverride = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static String get baseUrl {
    final baseUrlOverride = _apiBaseUrlOverride.trim();
    if (baseUrlOverride.isNotEmpty) return baseUrlOverride;
    final hostOverride = _apiHostOverride.trim();
    if (hostOverride.isNotEmpty) {
      if (hostOverride.startsWith('http://') || hostOverride.startsWith('https://')) {
        return hostOverride;
      }
      return 'https://$hostOverride';
    }
    return _defaultBaseUrl;
  }

  static const String authStaffLogin = '/auth/staff-login';
  static const String authMe = '/auth/me';
  static const String authRefresh = '/auth/refresh';

  static const String receptionPatients = '/reception/patients';
  static const String receptionCreatePatient = '/reception/patients';
  static const String receptionDoctors = '/reception/doctors';
  static String receptionPatientDoctors(String patientId) =>
      '/reception/patients/$patientId/doctors';
  static const String receptionAssignPatient = '/reception/assign';
  static String receptionUploadPatientImage(String patientId) =>
      '/reception/patients/$patientId/upload-image';
  static String receptionPatientGallery(String patientId) =>
      '/reception/patients/$patientId/gallery';

  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
}
