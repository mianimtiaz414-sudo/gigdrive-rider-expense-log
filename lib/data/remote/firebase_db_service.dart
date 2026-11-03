import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rider_expense_tracker/data/models/expense_model.dart';

class FirebaseDbService {
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
    await _logs(uid).doc(log.id).set(log.toMap());
  }

  Future<void> removeLog(String uid, String id) async {
    await _logs(uid).doc(id).delete();
  }

  Future<List<ExpenseModel>> fetchLogs(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _logs(uid).get();
    return snapshot.docs
        .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
            ExpenseModel.fromMap(d.data()))
        .toList();
  }

  
  Future<void> saveSettings(String uid, Map<String, dynamic> data) async {
    await _settingsDoc(uid).set(data, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> fetchSettings(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snap =
        await _settingsDoc(uid).get();
    return snap.data();
  }
}
