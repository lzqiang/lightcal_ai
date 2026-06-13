import 'package:flutter/widgets.dart';

class DietRecord {
  const DietRecord({
    required this.meal,
    required this.foodName,
    required this.portion,
    required this.calories,
    this.note,
  });

  final String meal;
  final String foodName;
  final String portion;
  final int calories;
  final String? note;
}

class AppState extends ChangeNotifier {
  final List<DietRecord> _dietRecords = [];

  List<DietRecord> get dietRecords => List.unmodifiable(_dietRecords);

  int get todayIntakeCalories =>
      _dietRecords.fold(0, (total, record) => total + record.calories);

  int get recordedMealCount =>
      _dietRecords.map((record) => record.meal).toSet().length;

  int get remainingCalories => (1450 - todayIntakeCalories).clamp(0, 9999);

  String get todayStatus {
    if (todayIntakeCalories == 0) {
      return '待记录';
    }
    if (todayIntakeCalories <= 1450) {
      return '控制良好';
    }
    if (todayIntakeCalories <= 1650) {
      return '接近上限';
    }
    return '已超标';
  }

  void addDietRecords(List<DietRecord> records) {
    if (records.isEmpty) {
      return;
    }
    _dietRecords.addAll(records);
    notifyListeners();
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState notifier,
    required super.child,
  }) : super(notifier: notifier);

  static AppState watch(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree.');
    return scope!.notifier!;
  }

  static AppState read(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<AppStateScope>()?.widget
            as AppStateScope?;
    assert(element != null, 'AppStateScope not found in widget tree.');
    return element!.notifier!;
  }
}
