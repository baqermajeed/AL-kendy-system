import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:reception_app_kendy/main.dart';
import 'package:reception_app_kendy/controllers/auth_controller.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    Get.put(AuthController(), permanent: true);
    await tester.pumpWidget(const ReceptionApp());
    await tester.pump();
    expect(find.byType(ReceptionApp), findsOneWidget);
  });
}
