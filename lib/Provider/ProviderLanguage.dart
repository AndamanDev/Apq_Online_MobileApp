import 'package:flutter/material.dart';

class ProviderLanguage extends ChangeNotifier {
  Locale _locale = const Locale('th');

  Locale get locale => _locale;

  void changeLanguage(String languageCode) {
    _locale = Locale(languageCode);
    notifyListeners();
  }
}
