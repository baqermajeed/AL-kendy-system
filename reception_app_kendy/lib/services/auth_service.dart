import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:reception_app_kendy/core/network/api_constants.dart';
import 'package:reception_app_kendy/core/network/api_exception.dart';
import 'package:reception_app_kendy/services/api_service.dart';

class AuthService {
  final _api = ApiService();

  Future<Map<String, dynamic>> staffLogin({
    required String username,
    required String password,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.authStaffLogin}');
      final headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json',
      };
      final body =
          'grant_type=password&username=${Uri.encodeComponent(username)}&password=${Uri.encodeComponent(password)}';

      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 30));

      final decoded = _decodeBody(response.bodyBytes);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final accessToken = decoded['access_token'] as String?;
        final refreshToken = decoded['refresh_token'] as String?;
        if (accessToken != null && refreshToken != null) {
          await _api.saveTokens(accessToken, refreshToken);
        }
        return {'ok': true, 'data': decoded};
      }
      return {
        'ok': false,
        'error': decoded['detail']?.toString() ?? 'فشل تسجيل الدخول',
      };
    } catch (e) {
      return {
        'ok': false,
        'error': e.toString().contains('timeout')
            ? 'انتهت مهلة الاتصال'
            : 'حدث خطأ في الاتصال',
      };
    }
  }

  Map<String, dynamic> _decodeBody(List<int> bodyBytes) {
    try {
      return jsonDecode(utf8.decode(bodyBytes)) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      final response = await _api.get(ApiConstants.authMe);
      if (response.statusCode == 200) {
        return {'ok': true, 'data': response.data};
      }
      throw ApiException('فشل جلب بيانات المستخدم');
    } catch (e) {
      if (e is ApiException) return {'ok': false, 'error': e.message};
      return {'ok': false, 'error': e.toString()};
    }
  }

  Future<bool> isLoggedIn() async {
    final token = await _api.getToken();
    return token != null && token.isNotEmpty;
  }
}
