import 'package:flutter/material.dart';

class TempVariables extends ChangeNotifier {
  void Function()? pageChanged;
  void Function()? storyIndexChanged;
  void Function(String query)? onSearch;
  void Function()? onSettingsUpdated;

  String? _tempFirstName;
  int _tempIndex = 1;
  int _tempStoryIndex = 1;

  String? get tempFirstName => _tempFirstName;
  int get tempIndex => _tempIndex;
  int get tempStoryIndex => _tempStoryIndex;

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

  void setTempStoryIndex(int index) {
    _tempStoryIndex = index;
    notifyListeners();

    if(storyIndexChanged != null)
      storyIndexChanged!();
  }

  void settingsUpdated() {
    print(onSettingsUpdated != null);
    if(onSettingsUpdated != null)
      onSettingsUpdated!();
  }
}