import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:iccm_eu_app/utils/debug.dart';

import '../model/error_signal.dart';

class ErrorProvider with ChangeNotifier {
  ErrorSignal? _errorSignal;

  ErrorSignal? get errorSignal => _errorSignal;

  void setErrorSignal(ErrorSignal signal) {
    Debug.msg(signal.message);
    _errorSignal = signal;
    notifyListeners();
  }

  void clearErrorSignal() {
    _errorSignal = null;
    // FIXME: Throws errors
    // notifyListeners();
  }
}