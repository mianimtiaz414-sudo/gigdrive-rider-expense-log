import 'package:get/get.dart';
import 'package:rider_expense_tracker/views/add_log_view.dart';
import 'package:rider_expense_tracker/views/dashboard_view.dart';
import 'package:rider_expense_tracker/views/login_passcode_view.dart';
import 'package:rider_expense_tracker/views/login_view.dart';
import 'package:rider_expense_tracker/views/onboarding_view.dart';
import 'package:rider_expense_tracker/views/set_passcode_view.dart';
import 'package:rider_expense_tracker/views/settings_view.dart';
import 'package:rider_expense_tracker/views/setup_wizard_view.dart';
import 'package:rider_expense_tracker/views/splash_view.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String setup = '/setup';
  static const String login = '/login';
  static const String setPasscode = '/set-passcode';
  static const String loginPasscode = '/login-passcode';
  static const String dashboard = '/dashboard';
  static const String addLog = '/add-log';
  static const String settings = '/settings';

  static final List<GetPage<dynamic>> pages = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: splash,
      page: () => const SplashView(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: onboarding,
      page: () => const OnboardingView(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: setup,
      page: () => const SetupWizardView(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: login,
      page: () => const LoginView(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: setPasscode,
      page: () => const SetPasscodeView(),
      transition: Transition.rightToLeft,
    ),
    GetPage<dynamic>(
      name: loginPasscode,
      page: () => const LoginPasscodeView(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: dashboard,
      page: () => const DashboardView(),
      transition: Transition.fadeIn,
    ),
    GetPage<dynamic>(
      name: addLog,
      page: () => const AddLogView(),
      transition: Transition.downToUp,
    ),
    GetPage<dynamic>(
      name: settings,
      page: () => const SettingsView(),
      transition: Transition.rightToLeft,
    ),
  ];
}
