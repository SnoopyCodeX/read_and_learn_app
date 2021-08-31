import 'package:flutter/material.dart';

class TempVariables extends ChangeNotifier {
  void Function()? pageChanged;

  TempVariables({this.pageChanged});

  String? _tempFirstName;
  int _tempIndex = 1;

  String? get tempFirstName => _tempFirstName;
  int get tempIndex => _tempIndex;

  void setTempFirstName(String name) {
    _tempFirstName = name;
    notifyListeners();
  }

  void setTempIndex(int index) {
    _tempIndex = index;
    notifyListeners();

    if(pageChanged != null)
      pageChanged!();
  }
}