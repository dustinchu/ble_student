import 'dart:async';
import 'dart:io';

import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_chart_status.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_controller_status.dart';
import 'package:flutter_reactive_ble_example/src/ui/btn_screen.dart';
import 'package:flutter_reactive_ble_example/src/ui/imu_screen.dart';
import 'package:flutter_reactive_ble_example/src/ui/led_screen.dart';
import 'package:flutter_reactive_ble_example/util/characteristic_Id.dart';
import 'package:flutter_reactive_ble_example/util/user.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import '../../widgets.dart';
import '../chart.dart';
import '../electricity_text_screen.dart';
import '../temp_text_screen.dart';
import 'characteristic_interaction_dialog.dart';
import 'service_discovery_list.dart';

part 'device_interaction_tab.g.dart';
//ignore_for_file: annotate_overrides

class DeviceInteractionTab extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceInteractionTab({
    required this.device,
    Key? key,
  }) : super(key: key);

  saveLedCharacteristic(
      BleDeviceInteractor serviceDiscoverer, BuildContext context) async {
    List<DiscoveredService> discoveredService =
        await serviceDiscoverer.discoverServices(device.id);
    discoveredService.asMap().forEach((index, service) {
      for (var i = 0; i < service.characteristicIds.length; i++) {
        if (GetCharacteristicId2(service.characteristics[i]) == "ffc1" ||
            GetCharacteristicId2(service.characteristics[i]) == "ffc2") {
          print(
              "0 =  ${GetCharacteristicId(service.characteristics[i])}   1 = ${service.characteristics[i].characteristicId}   2 = ${service.characteristics[i].serviceId} 3 = ${device.id}");

          Provider.of<BleControllerStatus>(context, listen: false)
              .setCharacteristic(
                  device.id,
                  GetCharacteristicId2(service.characteristics[i]),
                  QualifiedCharacteristic(
                    characteristicId:
                        service.characteristics[i].characteristicId,
                    serviceId: service.characteristics[i].serviceId,
                    deviceId: device.id,
                  ));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      Consumer3<BleDeviceConnector, ConnectionStateUpdate, BleDeviceInteractor>(
          builder: (_, deviceConnector, connectionStateUpdate,
              serviceDiscoverer, __) {
        if (connectionStateUpdate.connectionState ==
            DeviceConnectionState.connected) {
          serviceDiscoverer.discoverServices(device.id);
          saveLedCharacteristic(serviceDiscoverer, context);
          Provider.of<BleControllerStatus>(context, listen: false)
              .setController(
            device.id,
            serviceDiscoverer,
          );
        }

        return DeviceInteraction(
          device: device,
          viewModel: DeviceInteractionViewModel(
            deviceId: device.id,
            connectionStatus: connectionStateUpdate.connectionState,
            deviceConnector: deviceConnector,
            discoverServices: () =>
                serviceDiscoverer.discoverServices(device.id),
            readRssi: () => serviceDiscoverer.readRssi(device.id),
          ),
        );
      });
}

@immutable
@FunctionalData()
class DeviceInteractionViewModel extends $DeviceInteractionViewModel {
  const DeviceInteractionViewModel({
    required this.deviceId,
    required this.connectionStatus,
    required this.deviceConnector,
    required this.discoverServices,
    required this.readRssi,
  });

  final String deviceId;
  final DeviceConnectionState connectionStatus;
  final BleDeviceConnector deviceConnector;
  @CustomEquality(Ignore())
  final Future<List<DiscoveredService>> Function() discoverServices;
  final Future<int> Function() readRssi;
  bool get deviceConnected =>
      connectionStatus == DeviceConnectionState.connected;

  void connect() {
    deviceConnector.connect(deviceId);
  }

  void disconnect() {
    deviceConnector.disconnect(deviceId);
  }
}

class DeviceInteraction extends StatefulWidget {
  const DeviceInteraction({
    required this.device,
    required this.viewModel,
    Key? key,
  }) : super(key: key);
  final DiscoveredDevice device;
  final DeviceInteractionViewModel viewModel;

  @override
  DeviceInteractionState createState() => DeviceInteractionState();
}

class DeviceInteractionState extends State<DeviceInteraction> {
  late List<DiscoveredService> discoveredServices;
  StreamSubscription<List<int>>? sub180f;
  StreamSubscription<List<int>>? sub1601;

  StreamSubscription<List<int>>? sub1602;
  StreamSubscription<List<int>>? sub1604;
  StreamSubscription<List<int>>? sub1605;
  StreamSubscription<List<int>>? sub1606;
  StreamSubscription<List<int>>? sub2a6e;
  StreamSubscription<List<int>>? subffc3;
  Timer timer = Timer(const Duration(minutes: 1), () {});
  int rssi = 0;
  @override
  void dispose() {
    print(" subscribeStream?.cancel();");

    cancelTimer();
    sub1601?.cancel();
    sub1602?.cancel();
    sub1604?.cancel();
    sub1605?.cancel();
    sub1606?.cancel();
    sub2a6e?.cancel();
    subffc3?.cancel();
    sub180f?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    rssi = widget.device.rssi;
    print("rssi=====$rssi");
    startTimer();
    discoveredServices = [];
    discoverServices();
    super.initState();
  }

  startTimer() async {
    cancelTimer();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      try {
        rssi = await readRssi();
        setState(() {});
      } catch (e) {
        print("read rssi error$e");
      }
    });
  }

  cancelTimer() {
    print(" time.cancel();");
    timer.cancel();
  }

  Future<void> discoverServices() async {
    final result = await widget.viewModel.discoverServices();
    setState(() {
      discoveredServices = result;
    });
  }

  Future<int> readRssi() async {
    final r = await widget.viewModel.readRssi();
    return r;
  }

  initSendFF10(BleDeviceInteractor bleDeviceInteractor, int value) async {
    bleDeviceInteractor.writeCharacterisiticWithResponse(
        QualifiedCharacteristic(
            characteristicId: Uuid.parse('ff10'),
            serviceId: Uuid.parse('ff00'),
            deviceId: widget.device.id),
        [value]);
  }

  Future<void> initRead1080f(BleDeviceInteractor bleDeviceInteractor) async {
    List<int> electricity = await bleDeviceInteractor.readCharacteristic(
      QualifiedCharacteristic(
          characteristicId: Uuid.parse('2a19'),
          serviceId: Uuid.parse('180f'),
          deviceId: widget.device.id),
    );
    print("180f read =======$electricity");
    Provider.of<BleChartStatus>(context, listen: false)
        .setElectricity(electricity[0]);
  }

  Future<void> subscribeCharacteristic2a6e(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('2A6e'),
        serviceId: Uuid.parse('181A'),
        deviceId: widget.device.id);
    sub2a6e = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      if (sub2a6e != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false).setTemp(event);
        }
      }
    });
  }

  Future<void> subscribeCharacteristicffc3(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('ffc3'),
        serviceId: Uuid.parse('ffc0'),
        deviceId: widget.device.id);
    subffc3 = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      if (subffc3 != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false).setBtn(event[0]);
        }
      }
    });
  }

  Future<void> subscribeCharacteristic180f(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('2a19'),
        serviceId: Uuid.parse('180f'),
        deviceId: widget.device.id);
    sub180f = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      if (sub180f != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false)
              .setElectricity(event[0]);
        }
      }

      print("180f sub =======$event");
    });
  }

  Future<void> subscribeCharacteristic1601(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('1601'),
        serviceId: Uuid.parse('1600'),
        deviceId: widget.device.id);
    sub1601 = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      if (sub1601 != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false)
              .set1601Data(event);
        }
      }
    });
  }

  Future<void> subscribeCharacteristic1602(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('1602'),
        serviceId: Uuid.parse('1600'),
        deviceId: widget.device.id);
    sub1602 = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      // print("-------------1602 ${event.toString()}");
      // if (!mounted) {
      if (sub1602 != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false).dmpData(event);
        }
      }
    });
  }

  Future<void> subscribeCharacteristic1604(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('1604'),
        serviceId: Uuid.parse('1600'),
        deviceId: widget.device.id);
    sub1604 = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      // print("-------------sub1604 ${event.toString()}");
      // if (!mounted) {
      if (sub1604 != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false).dmpData(event);
        }
      }
    });
  }

  Future<void> subscribeCharacteristic1605(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('1605'),
        serviceId: Uuid.parse('1600'),
        deviceId: widget.device.id);
    sub1605 = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      // print("-------------1605 ${event.toString()}");
      // if (!mounted) {
      if (sub1605 != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false)
              .set1605Data(event);
        }
      }
    });
  }

  Future<void> subscribeCharacteristic1606(
      BleDeviceInteractor bleDeviceInteractor) async {
    QualifiedCharacteristic qualified = QualifiedCharacteristic(
        characteristicId: Uuid.parse('1606'),
        serviceId: Uuid.parse('1600'),
        deviceId: widget.device.id);
    sub1606 = bleDeviceInteractor
        .subScribeToCharacteristic(qualified)
        .listen((event) {
      // if (!mounted) {
      if (sub1606 != null) {
        if (mounted) {
          Provider.of<BleChartStatus>(context, listen: false)
              .set1605Data(event);
        }
      }
    });
  }

  int ff10Type = 00;
  bool initStatus = true;
  @override
  Widget build(BuildContext context) {
    return Consumer3<BleDeviceConnector, ConnectionStateUpdate,
            BleDeviceInteractor>(
        builder:
            (_, deviceConnector, connectionStateUpdate, serviceDiscoverer, __) {
      if (connectionStateUpdate.connectionState ==
          DeviceConnectionState.connected) {
        if (initStatus) {
          initSendFF10(serviceDiscoverer, ff10Type);
          initRead1080f(serviceDiscoverer);
          subscribeCharacteristic180f(serviceDiscoverer);
          subscribeCharacteristic1601(serviceDiscoverer);
          subscribeCharacteristic1602(serviceDiscoverer);
          subscribeCharacteristic1604(serviceDiscoverer);
          subscribeCharacteristic1605(serviceDiscoverer);
          subscribeCharacteristic1606(serviceDiscoverer);
          subscribeCharacteristic2a6e(serviceDiscoverer);
          subscribeCharacteristicffc3(serviceDiscoverer);
          initStatus = false;
        }
      }

      return ListView(
        children: [
          ListTile(
            leading: BluetoothIcon(
                connectStatus: widget.viewModel.connectionStatus ==
                    DeviceConnectionState.connected),
            title: Text(widget.device.name),
            subtitle: Text(widget.device.id),
            trailing: Padding(
                padding: const EdgeInsets.only(right: 0),
                // WifiIcon(
                //   rssi: widget.device.rssi,
                // ),
                // if (widget.viewModel.deviceConnected)
                //   _ServiceDiscoveryList(
                //     deviceId: widget.viewModel.deviceId,
                //     discoveredServices: discoveredServices,
                //   ),
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ServiceDiscoveryList(
                                deviceConnected:
                                    widget.viewModel.deviceConnected,
                                discoveredServices: discoveredServices,
                                deviceId: widget.viewModel.deviceId)),
                      );
                    },
                    icon: Icon(Icons.touch_app))),
          ),
          const Divider(thickness: 2.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    ElectricityTextScreen(),
                    SizedBox(
                      height: 5,
                    ),
                    // Text("溫度:80°C"),
                    TempTextScreen(),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("RSSI:$rssi"),
                    const SizedBox(
                      height: 5,
                    ),
                    const BtnScreen(),
                  ],
                )
              ],
            ),
          ),
          const Divider(thickness: 2.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                          builder: (BuildContext context) =>
                              LED(mac: widget.device.id)),
                    );
                  },
                  child: Text("LED設定"),
                ),
                TextButton(
                  onPressed: () async {
                    // readRssi();
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ImuScreen(
                                  deviceId: widget.device.id,
                                )));
                  },
                  child: Text("IMU設定"),
                )
              ],
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Center(
            child: CupertinoRadioChoice(
                choices: const {
                  '1601': 'SIX',
                  '1602': 'ACC',
                  '1604': 'GYRO',
                  '1605': 'DMP',
                  '1606': 'ACC'
                },
                notSelectedColor: Colors.transparent,
                onChange: (selectedGender) {
                  switch (selectedGender) {
                    case "1601":
                      ff10Type = 00;
                      initSendFF10(serviceDiscoverer, ff10Type);
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setType(1601);
                      Provider.of<BleChartStatus>(context, listen: false)
                          .cleanData();
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setLineCount(
                              line_count: 6, max_y: 32767, min_y: -32768);
                      print("00");
                      break;
                    case "1602":
                      ff10Type = 03;
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setType(1602);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      print("03");
                      break;
                    case "1604":
                      ff10Type = 04;
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setType(1604);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      print("04");
                      break;
                    case "1605":
                      ff10Type = 01;
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setType(1605);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      Provider.of<BleChartStatus>(context, listen: false)
                          .cleanData();
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setLineCount(
                              line_count: 3, max_y: 32767, min_y: -32768);
                      print("05");
                      break;
                    case "1606":
                      ff10Type = 02;
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setType(1606);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      Provider.of<BleChartStatus>(context, listen: false)
                          .cleanData();
                      Provider.of<BleChartStatus>(context, listen: false)
                          .setLineCount(
                              line_count: 3, max_y: 32767, min_y: -32768);
                      print("02");
                      break;
                  }
                },
                initialKeyValue: 'state'),
          ),
          SizedBox(
            height: 20,
          ),
          LineChartSample1(),
          // Expanded(
          //   child: CustomScrollView(
          //     slivers: [
          //       SliverList(
          //         delegate: SliverChildListDelegate.fixed(
          //           [
          //             if (widget.viewModel.deviceConnected)
          //               _ServiceDiscoveryList(
          //                 deviceId: widget.viewModel.deviceId,
          //                 discoveredServices: discoveredServices,
          //               ),
          //           ],
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
        ],
      );
    });
  }
}

class _ServiceDiscoveryList extends StatefulWidget {
  const _ServiceDiscoveryList({
    required this.deviceId,
    required this.discoveredServices,
    Key? key,
  }) : super(key: key);

  final String deviceId;
  final List<DiscoveredService> discoveredServices;

  @override
  _ServiceDiscoveryListState createState() => _ServiceDiscoveryListState();
}

class _ServiceDiscoveryListState extends State<_ServiceDiscoveryList> {
  late final List<int> _expandedItems;

  @override
  void initState() {
    print("---------${widget.discoveredServices.length}");
    _expandedItems = [];
    super.initState();
  }

  Widget _characteristicTile(
      DiscoveredCharacteristic characteristic, String deviceId) {
    return ListTile(
      onTap: () => showDialog<void>(
          context: context,
          builder: (c) {
            User.instance.context = c;
            return CharacteristicInteractionDialog(
              characteristicStr: CharactisticsSummary(characteristic),
              characteristic: QualifiedCharacteristic(
                characteristicId: characteristic.characteristicId,
                serviceId: characteristic.serviceId,
                deviceId: deviceId,
              ),
            );
          }),
      title: Text(
        GetCharacteristicId(characteristic),
        style: const TextStyle(
          fontSize: 14,
        ),
      ),
    );
  }

  List<Widget> buildPanels() {
    List<Widget> panels = [];

    widget.discoveredServices.asMap().forEach((index, service) {
      panels.add(Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsetsDirectional.only(
          top: 10.0,
          start: 14.0,
          bottom: 10.0,
        ),
        width: double.infinity,
        color: const Color(0xFF243E4D).withOpacity(0.3),
        child: Text(
          Platform.isIOS
              ? "${service.serviceId}"
              : service.serviceId.toString().substring(4, 8),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ));
      for (var i = 0; i < service.characteristicIds.length; i++) {
        panels.add(_characteristicTile(
          service.characteristics[i],
          widget.deviceId,
        ));
        if (i != service.characteristicIds.length - 1) {
          panels.add(const Divider(thickness: 2.0));
        }
      }
    });

    return panels;
  }

  @override
  Widget build(BuildContext context) => widget.discoveredServices.isEmpty
      ? const SizedBox()
      : Padding(
          padding: const EdgeInsetsDirectional.only(
            top: 20.0,
            start: 20.0,
            end: 20.0,
          ),
          child: Column(
            children: buildPanels(),
          ),
        );
}
