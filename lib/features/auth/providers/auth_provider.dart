import 'package:flutter/foundation.dart';

import '../models/account_session.dart';

class AuthProvider extends ChangeNotifier {
  AccountSession? _session;
  bool _isLoading = false;
  String? _error;

  AccountSession? get session => _session;
  bool get isLoggedIn => _session != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void setSession(AccountSession? value) {
    _session = value;
    _error = null;
    notifyListeners();
  }

  void setError(String message) {
    _error = message;
    _isLoading = false;
    notifyListeners();
  }

  void finishLoading() {
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _session = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
