import 'package:get/get.dart';
import 'package:rider_expense_tracker/data/local/translation_service.dart';



class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys {
    final Map<String, Map<String, String>> base = TranslationService().keys;
    final Map<String, Map<String, String>> merged =
        <String, Map<String, String>>{};
    base.forEach((String code, Map<String, String> values) {
      merged[code] = <String, String>{...values, ...?_extras[code]};
    });
    return merged;
  }

  static const Map<String, Map<String, String>> _extras =
      <String, Map<String, String>>{
    'en': _en,
    'ur': _ur,
    'hi': _hi,
    'ar': _ar,
  };

  static const Map<String, String> _en = <String, String>{
    'export_pdf': 'Export PDF',
    'pdf_no_data_title': 'Nothing to export',
    'pdf_no_data_msg': 'Add at least one daily log before exporting a PDF.',
    'pdf_failed': 'PDF export failed',
    'account': 'Account',
    'switch_account': 'Add / Switch Another Account',
    'switch_account_title': 'Switch account?',
    'switch_account_msg':
        'Your logs are backed up first. Then you will be signed out so you can sign in with another account.',
    'logout': 'Logout',
    'logout_title': 'Log out?',
    'logout_msg':
        'Your logs are backed up first when you are signed in. You will then return to the login screen.',
    'confirm': 'Confirm',
    'backup_failed_title': 'Backup incomplete',
    'backup_failed_msg':
        'Some logs could not be uploaded. Check your connection and try again so nothing is lost.',
    'login_title': 'Welcome',
    'login_sub':
        'Sign in to back up your logs to the cloud, or continue without an account.',
    'continue_offline': 'Continue without an account',
    'or_divider': 'or',
  };

  static const Map<String, String> _ur = <String, String>{
    'export_pdf': 'پی ڈی ایف ایکسپورٹ کریں',
    'pdf_no_data_title': 'ایکسپورٹ کے لیے کچھ نہیں',
    'pdf_no_data_msg':
        'پی ڈی ایف ایکسپورٹ کرنے سے پہلے کم از کم ایک روزانہ لاگ شامل کریں۔',
    'pdf_failed': 'پی ڈی ایف ایکسپورٹ ناکام ہو گئی',
    'account': 'اکاؤنٹ',
    'switch_account': 'دوسرا اکاؤنٹ شامل / تبدیل کریں',
    'switch_account_title': 'اکاؤنٹ تبدیل کریں؟',
    'switch_account_msg':
        'پہلے آپ کے لاگز کا بیک اپ لیا جائے گا۔ پھر آپ سائن آؤٹ ہو جائیں گے تاکہ دوسرے اکاؤنٹ سے سائن ان کر سکیں۔',
    'logout': 'لاگ آؤٹ',
    'logout_title': 'لاگ آؤٹ کریں؟',
    'logout_msg':
        'سائن ان ہونے کی صورت میں پہلے آپ کے لاگز کا بیک اپ لیا جائے گا۔ اس کے بعد آپ لاگ ان اسکرین پر واپس چلے جائیں گے۔',
    'confirm': 'تصدیق کریں',
    'backup_failed_title': 'بیک اپ نامکمل',
    'backup_failed_msg':
        'کچھ لاگز اپ لوڈ نہیں ہو سکے۔ اپنا کنکشن چیک کریں اور دوبارہ کوشش کریں تاکہ کچھ ضائع نہ ہو۔',
    'login_title': 'خوش آمدید',
    'login_sub':
        'اپنے لاگز کا کلاؤڈ پر بیک اپ لینے کے لیے سائن ان کریں، یا بغیر اکاؤنٹ کے جاری رکھیں۔',
    'continue_offline': 'بغیر اکاؤنٹ کے جاری رکھیں',
    'or_divider': 'یا',
  };

  static const Map<String, String> _hi = <String, String>{
    'export_pdf': 'पीडीएफ एक्सपोर्ट करें',
    'pdf_no_data_title': 'एक्सपोर्ट करने के लिए कुछ नहीं',
    'pdf_no_data_msg':
        'पीडीएफ एक्सपोर्ट करने से पहले कम से कम एक दैनिक लॉग जोड़ें।',
    'pdf_failed': 'पीडीएफ एक्सपोर्ट विफल रहा',
    'account': 'अकाउंट',
    'switch_account': 'दूसरा अकाउंट जोड़ें / बदलें',
    'switch_account_title': 'अकाउंट बदलें?',
    'switch_account_msg':
        'पहले आपके लॉग का बैकअप लिया जाएगा। फिर आप साइन आउट हो जाएँगे ताकि दूसरे अकाउंट से साइन इन कर सकें।',
    'logout': 'लॉगआउट',
    'logout_title': 'लॉगआउट करें?',
    'logout_msg':
        'साइन इन होने पर पहले आपके लॉग का बैकअप लिया जाएगा। फिर आप लॉगिन स्क्रीन पर लौट जाएँगे।',
    'confirm': 'पुष्टि करें',
    'backup_failed_title': 'बैकअप अधूरा',
    'backup_failed_msg':
        'कुछ लॉग अपलोड नहीं हो सके। अपना कनेक्शन जाँचें और फिर कोशिश करें ताकि कुछ न खोए।',
    'login_title': 'स्वागत है',
    'login_sub':
        'अपने लॉग का क्लाउड बैकअप लेने के लिए साइन इन करें, या बिना अकाउंट के जारी रखें।',
    'continue_offline': 'बिना अकाउंट के जारी रखें',
    'or_divider': 'या',
  };

  static const Map<String, String> _ar = <String, String>{
    'export_pdf': 'تصدير PDF',
    'pdf_no_data_title': 'لا يوجد ما يمكن تصديره',
    'pdf_no_data_msg': 'أضف سجلًا يوميًا واحدًا على الأقل قبل تصدير ملف PDF.',
    'pdf_failed': 'فشل تصدير PDF',
    'account': 'الحساب',
    'switch_account': 'إضافة حساب آخر / التبديل',
    'switch_account_title': 'تبديل الحساب؟',
    'switch_account_msg':
        'سيتم نسخ سجلاتك احتياطيًا أولًا. ثم يتم تسجيل خروجك لتتمكن من الدخول بحساب آخر.',
    'logout': 'تسجيل الخروج',
    'logout_title': 'تسجيل الخروج؟',
    'logout_msg':
        'عند تسجيل الدخول سيتم نسخ سجلاتك احتياطيًا أولًا. ثم تعود إلى شاشة تسجيل الدخول.',
    'confirm': 'تأكيد',
    'backup_failed_title': 'النسخ الاحتياطي غير مكتمل',
    'backup_failed_msg':
        'تعذّر رفع بعض السجلات. تحقق من اتصالك وحاول مرة أخرى حتى لا يضيع شيء.',
    'login_title': 'مرحبًا بك',
    'login_sub':
        'سجّل الدخول لنسخ سجلاتك احتياطيًا إلى السحابة، أو تابع بدون حساب.',
    'continue_offline': 'المتابعة بدون حساب',
    'or_divider': 'أو',
  };
}
