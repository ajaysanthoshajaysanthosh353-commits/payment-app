// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get welcome => 'Welcome to ECpay!';

  @override
  String get loginSubtitle => 'Login to continue making payments';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get yourBalance => 'Your Balance';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get send => 'Send';

  @override
  String get scan => 'Scan';

  @override
  String get history => 'History';

  @override
  String get sendMoney => 'Send Money';

  @override
  String get recentTransactions => 'Recent Transactions';

  @override
  String get home => 'Home';

  @override
  String get profile => 'Profile';

  @override
  String get selectLanguage => 'Select Language';
}
