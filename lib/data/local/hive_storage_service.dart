import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';

class HiveStorageService {
  static const String expenseBoxName = 'expense_logs';

  late Box<ExpenseModel> _box;

  Future<HiveStorageService> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    _box = await Hive.openBox<ExpenseModel>(expenseBoxName);
    return this;
  }

  List<ExpenseModel> getAllLogs() {
    final List<ExpenseModel> items = _box.values.toList();
    items.sort((ExpenseModel a, ExpenseModel b) {
      final int byDate = b.date.compareTo(a.date);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });
    return items;
  }

  List<ExpenseModel> getUnsyncedLogs() {
    return _box.values.where((ExpenseModel e) => !e.synced).toList();
  }

  Future<void> saveLog(ExpenseModel log) async {
    await _box.put(log.id, log);
  }

  Future<void> saveAll(List<ExpenseModel> logs) async {
    final Map<String, ExpenseModel> entries = <String, ExpenseModel>{
      for (final ExpenseModel l in logs) l.id: l,
    };
    await _box.putAll(entries);
  }

  Future<void> deleteLog(String id) async {
    await _box.delete(id);
  }

  Future<void> clearAll() async {
    await _box.clear();
  }
}
