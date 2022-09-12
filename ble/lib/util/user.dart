import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class User {
  static final User _singleton = new User._internal();
  User._internal();
  static User get instance => _singleton;
  BuildContext? context;
  String clickDeviceName = "";

  FlutterReactiveBle? ble;
}
