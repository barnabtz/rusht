import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get appTitle => 'Russhit';
  String get login => 'Login';
  String get register => 'Register';
  String get email => 'Email';
  String get password => 'Password';
  String get fullName => 'Full Name';
  String get phoneNumber => 'Phone Number';
  String get address => 'Address';
  String get profile => 'Profile';
  String get editProfile => 'Edit Profile';
  String get save => 'Save';
  String get cancel => 'Cancel';
  String get signOut => 'Sign Out';
  String get ownerMode => 'Owner Mode';
  String get ownerModeDescription => 'Enable to list items for rent';
  String get locationUpdated => 'Location updated successfully';
  String get profileUpdated => 'Profile updated successfully';
  String get profilePictureUpdated => 'Profile picture updated successfully';
  String get errorOccurred => 'An error occurred';
  String get pleaseEnterYourName => 'Please enter your name';
  String get pleaseEnterYourPhone => 'Please enter your phone number';
  String get pleaseEnterYourAddress => 'Please enter your address';
  String get createRequest => 'Create Request';
  String get requestTitle => 'Request Title';
  String get requestTitleHint => 'Enter the title of your request';
  String get requestTitleRequired => 'Title is required';
  String get requestDescription => 'Description';
  String get requestDescriptionHint => 'Enter a description';
  String get requestDescriptionRequired => 'Description is required';
  String get requestCategory => 'Category';
  String get categoryElectronics => 'Electronics';
  String get categoryFurniture => 'Furniture';
  String get categoryTools => 'Tools';
  String get categorySports => 'Sports';
  String get requestBudgetMin => 'Minimum Budget';
  String get requestBudgetRequired => 'Budget is required';
  String get requestBudgetInvalid => 'Invalid budget';
  String get requestBudgetMax => 'Maximum Budget';
  String get requestBudgetMaxTooLow => 'The maximum budget cannot be lower than the minimum budget.';
  String get requestNeededBy => 'Needed By';
  String get requestNeededByDate => 'Needed By Date';
  String get requestImages => 'Images';
  String get requestAddImage => 'Add Image';
  String get submitRequest => 'Submit Request';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    final localizations = AppLocalizations(locale);
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
