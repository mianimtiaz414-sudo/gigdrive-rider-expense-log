import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  void _handleNetworkError(dynamic error) {
    String message = 'network_error_msg'.tr;
    if (error is TimeoutException) {
      message = 'connection_timeout_msg'.tr;
    } else if (error is FirebaseException) {
      message = error.message ?? 'cloud_server_error_msg'.tr;
    }

    Get.snackbar(
      'cloud_sync_title'.tr,
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: const Color(0xFFE57373),
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> upsertLog(String uid, ExpenseModel log) async {
    try {
      await _logs(uid)
          .doc(log.id)
          .set(log.toMap())
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      _handleNetworkError(e);
      rethrow;
    }
  }

  Future<void> removeLog(String uid, String id) async {
    try {
      await _logs(uid).doc(id).delete().timeout(const Duration(seconds: 5));
    } catch (e) {
      _handleNetworkError(e);
      rethrow;
    }
  }

  Future<List<ExpenseModel>> fetchLogs(String uid) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _logs(uid)
          .get(const GetOptions(source: Source.serverAndCache))
          .timeout(const Duration(seconds: 8));

      return snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> d) =>
              ExpenseModel.fromMap(d.data()))
          .toList();
    } catch (e) {
      _handleNetworkError(e);
      return [];
    }
  }

  Future<void> saveSettings(String uid, Map<String, dynamic> data) async {
    try {
      await _settingsDoc(uid)
          .set(data, SetOptions(merge: true))
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      _handleNetworkError(e);
    }
  }

  Future<Map<String, dynamic>?> fetchSettings(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snap =
          await _settingsDoc(uid).get().timeout(const Duration(seconds: 5));
      return snap.data();
    } catch (e) {
      _handleNetworkError(e);
      return null;
    }
  }
}
