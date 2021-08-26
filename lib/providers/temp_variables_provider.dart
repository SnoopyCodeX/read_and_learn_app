import 'package:flutter/material.dart';

class TempVariables extends ChangeNotifier {
  String? _tempFirstName;

  String? get tempFirstName => _tempFirstName;

  void setTempFirstName(String name) {
    _tempFirstName = name;
    notifyListeners();
  }
}