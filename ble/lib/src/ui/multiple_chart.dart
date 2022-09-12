import 'dart:async';
import 'dart:io';

import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_controller_status.dart';
import 'package:flutter_reactive_ble_example/src/status/home_ble_chart_status.dart';
import 'package:flutter_reactive_ble_example/util/characteristic_Id.dart';
import 'package:flutter_reactive_ble_example/util/user.dart';
import 'package:functional_data/functional_data.dart';
import 'package:provider/provider.dart';

import 'device_detail/characteristic_interaction_dialog.dart';
import 'device_detail/device_interaction_tab.dart';
import 'home_chart.dart';

//ignore_for_file: annotate_overrides

class MultipleChart extends StatelessWidget {
  final DiscoveredDevice device;

  const MultipleChart({
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
  StreamSubscription<List<int>>? sub1601;

  StreamSubscription<List<int>>? sub1602;
  StreamSubscription<List<int>>? sub1604;
  StreamSubscription<List<int>>? sub1605;
  StreamSubscription<List<int>>? sub1606;
  Timer timer = Timer(const Duration(minutes: 1), () {});
  @override
  void dispose() {
    print(" subscribeStream?.cancel();");

    sub1601?.cancel();
    sub1602?.cancel();
    sub1604?.cancel();
    sub1605?.cancel();
    sub1606?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    discoveredServices = [];
    Provider.of<HomeBleChartStatus>(context, listen: false)
        .init(widget.device.id);
    discoverServices();
    super.initState();
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
          Provider.of<HomeBleChartStatus>(context, listen: false)
              .set1601Data(widget.device.id, event);
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
          Provider.of<HomeBleChartStatus>(context, listen: false)
              .set1602dmpaData(widget.device.id, event);
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
          Provider.of<HomeBleChartStatus>(context, listen: false)
              .set1604dmpgData(widget.device.id, event);
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
          Provider.of<HomeBleChartStatus>(context, listen: false)
              .set1605DmpData(widget.device.id, event);
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
          Provider.of<HomeBleChartStatus>(context, listen: false)
              .set1606gyroData(widget.device.id, event);
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
          subscribeCharacteristic1601(serviceDiscoverer);
          subscribeCharacteristic1602(serviceDiscoverer);
          subscribeCharacteristic1604(serviceDiscoverer);
          subscribeCharacteristic1605(serviceDiscoverer);
          subscribeCharacteristic1606(serviceDiscoverer);
          initStatus = false;
        }
      }
// Multiple
      return ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: double.infinity,
          ),
          Center(
            child: CupertinoRadioChoice(
                choices: const {
                  '1601': 'SIX',
                  '1606': 'GYRO',
                  '1605': 'ACC',
                  '1602': 'DMP_A',
                  '1604': 'DMP_G',
                },
                notSelectedColor: Colors.transparent,
                onChange: (selectedGender) {
                  switch (selectedGender) {
                    case "1601":
                      ff10Type = 00;
                      initSendFF10(serviceDiscoverer, ff10Type);
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setType(widget.device.id, 1601);
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .cleanData(widget.device.id);
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setLineCount(
                              deviceId: widget.device.id,
                              line_count: 6,
                              max_y: 32767,
                              min_y: -32768);
                      print("00");
                      break;
                    case "1602":
                      ff10Type = 03;
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setType(widget.device.id, 1602);
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setLineCount(
                              deviceId: widget.device.id,
                              line_count: 6,
                              max_y: 32767,
                              min_y: -32768);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      print("03");
                      break;
                    case "1604":
                      ff10Type = 04;
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setType(widget.device.id, 1604);
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setLineCount(
                              deviceId: widget.device.id,
                              line_count: 3,
                              max_y: 32767,
                              min_y: -32768);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      print("04");
                      break;
                    case "1605":
                      ff10Type = 01;
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setType(widget.device.id, 1605);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      // Provider.of<HomeBleChartStatus>(context, listen: false)
                      //     .cleanData(widget.device.id);
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setLineCount(
                              deviceId: widget.device.id,
                              line_count: 3,
                              max_y: 32767,
                              min_y: -32768);
                      print("05");
                      break;
                    case "1606":
                      ff10Type = 02;
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setType(widget.device.id, 1606);
                      initSendFF10(serviceDiscoverer, ff10Type);
                      // Provider.of<HomeBleChartStatus>(context, listen: false)
                      //     .cleanData(widget.device.id);
                      Provider.of<HomeBleChartStatus>(context, listen: false)
                          .setLineCount(
                              deviceId: widget.device.id,
                              line_count: 3,
                              max_y: 32767,
                              min_y: -32768);
                      print("02");
                      break;
                  }
                },
                initialKeyValue: 'state'),
          ),
          SizedBox(
            height: 20,
          ),
          HomeLineChartSample1(
            deviceId: widget.device.id,
          ),
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
