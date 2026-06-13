import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';

class ManualDietPage extends StatefulWidget {
  const ManualDietPage({super.key});

  @override
  State<ManualDietPage> createState() => _ManualDietPageState();
}

class _ManualDietPageState extends State<ManualDietPage> {
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final List<DietRecord> _pendingRecords = [];

  String _meal = '午餐';
  String _portion = '正常';

  int get _mealCalories =>
      _pendingRecords.fold(0, (total, record) => total + record.calories);

  bool get _canAdd =>
      _foodController.text.trim().isNotEmpty &&
      int.tryParse(_calorieController.text.trim()) != null;

  bool get _canSave => _pendingRecords.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _foodController.addListener(_refresh);
    _calorieController.addListener(_refresh);
  }

  @override
  void dispose() {
    _foodController
      ..removeListener(_refresh)
      ..dispose();
    _calorieController
      ..removeListener(_refresh)
      ..dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _refresh() {
    setState(() {});
  }

  void _estimateCalories() {
    if (_foodController.text.trim().isEmpty) {
      return;
    }
    final lowerName = _foodController.text.trim().toLowerCase();
    final estimated = lowerName.contains('米饭')
        ? 140
        : lowerName.contains('鸡')
        ? 230
        : lowerName.contains('菜')
        ? 80
        : 180;
    _calorieController.text = estimated.toString();
  }

  void _addFood() {
    final calories = int.tryParse(_calorieController.text.trim());
    if (calories == null || _foodController.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _pendingRecords.add(
        DietRecord(
          meal: _meal,
          foodName: _foodController.text.trim(),
          portion: _portion,
          calories: calories,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ),
      );
      _foodController.clear();
      _calorieController.clear();
    });
  }

  void _saveRecords() {
    AppStateScope.read(context).addDietRecords(_pendingRecords);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('手动饮食记录')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
                          '手动记饮食',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '不拍照也能快速记录',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const _Pill(label: '手动'),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                child: _ChoiceGroup(
                  title: '选择餐次',
                  options: const ['早餐', '午餐', '晚餐', '加餐'],
                  value: _meal,
                  onChanged: (value) => setState(() => _meal = value),
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      '添加食物',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _foodController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: '食物名称'),
                    ),
                    const SizedBox(height: 12),
                    _ChoiceGroup(
                      title: '份量',
                      options: const ['少量', '正常', '偏多'],
                      value: _portion,
                      onChanged: (value) => setState(() => _portion = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _calorieController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: '估算热量',
                        suffixText: 'kcal',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(labelText: '备注'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _estimateCalories,
                            child: const Text('AI 估算热量'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _canAdd ? _addFood : null,
                            child: const Text('添加'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'AI 估算可能存在偏差，请确认份量后保存。',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('已添加', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (_pendingRecords.isEmpty)
                      Text(
                        '还没有添加食物。',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    else
                      for (final record in _pendingRecords)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: _InfoRow(
                            label: '${record.foodName} · ${record.portion}',
                            value: '${record.calories} kcal',
                          ),
                        ),
                    const SizedBox(height: 8),
                    _Pill(label: '本餐约 $_mealCalories kcal', blue: true),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _canSave ? _saveRecords : null,
                child: const Text('保存到今日记录'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(padding: const EdgeInsets.all(14), child: child),
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.ink,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, this.blue = false});

  final String label;
  final bool blue;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: blue ? AppTheme.blueSoft : AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: Text(
          label,
          style: TextStyle(
            color: blue ? const Color(0xFF12486D) : AppTheme.primaryDark,
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
