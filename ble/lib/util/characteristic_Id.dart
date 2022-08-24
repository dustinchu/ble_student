import 'dart:io';

import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

String CharactisticsSummary(DiscoveredCharacteristic c) {
  final props = <String>[];
  if (c.isReadable) {
    props.add("read");
  }
  if (c.isWritableWithoutResponse) {
    // props.add("write without response");
    props.add("write");
  }
  if (c.isWritableWithResponse) {
    // props.add("write with response");
    props.add("write");
  }
  if (c.isNotifiable) {
    props.add("notify");
  }
  if (c.isIndicatable) {
    props.add("indicate");
  }

  return props.join(" ");
}

String GetCharacteristicId(characteristic) => Platform.isIOS
    ? "${characteristic.characteristicId.toString()} \n(${CharactisticsSummary(characteristic)}"
    : '${characteristic.characteristicId.toString().substring(4, 8)} \n(${CharactisticsSummary(characteristic)})';

String GetCharacteristicId2(characteristic) => Platform.isIOS
    ? "${characteristic.characteristicId.toString()}"
    : '${characteristic.characteristicId.toString().substring(4, 8)}';
