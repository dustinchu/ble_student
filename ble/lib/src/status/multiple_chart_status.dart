import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';

class MultipleChartStatus extends ChangeNotifier {
  late Map<String, QualifiedCharacteristic> bleCharacteristic = {};
  //  Dart Unhandled Exception: type '_InternalLinkedHashMap
  Map<String, BleDeviceInteractor> bleController = {};
  String writeStatus = "";

  BleDeviceInteractor? getBleController(String mac) {
    return bleController["mac"];
  }

  setCharacteristic(String key, String characteristicId,
      QualifiedCharacteristic characteristic) {
    bleCharacteristic[key + characteristicId] = characteristic;
  }

  setController(String key, BleDeviceInteractor bleDeviceInteractor) {
    print("set controller  key ====$key");
    bleController[key] = bleDeviceInteractor;
  }

  QualifiedCharacteristic getQualifiedCharacteristic(String mac, String id) {
    return bleCharacteristic[mac + id] ??= QualifiedCharacteristic(
        characteristicId: Uuid.parse('ff01'),
        serviceId: Uuid.parse('ffc0'),
        deviceId: mac);
  }
}
