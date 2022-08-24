import 'package:flutter/material.dart';

class User {
  static final User _singleton = new User._internal();
  User._internal();
  static User get instance => _singleton;
  BuildContext? context;
}
