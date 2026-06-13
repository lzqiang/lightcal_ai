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

  testWidgets('start button opens the login page', (WidgetTester tester) async {
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
    await _openLoginPage(tester);

    final loginButton = find.widgetWithText(FilledButton, '登录');
    expect(tester.widget<FilledButton>(loginButton).onPressed, isNull);

    await tester.enterText(
      find.widgetWithText(TextFormField, '请输入手机号'),
      '13800138000',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '请输入验证码'),
      '123456',
    );
    await tester.pump();
    expect(tester.widget<FilledButton>(loginButton).onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<FilledButton>(loginButton).onPressed, isNotNull);

    await tester.tap(loginButton);
    await tester.pumpAndSettle();

    expect(find.text('基础信息'), findsOneWidget);
  });

  testWidgets('profile setup shows required fields and preference options', (
    WidgetTester tester,
  ) async {
    await _completeLogin(tester);

    expect(find.text('基础信息'), findsOneWidget);
    expect(find.text('生成你的每日摄入范围'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '昵称'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '年龄'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '身高 cm'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '当前体重 kg'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '目标体重 kg'), findsOneWidget);
    expect(find.text('性别'), findsOneWidget);
    expect(find.text('每周目标'), findsOneWidget);
    expect(find.text('饮食偏好'), findsOneWidget);
    expect(find.text('运动基础'), findsOneWidget);
    expect(find.text('外卖党'), findsOneWidget);
    expect(find.text('正常减'), findsOneWidget);
    expect(find.text('偶尔运动'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '生成计划'), findsOneWidget);
  });

  testWidgets(
    'profile setup generates calorie range and opens home placeholder',
    (WidgetTester tester) async {
      await _completeLogin(tester);

      await tester.enterText(find.widgetWithText(TextFormField, '昵称'), '赵强');
      await tester.enterText(find.widgetWithText(TextFormField, '年龄'), '30');
      await tester.enterText(
        find.widgetWithText(TextFormField, '身高 cm'),
        '168',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '当前体重 kg'),
        '68',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '目标体重 kg'),
        '60',
      );
      await tester.ensureVisible(find.widgetWithText(FilledButton, '生成计划'));
      await tester.pump();

      expect(find.textContaining('建议每日摄入'), findsOneWidget);
      expect(find.textContaining('目标节奏合理'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, '生成计划'));
      await tester.pumpAndSettle();

      expect(find.text('首页'), findsOneWidget);
    },
  );
}

Future<void> _openLoginPage(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.widgetWithText(FilledButton, '开始记录'));
  await tester.tap(find.widgetWithText(FilledButton, '开始记录'));
  await tester.pumpAndSettle();
}

Future<void> _completeLogin(WidgetTester tester) async {
  await _openLoginPage(tester);
  await tester.enterText(
    find.widgetWithText(TextFormField, '请输入手机号'),
    '13800138000',
  );
  await tester.enterText(
    find.widgetWithText(TextFormField, '请输入验证码'),
    '123456',
  );
  await tester.tap(find.byType(Checkbox));
  await tester.pump();
  await tester.tap(find.widgetWithText(FilledButton, '登录'));
  await tester.pumpAndSettle();
}
