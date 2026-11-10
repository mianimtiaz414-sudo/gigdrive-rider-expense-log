import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';

class HiveStorageService {
  static const String expenseBoxName = 'expense_logs';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static const String _keyName = 'hive_encryption_key';

  late Box<ExpenseModel> _box;

  Future<HiveStorageService> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }

    final Uint8List encryptionKey = await _getOrCreateEncryptionKey();

    _box = await Hive.openBox<ExpenseModel>(
      expenseBoxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );

    return this;
  }

  Future<Uint8List> _getOrCreateEncryptionKey() async {
    final String? storedKey = await _secureStorage.read(key: _keyName);

    if (storedKey == null || storedKey.isEmpty) {
      final List<int> secureKey = Hive.generateSecureKey();

      if (secureKey.length != 32) {
        throw StateError(
          'Failed to generate a valid Hive encryption key.',
        );
      }

      await _secureStorage.write(
        key: _keyName,
        value: base64Url.encode(secureKey),
      );

      return Uint8List.fromList(secureKey);
    }

    try {
      final Uint8List decodedKey = Uint8List.fromList(
        base64Url.decode(storedKey),
      );

      if (decodedKey.length != 32) {
        throw StateError(
          'Stored Hive encryption key must be 32 bytes.',
        );
      }

      return decodedKey;
    } catch (e) {
      throw StateError(
        'Hive encryption key is invalid. '
        'Existing encrypted data has been preserved. Error: $e',
      );
    }
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
    final Map<String, ExpenseModel> entries = {
      for (final ExpenseModel log in logs) log.id: log,
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
