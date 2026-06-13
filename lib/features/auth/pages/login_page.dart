import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _agreed = false;

  bool get _canLogin =>
      _agreed &&
      _phoneController.text.trim().isNotEmpty &&
      _codeController.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_refresh);
    _codeController.addListener(_refresh);
  }

  @override
  void dispose() {
    _phoneController
      ..removeListener(_refresh)
      ..dispose();
    _codeController
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  void _submit() {
    Navigator.of(context).pushReplacementNamed('/profile-setup');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 42),
                      Text(
                        '轻卡 AI',
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '登录后保存你的饮食、运动和减脂计划。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 28),
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                '手机号快捷登录',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 14),
                              TextFormField(
                                controller: _phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: const InputDecoration(
                                  labelText: '请输入手机号',
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _codeController,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.done,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                decoration: InputDecoration(
                                  labelText: '请输入验证码',
                                  suffix: TextButton(
                                    onPressed: () {},
                                    child: const Text('获取验证码'),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '手机号作为账号标识，登录后可在“我的”页查看和管理。',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 14),
                              FilledButton(
                                onPressed: _canLogin ? _submit : null,
                                child: const Text('登录'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton(
                        onPressed: _agreed ? () {} : null,
                        child: const Text('微信一键登录'),
                      ),
                      const SizedBox(height: 12),
                      _AgreementRow(
                        agreed: _agreed,
                        onChanged: (value) {
                          setState(() {
                            _agreed = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AgreementRow extends StatelessWidget {
  const _AgreementRow({
    required this.agreed,
    required this.onChanged,
  });

  final bool agreed;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Checkbox(
            value: agreed,
            onChanged: onChanged,
            activeColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Text.rich(
              TextSpan(
                text: '登录即表示已阅读并同意',
                style: Theme.of(context).textTheme.bodyMedium,
                children: const [
                  TextSpan(
                    text: '《用户协议》',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: '和'),
                  TextSpan(
                    text: '《隐私政策》',
                    style: TextStyle(
                      color: AppTheme.primaryDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  TextSpan(text: '。'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
