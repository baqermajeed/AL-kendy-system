import 'package:get/get.dart';
import 'package:reception_app_kendy/models/user_model.dart';
import 'package:reception_app_kendy/services/auth_service.dart';
import 'package:reception_app_kendy/services/api_service.dart';
import 'package:reception_app_kendy/core/network/api_exception.dart';

class AuthController extends GetxController {
  final _authService = AuthService();
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final RxBool isLoading = false.obs;

  Future<void> loadSession() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final res = await _authService.getCurrentUser();
        if (res['ok'] == true && res['data'] != null) {
          currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(res['data']));
        } else {
          currentUser.value = null;
        }
      } else {
        currentUser.value = null;
      }
    } catch (_) {
      currentUser.value = null;
    }
  }

  Future<void> loginReception({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) {
      Get.snackbar('خطأ', 'يرجى إدخال اسم المستخدم وكلمة المرور');
      return;
    }
    try {
      isLoading.value = true;
      final res = await _authService.staffLogin(
        username: username.trim(),
        password: password,
      );
      if (res['ok'] == true) {
        final userRes = await _authService.getCurrentUser();
        if (userRes['ok'] == true && userRes['data'] != null) {
          currentUser.value = UserModel.fromJson(Map<String, dynamic>.from(userRes['data']));
          Get.offAllNamed('/home');
          Get.snackbar('نجح', 'تم تسجيل الدخول بنجاح');
        } else {
          Get.snackbar('خطأ', userRes['error']?.toString() ?? 'فشل جلب المستخدم');
        }
      } else {
        Get.snackbar('خطأ', res['error']?.toString() ?? 'فشل تسجيل الدخول');
      }
    } on ApiException catch (e) {
      Get.snackbar('خطأ', e.message);
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await ApiService().clearTokens();
    currentUser.value = null;
    Get.offAllNamed('/login');
  }
}
