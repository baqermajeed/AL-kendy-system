import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:reception_app_kendy/core/theme/app_theme.dart';
import 'package:reception_app_kendy/controllers/auth_controller.dart';
import 'package:reception_app_kendy/views/auth_gate.dart';
import 'package:reception_app_kendy/views/reception_login_screen.dart';
import 'package:reception_app_kendy/views/reception_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AuthController(), permanent: true);
  runApp(const ReceptionApp());
}

class ReceptionApp extends StatelessWidget {
  const ReceptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'استقبال - عيادة الكندي',
          theme: AppTheme.light(),
          locale: const Locale('ar'),
          supportedLocales: const [Locale('ar'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/',
          getPages: [
            GetPage(name: '/', page: () => const AuthGate()),
            GetPage(name: '/login', page: () => const ReceptionLoginScreen()),
            GetPage(name: '/home', page: () => const ReceptionHomeScreen()),
          ],
        );
      },
    );
  }
}
