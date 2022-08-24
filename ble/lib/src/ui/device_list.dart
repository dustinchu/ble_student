import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:provider/provider.dart';

import '../widgets.dart';
import 'device_detail/device_detail_screen.dart';
import 'wifi_icon.dart';

class DeviceListScreen extends StatelessWidget {
  const DeviceListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer2<BleScanner, BleScannerState?>(
        builder: (_, bleScanner, bleScannerState, __) => _DeviceList(
          scannerState: bleScannerState ??
              const BleScannerState(
                discoveredDevices: [],
                scanIsInProgress: false,
              ),
          startScan: bleScanner.startScan,
          stopScan: bleScanner.stopScan,
        ),
      );
}

class _DeviceList extends StatefulWidget {
  const _DeviceList(
      {required this.scannerState,
      required this.startScan,
      required this.stopScan});

  final BleScannerState scannerState;
  final void Function() startScan;
  final VoidCallback stopScan;

  @override
  _DeviceListState createState() => _DeviceListState();
}

class _DeviceListState extends State<_DeviceList> {
  @override
  void initState() {
    super.initState();
    widget.startScan();
  }

  @override
  void dispose() {
    // widget.stopScan();
    super.dispose();
  }

  void _startScanning() {
    widget.startScan();
  }

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

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // IconButton(
                      //   onPressed: () {},
                      //   icon: const Icon(Icons.bar_chart_outlined),
                      // ),
                      IconButton(
                        onPressed: () {
                          if (!widget.scannerState.scanIsInProgress) {
                            _startScanning();
                          }
                          if (widget.scannerState.scanIsInProgress) {
                            widget.stopScan();
                          }
                        },
                        icon: Icon(!widget.scannerState.scanIsInProgress
                            ? Icons.play_arrow
                            : Icons.stop),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          "Scanner",
                          style: TextStyle(
                              fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                      if (widget.scannerState.scanIsInProgress ||
                          widget.scannerState.discoveredDevices.isNotEmpty)
                        Padding(
                          padding:
                              const EdgeInsetsDirectional.only(start: 18.0),
                          child: Text(
                              'count: ${widget.scannerState.discoveredDevices.length}'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: ListView(
                children: widget.scannerState.discoveredDevices.map((device) {
                  return Consumer3<BleDeviceConnector, ConnectionStateUpdate,
                          BleDeviceInteractor>(
                      builder: (_, deviceConnector, connectionStateUpdate,
                          serviceDiscoverer, __) {
                    return ListTile(
                      minLeadingWidth: 10,
                      title: Text("${device.name}\nRssi : ${device.rssi}"),
                      // subtitle: Text(
                      //   device.id,
                      // ),
                      leading: BluetoothIcon(
                          connectStatus:
                              connectionStateUpdate.connectionState ==
                                  DeviceConnectionState.connected),
                      trailing: SizedBox(
                        width: 140,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            WifiIcon(
                              rssi: device.rssi,
                            ),
                            const Spacer(),
                            TextButton(
                                child: Text(connectStateMsg(
                                    connectionStateUpdate.connectionState)),
                                onPressed: () async {
                                  if (connectionStateUpdate.connectionState !=
                                      DeviceConnectionState.connecting) {
                                    if (connectionStateUpdate.connectionState ==
                                            DeviceConnectionState
                                                .disconnected ||
                                        connectionStateUpdate.connectionState ==
                                            DeviceConnectionState
                                                .disconnecting) {
                                      deviceConnector.connect(device.id);
                                      int count = 1;
                                      for (var i = 0; i < 100; i++) {
                                        if (connectionStateUpdate
                                                .connectionState ==
                                            DeviceConnectionState.connecting) {
                                          await Future.delayed(
                                              const Duration(seconds: 1));
                                          if (count == 10) {
                                            await deviceConnector
                                                .disconnect(device.id);
                                            await deviceConnector
                                                .connect(device.id);
                                          }
                                          ++count;
                                        } else {
                                          break;
                                        }
                                      }
                                    }
                                  }
                                  if (connectionStateUpdate.connectionState ==
                                      DeviceConnectionState.connected) {
                                    deviceConnector.disconnect(device.id);
                                  }
                                }),
                          ],
                        ),
                      ),
                      onTap: () async {
                        // widget.stopScan();
                        if (connectionStateUpdate.connectionState ==
                            DeviceConnectionState.connected) {
                          await Navigator.push<void>(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      DeviceDetailScreen(device: device)));
                        }
                      },
                    );
                  });
                  // return ListTile(
                  //   title: Text(device.name),
                  //   trailing: TextButton(
                  //       child: const Text('Connect'), onPressed: () {}),
                  //   // subtitle: Text("${device.id}"),
                  //   leading: const BluetoothIcon(),
                  //   onTap: () async {
                  //     widget.stopScan();
                  //     await Navigator.push<void>(
                  //         context,
                  //         MaterialPageRoute(
                  //             builder: (_) =>
                  //                 DeviceDetailScreen(device: device)));
                  //   },
                  // );
                }).toList(),
              ),
            ),
          ],
        ),
      );
}
