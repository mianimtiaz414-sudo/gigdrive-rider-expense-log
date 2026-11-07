import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:rider_expense_tracker/data/local/shared_prefs.dart';
import 'package:rider_expense_tracker/routes/app_routes.dart';

class SetupGuard extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    if (!SharedPrefs.isOnboardingDone) {
      return const RouteSettings(name: AppRoutes.onboarding);
    }
    if (!SharedPrefs.isSetupDone) {
      return const RouteSettings(name: AppRoutes.setup);
    }
    return null;
  }
}
