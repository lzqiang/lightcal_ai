import 'package:flutter/material.dart';

import '../../../core/state/app_state.dart';
import '../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: const [
            _HomeDashboard(),
            _TabPlaceholder(title: '历史记录', subtitle: '按日期查看摄入、消耗和状态'),
            _TabPlaceholder(title: '推荐页', subtitle: '明日计划和未来 7 天计划日历'),
            _TabPlaceholder(title: '我的页', subtitle: '账号资料、身体目标和基础设置'),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '首页',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: '记录',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: '推荐',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

class _HomeDashboard extends StatelessWidget {
  const _HomeDashboard();

  @override
  Widget build(BuildContext context) {
    final appState = AppStateScope.watch(context);

    return SingleChildScrollView(
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
                      '早上好，赵强',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '已连续记录 12 天',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const _Pill(label: '目标中'),
            ],
          ),
          const SizedBox(height: 16),
          const _ProgressCard(),
          const SizedBox(height: 12),
          _TodayProgressCard(appState: appState),
          const SizedBox(height: 12),
          const _YesterdayReviewCard(),
          const SizedBox(height: 12),
          const _TodayPlanCard(),
          const SizedBox(height: 12),
          _CompletionCard(appState: appState),
          const SizedBox(height: 12),
          const _QuickActions(),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '目标进度',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Text(
                '60.0 kg',
                style: TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '当前 66.8 kg，距离目标还差 6.8 kg',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: const LinearProgressIndicator(
              value: 0.64,
              minHeight: 8,
              backgroundColor: AppTheme.line,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayProgressCard extends StatelessWidget {
  const _TodayProgressCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final intake = appState.todayIntakeCalories;

    return _CardSection(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '今日进度',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _Pill(label: appState.todayStatus),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: '已摄入',
                  value: intake.toString(),
                  unit: 'kcal',
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: _StatTile(label: '已消耗', value: '180', unit: 'kcal'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoRow(
            label: '还可摄入',
            value: '约 ${appState.remainingCalories} kcal',
          ),
          const SizedBox(height: 6),
          Text('点击查看今天详情', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _YesterdayReviewCard extends StatelessWidget {
  const _YesterdayReviewCard();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '昨日回顾',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const _Pill(label: '略超标'),
            ],
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Expanded(
                child: _StatTile(label: '摄入', value: '1820', unit: 'kcal'),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _StatTile(label: '消耗', value: '260', unit: 'kcal'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'AI：今天晚餐控制油脂，运动保持快走即可。点击查看昨天详情。',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _TodayPlanCard extends StatelessWidget {
  const _TodayPlanCard();

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '今日计划',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const _Pill(label: '待完成', blue: true),
            ],
          ),
          const SizedBox(height: 10),
          const _PlanItem(title: '早餐 已完成', detail: '鸡蛋 2 个 · 无糖酸奶'),
          const _PlanItem(title: '午餐 建议', detail: '鸡胸肉 · 半碗米饭 · 西兰花'),
          const _PlanItem(title: '晚餐 建议', detail: '豆腐虾仁 · 两份蔬菜 · 主食半碗'),
          const _PlanItem(title: '训练 待完成', detail: '饭后快走 30 分钟 · 中等强度'),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return _CardSection(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('记录完成度', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 10),
          _InfoRow(
            label: '饮食记录',
            value: '已记录 ${appState.recordedMealCount}/3 餐',
          ),
          const SizedBox(height: 6),
          const _InfoRow(label: '运动完成', value: '待完成'),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilledButton(
          onPressed: () => Navigator.of(context).pushNamed('/diet/photo'),
          child: const Text('拍照记饮食'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/diet/manual'),
                child: const Text('手动记饮食'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    Navigator.of(context).pushNamed('/exercise/screenshot'),
                child: const Text('上传运动截图'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Card(
      child: Padding(padding: const EdgeInsets.all(14), child: child),
    );

    if (onTap == null) {
      return content;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: content,
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 24,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(unit, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _PlanItem extends StatelessWidget {
  const _PlanItem({required this.title, required this.detail});

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppTheme.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(detail, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
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
