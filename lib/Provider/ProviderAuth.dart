import 'package:flutter/material.dart';
import '../Database/DatabaseAuth.dart';
import '../Models/ModelsAuth.dart';

class ProviderAuth extends ChangeNotifier {
  Modelsauth? _auth;
  bool _isLoading = true;

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _auth != null;
  Modelsauth? get auth => _auth;

  String? get domain => _auth?.domain;
  String? get username => _auth?.username;

  Future<void> loadFromDb() async {
    _auth = await Databaseauth.getAuth();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> setAuth(Modelsauth auth) async {
    _auth = auth;
    await Databaseauth.saveAuth(auth);
    notifyListeners();
  }

  Future<void> logout() async {
    _auth = null;
    await Databaseauth.logout();
    notifyListeners();
  }
}
