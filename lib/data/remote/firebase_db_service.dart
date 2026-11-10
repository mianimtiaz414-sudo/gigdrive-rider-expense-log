import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';

class FirebaseDbService {
  static const Duration _writeTimeout = Duration(seconds: 5);
  static const Duration _readTimeout = Duration(seconds: 8);

  bool get isAvailable => Firebase.apps.isNotEmpty;

  CollectionReference<Map<String, dynamic>> _logs(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('daily_logs');
  }

  DocumentReference<Map<String, dynamic>> _settingsDoc(String uid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('preferences');
  }

  Future<void> upsertLog(String uid, ExpenseModel log) async {
    await _logs(uid).doc(log.id).set(log.toMap()).timeout(_writeTimeout);
  }

  Future<void> removeLog(String uid, String id) async {
    await _logs(uid).doc(id).delete().timeout(_writeTimeout);
  }

  Future<List<ExpenseModel>> fetchLogs(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _logs(uid)
        .get(
          const GetOptions(source: Source.serverAndCache),
        )
        .timeout(_readTimeout);

    return snapshot.docs.map(
      (QueryDocumentSnapshot<Map<String, dynamic>> document) {
        return ExpenseModel.fromMap(document.data());
      },
    ).toList();
  }

  Future<void> saveSettings(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _settingsDoc(uid)
        .set(
          data,
          SetOptions(merge: true),
        )
        .timeout(_writeTimeout);
  }

  Future<Map<String, dynamic>?> fetchSettings(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _settingsDoc(uid)
            .get(
              const GetOptions(source: Source.serverAndCache),
            )
            .timeout(_readTimeout);

    return snapshot.data();
  }
}
