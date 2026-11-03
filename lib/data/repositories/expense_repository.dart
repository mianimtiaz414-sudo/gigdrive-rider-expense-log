import 'dart:async';

import 'package:rider_expense_tracker/data/local/hive_storage_service.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';
import 'package:rider_expense_tracker/data/remote/firebase_auth_service.dart';
import 'package:rider_expense_tracker/data/remote/firebase_db_service.dart';


class ExpenseRepository {
  ExpenseRepository({
    required HiveStorageService hive,
    required FirebaseDbService db,
    required FirebaseAuthService auth,
  })  : _hive = hive,
        _db = db,
        _auth = auth;

  final HiveStorageService _hive;
  final FirebaseDbService _db;
  final FirebaseAuthService _auth;

  bool get isCloudReady => _auth.isAvailable && _auth.uid != null;

  
  int get pendingCount => _hive.getUnsyncedLogs().length;

  List<ExpenseModel> getLocalLogs() => _hive.getAllLogs();

  
  Future<void> addLog(ExpenseModel log, {void Function()? onSynced}) async {
    log.synced = false;
    await _hive.saveLog(log);
    unawaited(_syncOne(log).then((bool ok) {
      if (ok && onSynced != null) {
        onSynced();
      }
    }));
  }

  Future<void> deleteLog(String id) async {
    await _hive.deleteLog(id);
    if (!isCloudReady) {
      return;
    }
    try {
      await _db.removeLog(_auth.uid!, id);
    } catch (_) {
      
    }
  }

  
  
  Future<void> clearLocal() async {
    await _hive.clearAll();
  }

  
  Future<int> syncPending() async {
    if (!isCloudReady) {
      return 0;
    }
    int uploaded = 0;
    for (final ExpenseModel log in _hive.getUnsyncedLogs()) {
      final bool ok = await _syncOne(log);
      if (ok) {
        uploaded++;
      }
    }
    return uploaded;
  }

  
  Future<int> restoreFromCloud() async {
    final String? uid = _auth.uid;
    if (uid == null || !_db.isAvailable) {
      return 0;
    }
    final List<ExpenseModel> remote = await _db.fetchLogs(uid);
    final Set<String> localIds =
        _hive.getAllLogs().map((ExpenseModel e) => e.id).toSet();
    final List<ExpenseModel> missing =
        remote.where((ExpenseModel r) => !localIds.contains(r.id)).toList();
    await _hive.saveAll(missing);
    return missing.length;
  }

  Future<bool> _syncOne(ExpenseModel log) async {
    final String? uid = _auth.uid;
    if (uid == null || !_db.isAvailable) {
      return false;
    }
    try {
      await _db.upsertLog(uid, log);
      log.synced = true;
      await _hive.saveLog(log);
      return true;
    } catch (_) {
      return false;
    }
  }
}
