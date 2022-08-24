import 'package:flutter/material.dart';

class DialogStatus extends ChangeNotifier {
  String subscribeOutput = "";

  String get getSubscribeOutput => subscribeOutput;

  setSubscribeOutput(String str) {
    subscribeOutput = str;
    notifyListeners();
  }
}
