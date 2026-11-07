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
    'forgot_password': 'Forgot Password?',
    'forgot_password_need_title': 'Enter your email',
    'forgot_password_need_msg':
        'Type your account email in the field above, then tap Forgot Password again.',
    'forgot_password_sent_title': 'Reset email sent',
    'forgot_password_sent_msg':
        'If an account exists for @email, a password reset link is on its way.',
    'confirm_password': 'Confirm password',
    'passwords_mismatch': 'The two passwords do not match.',
    'forgot_pin': 'Forgot PIN?',
    'forgot_pin_title': 'Reset your PIN?',
    'forgot_pin_password_title': 'Verify your identity',
    'forgot_pin_password_msg':
        'Enter the password for @email to reset your PIN.',
    'forgot_pin_google_msg':
        'Verify with your Google account to reset your PIN.',
    'forgot_pin_signed_out_msg':
        'You are not signed in, so your identity cannot be verified. Resetting will permanently erase all logs on this device and remove your PIN.',
    'forgot_pin_verify_failed':
        'Verification failed. Check your password and try again.',
    'forgot_pin_ready_title': 'Identity verified',
    'forgot_pin_ready_msg': 'Choose a new 4-digit PIN to continue.',
    'verify': 'Verify',
    'erase_reset': 'Erase & Reset',
    'skip_security_finish': 'Skip Security & Finish',
    'google_error_10':
        'Google sign-in is not configured for this build. Add your app SHA-1 fingerprint in Firebase and download google-services.json again.',
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
    'forgot_password': 'پاس ورڈ بھول گئے؟',
    'forgot_password_need_title': 'اپنی ای میل درج کریں',
    'forgot_password_need_msg':
        'اوپر والے خانے میں اپنے اکاؤنٹ کی ای میل لکھیں، پھر دوبارہ پاس ورڈ بھول گئے پر ٹیپ کریں۔',
    'forgot_password_sent_title': 'ری سیٹ ای میل بھیج دی گئی',
    'forgot_password_sent_msg':
        'اگر @email کا اکاؤنٹ موجود ہے تو پاس ورڈ ری سیٹ لنک بھیج دیا گیا ہے۔',
    'confirm_password': 'پاس ورڈ کی تصدیق کریں',
    'passwords_mismatch': 'دونوں پاس ورڈ مماثل نہیں ہیں۔',
    'forgot_pin': 'پن بھول گئے؟',
    'forgot_pin_title': 'اپنا پن ری سیٹ کریں؟',
    'forgot_pin_password_title': 'اپنی شناخت کی تصدیق کریں',
    'forgot_pin_password_msg':
        'پن ری سیٹ کرنے کے لیے @email کا پاس ورڈ درج کریں۔',
    'forgot_pin_google_msg':
        'پن ری سیٹ کرنے کے لیے اپنے گوگل اکاؤنٹ سے تصدیق کریں۔',
    'forgot_pin_signed_out_msg':
        'آپ سائن ان نہیں ہیں اس لیے آپ کی شناخت کی تصدیق نہیں ہو سکتی۔ ری سیٹ کرنے سے اس ڈیوائس کے تمام لاگز مستقل طور پر مٹ جائیں گے اور پن ہٹا دیا جائے گا۔',
    'forgot_pin_verify_failed':
        'تصدیق ناکام ہو گئی۔ اپنا پاس ورڈ چیک کر کے دوبارہ کوشش کریں۔',
    'forgot_pin_ready_title': 'شناخت کی تصدیق ہو گئی',
    'forgot_pin_ready_msg': 'جاری رکھنے کے لیے نیا 4 ہندسوں کا پن منتخب کریں۔',
    'verify': 'تصدیق کریں',
    'erase_reset': 'مٹائیں اور ری سیٹ کریں',
    'skip_security_finish': 'سیکیورٹی چھوڑیں اور مکمل کریں',
    'google_error_10':
        'اس بلڈ کے لیے گوگل سائن ان ترتیب نہیں دیا گیا۔ Firebase میں ایپ کا SHA-1 شامل کریں اور google-services.json دوبارہ ڈاؤن لوڈ کریں۔',
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
    'forgot_password': 'पासवर्ड भूल गए?',
    'forgot_password_need_title': 'अपना ईमेल दर्ज करें',
    'forgot_password_need_msg':
        'ऊपर के खाने में अपने अकाउंट का ईमेल लिखें, फिर दोबारा पासवर्ड भूल गए पर टैप करें।',
    'forgot_password_sent_title': 'रीसेट ईमेल भेज दिया गया',
    'forgot_password_sent_msg':
        'यदि @email का अकाउंट मौजूद है तो पासवर्ड रीसेट लिंक भेज दिया गया है।',
    'confirm_password': 'पासवर्ड की पुष्टि करें',
    'passwords_mismatch': 'दोनों पासवर्ड मेल नहीं खाते।',
    'forgot_pin': 'पिन भूल गए?',
    'forgot_pin_title': 'अपना पिन रीसेट करें?',
    'forgot_pin_password_title': 'अपनी पहचान सत्यापित करें',
    'forgot_pin_password_msg':
        'पिन रीसेट करने के लिए @email का पासवर्ड दर्ज करें।',
    'forgot_pin_google_msg':
        'पिन रीसेट करने के लिए अपने Google अकाउंट से सत्यापित करें।',
    'forgot_pin_signed_out_msg':
        'आप साइन इन नहीं हैं, इसलिए आपकी पहचान सत्यापित नहीं हो सकती। रीसेट करने से इस डिवाइस के सभी लॉग हमेशा के लिए मिट जाएँगे और पिन हटा दिया जाएगा।',
    'forgot_pin_verify_failed':
        'सत्यापन विफल रहा। अपना पासवर्ड जाँचें और फिर कोशिश करें।',
    'forgot_pin_ready_title': 'पहचान सत्यापित हुई',
    'forgot_pin_ready_msg': 'जारी रखने के लिए नया 4 अंकों का पिन चुनें।',
    'verify': 'सत्यापित करें',
    'erase_reset': 'मिटाएँ और रीसेट करें',
    'skip_security_finish': 'सुरक्षा छोड़ें और पूरा करें',
    'google_error_10':
        'इस बिल्ड के लिए Google साइन-इन कॉन्फ़िगर नहीं है। Firebase में ऐप का SHA-1 जोड़ें और google-services.json फिर से डाउनलोड करें।',
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
    'forgot_password': 'نسيت كلمة المرور؟',
    'forgot_password_need_title': 'أدخل بريدك الإلكتروني',
    'forgot_password_need_msg':
        'اكتب بريد حسابك في الحقل أعلاه ثم اضغط على نسيت كلمة المرور مرة أخرى.',
    'forgot_password_sent_title': 'تم إرسال رسالة إعادة التعيين',
    'forgot_password_sent_msg':
        'إذا كان هناك حساب لـ @email فقد تم إرسال رابط إعادة تعيين كلمة المرور.',
    'confirm_password': 'تأكيد كلمة المرور',
    'passwords_mismatch': 'كلمتا المرور غير متطابقتين.',
    'forgot_pin': 'نسيت الرمز؟',
    'forgot_pin_title': 'إعادة تعيين الرمز؟',
    'forgot_pin_password_title': 'تحقق من هويتك',
    'forgot_pin_password_msg': 'أدخل كلمة مرور @email لإعادة تعيين الرمز.',
    'forgot_pin_google_msg':
        'تحقق باستخدام حساب Google الخاص بك لإعادة تعيين الرمز.',
    'forgot_pin_signed_out_msg':
        'لم تسجّل الدخول، لذلك لا يمكن التحقق من هويتك. ستؤدي إعادة التعيين إلى حذف جميع السجلات على هذا الجهاز نهائيًا وإزالة الرمز.',
    'forgot_pin_verify_failed':
        'فشل التحقق. تحقق من كلمة المرور وحاول مرة أخرى.',
    'forgot_pin_ready_title': 'تم التحقق من الهوية',
    'forgot_pin_ready_msg': 'اختر رمزًا جديدًا من 4 أرقام للمتابعة.',
    'verify': 'تحقق',
    'erase_reset': 'حذف وإعادة تعيين',
    'skip_security_finish': 'تخطي الحماية وإنهاء الإعداد',
    'google_error_10':
        'لم يتم إعداد تسجيل الدخول عبر Google لهذا الإصدار. أضف بصمة SHA-1 للتطبيق في Firebase ونزّل google-services.json مرة أخرى.',
  };
}
