import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';

class BleControllerStatus extends ChangeNotifier {
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
// : Exception: GenericFailure<WriteCharacteristicFailure>(code: WriteCharacteristicFailure.unknown, message: "A characteristic FF01 is not found in the service FFC0 of the peripheral 507CF1E3-F50D-E794-E3CF-0CF6220A1BC7 (make sure it has been discovered)")
  // test(String mac, List<int> value) async {
  //   print("set controller  key2 ====$mac");
  //   print("-------test  ==${bleCharacteristic[mac + "ff01"]}");
  //   await bleController[mac]!.writeCharacterisiticWithResponse(
  //       bleCharacteristic[mac + "ff01"] ??= QualifiedCharacteristic(
  //           characteristicId: Uuid.parse('ff01'),
  //           serviceId: Uuid.parse('ffc0'),
  //           deviceId: mac),
  //       value);
  //   print("ok");
  // }
  //  return intTohex (String text){

  // }

  QualifiedCharacteristic getQualifiedCharacteristic(String mac, String id) {
    return bleCharacteristic[mac + id] ??= QualifiedCharacteristic(
        characteristicId: Uuid.parse('ff01'),
        serviceId: Uuid.parse('ffc0'),
        deviceId: mac);
  }

  // write(String key, QualifiedCharacteristic characteristic,
  //     List<int> value) async {
  //   await bleController[key]!
  //       .writeCharacterisiticWithResponse(characteristic, value);

  //   writeStatus = "OK";
  //   notifyListeners();
  // }
}
