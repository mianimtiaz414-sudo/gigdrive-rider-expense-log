import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';

class HiveStorageService {
  static const String expenseBoxName = 'expense_logs';
  static const _secureStorage = FlutterSecureStorage();
  static const _keyName = 'hive_encryption_key';

  late Box<ExpenseModel> _box;

  Future<HiveStorageService> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }

    final encryptionKey = await _getOrCreateEncryptionKey();

    _box = await Hive.openBox<ExpenseModel>(
      expenseBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    return this;
  }

  Future<Uint8List> _getOrCreateEncryptionKey() async {
    final containsKey = await _secureStorage.containsKey(key: _keyName);

    if (!containsKey) {
      final secureKey = Hive.generateSecureKey();
      await _secureStorage.write(
        key: _keyName,
        value: base64Url.encode(secureKey), // Fixed syntax
      );
      return Uint8List.fromList(secureKey);
    }

    final base64Key = await _secureStorage.read(key: _keyName);
    return Uint8List.fromList(base64Url.decode(base64Key!));
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
