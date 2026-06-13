import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_theme.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _currentWeightController =
      TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  String _gender = '男';
  String _weeklyGoal = '正常减';
  String _dietPreference = '外卖党';
  String _exerciseBase = '偶尔运动';

  bool get _hasRequiredInput =>
      _ageController.text.trim().isNotEmpty &&
      _heightController.text.trim().isNotEmpty &&
      _currentWeightController.text.trim().isNotEmpty &&
      _targetWeightController.text.trim().isNotEmpty;

  String get _calorieRange {
    final currentWeight = double.tryParse(_currentWeightController.text.trim());
    final targetWeight = double.tryParse(_targetWeightController.text.trim());
    final height = double.tryParse(_heightController.text.trim());
    final age = int.tryParse(_ageController.text.trim());

    if (currentWeight == null ||
        targetWeight == null ||
        height == null ||
        age == null) {
      return '填写基础信息后，系统会生成每日建议摄入范围。';
    }

    final base = _gender == '男'
        ? 10 * currentWeight + 6.25 * height - 5 * age + 5
        : 10 * currentWeight + 6.25 * height - 5 * age - 161;
    final activityFactor = switch (_exerciseBase) {
      '几乎不运动' => 1.2,
      '经常运动' => 1.5,
      _ => 1.35,
    };
    final deficit = switch (_weeklyGoal) {
      '轻松减' => 250,
      '快速减' => 550,
      _ => 400,
    };
    final target = (base * activityFactor - deficit).clamp(1200, 2400).round();
    final min = ((target - 100) / 10).round() * 10;
    final max = ((target + 100) / 10).round() * 10;
    final paceText = currentWeight - targetWeight > 12
        ? '目标偏快，建议延长 2 周。'
        : '目标节奏合理。';

    return '建议每日摄入 $min-$max kcal，$paceText';
  }

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _ageController,
      _heightController,
      _currentWeightController,
      _targetWeightController,
    ]) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final controller in [
      _nicknameController,
      _ageController,
      _heightController,
      _currentWeightController,
      _targetWeightController,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  void _submit() {
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '基础信息',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '生成你的每日摄入范围',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const _Pill(label: 'AI'),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                children: [
                  _ProfileField(
                    controller: _nicknameController,
                    label: '昵称',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _ChoiceGroup(
                    title: '性别',
                    options: const ['男', '女'],
                    value: _gender,
                    onChanged: (value) => setState(() => _gender = value),
                  ),
                  const SizedBox(height: 12),
                  _ProfileField(
                    controller: _ageController,
                    label: '年龄',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _ProfileField(
                    controller: _heightController,
                    label: '身高 cm',
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _ProfileField(
                    controller: _currentWeightController,
                    label: '当前体重 kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 12),
                  _ProfileField(
                    controller: _targetWeightController,
                    label: '目标体重 kg',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                children: [
                  _ChoiceGroup(
                    title: '每周目标',
                    options: const ['轻松减', '正常减', '快速减'],
                    value: _weeklyGoal,
                    onChanged: (value) => setState(() => _weeklyGoal = value),
                  ),
                  const SizedBox(height: 14),
                  _ChoiceGroup(
                    title: '饮食偏好',
                    options: const ['外卖党', '食堂党', '自己做饭', '不吃辣', '不吃猪肉', '素食'],
                    value: _dietPreference,
                    onChanged: (value) =>
                        setState(() => _dietPreference = value),
                  ),
                  const SizedBox(height: 14),
                  _ChoiceGroup(
                    title: '运动基础',
                    options: const ['几乎不运动', '偶尔运动', '经常运动'],
                    value: _exerciseBase,
                    onChanged: (value) => setState(() => _exerciseBase = value),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SectionCard(
                children: [
                  Text('目标可行性', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    _calorieRange,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '初始建议：先保持三餐规律，晚餐减少油脂，饭后快走 30 分钟。',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _hasRequiredInput ? _submit : null,
                child: const Text('生成计划'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.controller,
    required this.label,
    this.keyboardType,
    this.textInputAction,
  });

  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      inputFormatters: keyboardType == null
          ? null
          : [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(labelText: label),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _ChoiceGroup extends StatelessWidget {
  const _ChoiceGroup({
    required this.title,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in options)
              ChoiceChip(
                label: Text(option),
                selected: value == option,
                onSelected: (_) => onChanged(option),
                selectedColor: AppTheme.primarySoft,
                checkmarkColor: AppTheme.primaryDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: value == option ? AppTheme.primary : AppTheme.line,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: const TextStyle(
            color: AppTheme.primaryDark,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
