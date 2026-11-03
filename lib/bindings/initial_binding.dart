import 'package:get/get.dart';
import 'package:rider_expense_tracker/data/local/hive_storage_service.dart';
import 'package:rider_expense_tracker/data/remote/api_service.dart';
import 'package:rider_expense_tracker/data/remote/firebase_auth_service.dart';
import 'package:rider_expense_tracker/data/remote/firebase_db_service.dart';
import 'package:rider_expense_tracker/data/repositories/expense_repository.dart';
import 'package:rider_expense_tracker/data/repositories/settings_repository.dart';
import 'package:rider_expense_tracker/view_models/auth_view_model.dart';
import 'package:rider_expense_tracker/view_models/expense_view_model.dart';
import 'package:rider_expense_tracker/view_models/settings_view_model.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put<ApiService>(ApiService(), permanent: true);
    Get.put<FirebaseAuthService>(FirebaseAuthService(), permanent: true);
    Get.put<FirebaseDbService>(FirebaseDbService(), permanent: true);

    Get.put<ExpenseRepository>(
      ExpenseRepository(
        hive: Get.find<HiveStorageService>(),
        db: Get.find<FirebaseDbService>(),
        auth: Get.find<FirebaseAuthService>(),
      ),
      permanent: true,
    );
    Get.put<SettingsRepository>(
      SettingsRepository(
        db: Get.find<FirebaseDbService>(),
        auth: Get.find<FirebaseAuthService>(),
      ),
      permanent: true,
    );

    Get.put<SettingsViewModel>(
      SettingsViewModel(Get.find<SettingsRepository>()),
      permanent: true,
    );
    Get.put<AuthViewModel>(
      AuthViewModel(
        Get.find<FirebaseAuthService>(),
        Get.find<SettingsViewModel>(),
      ),
      permanent: true,
    );
    Get.put<ExpenseViewModel>(
      ExpenseViewModel(
        Get.find<ExpenseRepository>(),
        Get.find<SettingsViewModel>(),
      ),
      permanent: true,
    );
  }
}
