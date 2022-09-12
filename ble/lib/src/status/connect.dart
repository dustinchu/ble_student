import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class Connect extends ChangeNotifier {
  Map<String, dynamic> msg = {};
  Map<String, ConnectionStateUpdate>? connectionStreamSubscription;
  final flutterReactiveBle = FlutterReactiveBle();
  Map<String, DiscoveredDevice> mapDiscoveredDevice = {};

//  int id2 = await txn.rawInsert(
//       'INSERT INTO Test(name, value, num) VALUES(?, ?, ?)',
//       ['another name', 12345678, 3.1416]);
  setMsg(DiscoveredDevice d, Map<String, dynamic> m) {
    msg[d.id] = m;

    // notifyListeners();
  }

  setDiscover(DiscoveredDevice d) {
    mapDiscoveredDevice[d.id] = d;
  }

  remove(String key) {
    msg.remove(key);
    // notifyListeners();
  }
}
