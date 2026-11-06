// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get welcome => 'ECpay में आपका स्वागत है!';

  @override
  String get loginSubtitle => 'भुगतान जारी रखने के लिए लॉगिन करें';

  @override
  String get email => 'ईमेल';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get login => 'लॉगिन';

  @override
  String get register => 'रजिस्टर करें';

  @override
  String get noAccount => 'खाता नहीं है?';

  @override
  String get yourBalance => 'आपका बैलेंस';

  @override
  String get quickActions => 'त्वरित कार्य';

  @override
  String get send => 'भेजें';

  @override
  String get scan => 'स्कैन';

  @override
  String get history => 'इतिहास';

  @override
  String get sendMoney => 'पैसे भेजें';

  @override
  String get recentTransactions => 'हाल के लेन-देन';

  @override
  String get home => 'होम';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get selectLanguage => 'भाषा चुनें';
}
