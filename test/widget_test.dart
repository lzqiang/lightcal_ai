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

  testWidgets('start button opens the login page', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.widgetWithText(FilledButton, '开始记录'));
    await tester.tap(find.widgetWithText(FilledButton, '开始记录'));
    await tester.pumpAndSettle();

    expect(find.text('手机号快捷登录'), findsOneWidget);
  });

  testWidgets('login page shows phone login content from the product spec', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.widgetWithText(FilledButton, '开始记录'));
    await tester.tap(find.widgetWithText(FilledButton, '开始记录'));
    await tester.pumpAndSettle();

    expect(find.text('轻卡 AI'), findsOneWidget);
    expect(find.text('手机号快捷登录'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '请输入手机号'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '请输入验证码'), findsOneWidget);
    expect(find.text('获取验证码'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '登录'), findsOneWidget);
    expect(find.widgetWithText(OutlinedButton, '微信一键登录'), findsOneWidget);
    expect(find.textContaining('用户协议'), findsOneWidget);
    expect(find.textContaining('隐私政策'), findsOneWidget);
  });

  testWidgets('login requires agreement before entering profile setup', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.ensureVisible(find.widgetWithText(FilledButton, '开始记录'));
    await tester.tap(find.widgetWithText(FilledButton, '开始记录'));
    await tester.pumpAndSettle();

    final loginButton = find.widgetWithText(FilledButton, '登录');
    expect(tester.widget<FilledButton>(loginButton).onPressed, isNull);

    await tester.enterText(find.widgetWithText(TextFormField, '请输入手机号'), '13800138000');
    await tester.enterText(find.widgetWithText(TextFormField, '请输入验证码'), '123456');
    await tester.pump();
    expect(tester.widget<FilledButton>(loginButton).onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<FilledButton>(loginButton).onPressed, isNotNull);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('基础信息'), findsOneWidget);
  });
}
