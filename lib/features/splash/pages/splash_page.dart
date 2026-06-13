import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

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
                  padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _HeroPreview(),
                        const SizedBox(height: 20),
                        Text(
                          '轻卡 AI',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '拍一下，AI 帮你管住热量。',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(color: AppTheme.primaryDark),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '记录每天吃的和运动消耗，DeepSeek 分析热量和状态，给你明天能执行的食谱与运动建议。',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 18),
                        const _StartFlowCard(),
                        const Spacer(),
                        FilledButton(
                          onPressed: () =>
                              Navigator.of(context).pushNamed('/login'),
                          child: const Text('开始记录'),
                        ),
                      ],
                    ),
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

class _HeroPreview extends StatelessWidget {
  const _HeroPreview();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 258),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primarySoft,
        borderRadius: BorderRadius.circular(8),
      ),
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
                      '轻卡 AI',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppTheme.primaryDark),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '拍照记录饮食，AI 规划减脂',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const _Pill(label: 'DeepSeek'),
            ],
          ),
          const SizedBox(height: 18),
          const _PreviewCard(
            title: '今日午餐 · AI 已识别',
            subtitle: '米饭 · 鸡胸肉 · 青菜',
            valueLabel: '估算摄入',
            value: '620 kcal',
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _PreviewCard(
                  title: '运动截图',
                  subtitle: '快走 30 分钟',
                  value: '180 kcal',
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _PreviewCard(
                  title: '明日计划',
                  subtitle: '晚餐减主食',
                  value: '已更新',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.title,
    required this.subtitle,
    required this.value,
    this.valueLabel,
  });

  final String title;
  final String subtitle;
  final String value;
  final String? valueLabel;

  @override
  Widget build(BuildContext context) {
    final valueText = Text(
      value,
      style: const TextStyle(
        color: AppTheme.ink,
        fontSize: 15,
        fontWeight: FontWeight.w800,
      ),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: AppTheme.ink,
                ),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          if (valueLabel == null)
            valueText
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(valueLabel!, style: Theme.of(context).textTheme.bodyMedium),
                valueText,
              ],
            ),
        ],
      ),
    );
  }
}

class _StartFlowCard extends StatelessWidget {
  const _StartFlowCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '点击“开始记录”后',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            const _FlowRow(label: '未登录', value: '进入快捷登录'),
            const _FlowRow(label: '资料未填', value: '进入基础信息'),
            const _FlowRow(label: '老用户', value: '直接进首页'),
          ],
        ),
      ),
    );
  }
}

class _FlowRow extends StatelessWidget {
  const _FlowRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.ink,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
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
        color: AppTheme.surface,
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
