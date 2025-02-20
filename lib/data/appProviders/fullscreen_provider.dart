import 'package:flutter/material.dart';

class FullscreenProvider with ChangeNotifier {
  bool _isFullscreen = false;

  bool get isFullscreen => _isFullscreen;

  void toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    notifyListeners();
  }
}