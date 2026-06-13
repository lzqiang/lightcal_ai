import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:lightcal_ai/app.dart';

void main() {
  testWidgets('shows splash page content from the product spec', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('轻卡 AI'), findsWidgets);
    expect(find.text('拍一下，AI 帮你管住热量。'), findsOneWidget);
    expect(find.text('DeepSeek'), findsOneWidget);
    expect(find.text('未登录'), findsOneWidget);
    expect(find.text('进入快捷登录'), findsOneWidget);
    expect(find.text('资料未填'), findsOneWidget);
    expect(find.text('进入基础信息'), findsOneWidget);
    expect(find.text('老用户'), findsOneWidget);
    expect(find.text('直接进首页'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '开始记录'), findsOneWidget);
  });

  testWidgets('start button opens the login route placeholder', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.widgetWithText(FilledButton, '开始记录'));
    await tester.tap(find.widgetWithText(FilledButton, '开始记录'));
    await tester.pumpAndSettle();

    expect(find.text('登录页'), findsOneWidget);
  });
}
