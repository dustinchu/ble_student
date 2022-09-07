import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/status/connect.dart';
import 'package:flutter_reactive_ble_example/util/user.dart';
import 'package:provider/provider.dart';

class ConnectStatus extends StatelessWidget {
  ConnectStatus(
      {Key? key,
      required this.device,
      required this.connectState,
      required this.connectionStateUpdate,
      required this.bleConnector})
      : super(key: key);
  DiscoveredDevice device;
  DeviceConnectionState connectState;
  ConnectionStateUpdate connectionStateUpdate;
  BleDeviceConnector bleConnector;
  @override
  Widget build(BuildContext context) {
    var connect = Provider.of<Connect>(context);
    String connectStateMsg(DeviceConnectionState connectState) {
      switch (connectState) {
        case DeviceConnectionState.connecting:
          return "Connecting";
        case DeviceConnectionState.connected:
          return "Disconnect";
        case DeviceConnectionState.disconnected:
          return "Connect";
        case DeviceConnectionState.disconnecting:
          return "Connect";
        default:
          return "N/A";
      }
    }

    if (connect.msg[device.id] != null &&
        device.id == User.instance.clickDeviceName) {
      Map<String, dynamic> m = {};
      m = connect.msg[device.id];
      if (connectStateMsg(connectionStateUpdate.connectionState) ==
          "Disconnect") {
        m["connectStatus"] = "Y";
      } else {
        m["connectStatus"] = "N";
      }
      m["state"] = connectStateMsg(connectionStateUpdate.connectionState);
      connect.setMsg(device, m);
    }

    // return Text(connect.msg[device] != null
    //     ? connect.msg[device]["state"]
    //     : "Connect");
    return TextButton(
        // child: ConnectStatus(
        //   connectState: connectionStateUpdate.connectionState,
        //   connectionStateUpdate: connectionStateUpdate,
        //   device: device,
        // ),
        child: Text(connect.msg == null
            ? "Connect"
            : connect.msg[device.id] != null
                ? connect.msg[device.id]["state"]
                : "Connect"),
        onPressed: () async {
          Map<String, dynamic> m = {};

          User.instance.clickDeviceName = device.id;
          if (connect.msg[device.id] == null) {
            print("連線==${device.id}");
            bleConnector.connect(device.id);
            connect.setDiscover(device);

            m["connectStatus"] == "Y";
            connect.setMsg(device, m);
          } else {
            if (connect.msg[device.id]["connectStatus"] == "Y") {
              print("關閉連線 ===${device.id}");
              m = connect.msg[device.id];
              bleConnector.disconnect(device.id);
              m["connectStatus"] == "N";
              connect.setMsg(device, m);
              connect.remove(device.id);
            }
          }
          // for (var i = 0; i < 100; i++) {
          //       if (connectionStateUpdate
          //               .connectionState ==
          //           DeviceConnectionState.connecting) {
          //         await Future.delayed(
          //             const Duration(seconds: 1));
          //         if (count == 10) {
          //           await deviceConnector
          //               .disconnect(device);
          //           await deviceConnector
          //               .connect(device);
          //         }
          //         ++count;
          //       } else {
          //         break;
          //       }
          //     }
          // if (connectionStateUpdate.device ==
          //     device) {
          //   print(
          //       "device name ==$connectionStateUpdate    id====${device}");
          //   if (connectionStateUpdate.connectionState !=
          //       DeviceConnectionState.connecting) {
          //     if (connectionStateUpdate.connectionState ==
          //             DeviceConnectionState
          //                 .disconnected ||
          //         connectionStateUpdate.connectionState ==
          //             DeviceConnectionState
          //                 .disconnecting) {
          //       deviceConnector.connect(device);
          //       int count = 1;
          //       for (var i = 0; i < 100; i++) {
          //         if (connectionStateUpdate
          //                 .connectionState ==
          //             DeviceConnectionState.connecting) {
          //           await Future.delayed(
          //               const Duration(seconds: 1));
          //           if (count == 10) {
          //             await deviceConnector
          //                 .disconnect(device);
          //             await deviceConnector
          //                 .connect(device);
          //           }
          //           ++count;
          //         } else {
          //           break;
          //         }
          //       }
          //     }
          //   }
          // if (connectionStateUpdate.connectionState ==
          //     DeviceConnectionState.connected) {
          //   deviceConnector.disconnect(device);
          // }
          // }
        });
  }
}
