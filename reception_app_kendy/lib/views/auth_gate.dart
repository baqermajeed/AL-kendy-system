import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:reception_app_kendy/controllers/auth_controller.dart';
import 'package:reception_app_kendy/services/auth_service.dart';
import 'package:reception_app_kendy/views/reception_login_screen.dart';
import 'package:reception_app_kendy/views/reception_home_screen.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  final AuthController _authController = Get.find<AuthController>();
  final AuthService _authService = AuthService();
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final isLoggedIn = await _authService.isLoggedIn();
    if (isLoggedIn) {
      await _authController.loadSession();
      final user = _authController.currentUser.value;
      if (user != null && user.userType.toLowerCase() == 'receptionist') {
        if (mounted) Get.offAll(() => const ReceptionHomeScreen());
      }
    }
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return const ReceptionLoginScreen();
  }
}
