import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/util/characteristic_Id.dart';
import 'package:flutter_reactive_ble_example/util/user.dart';

import 'characteristic_interaction_dialog.dart';

class ServiceDiscoveryList extends StatelessWidget {
  ServiceDiscoveryList(
      {Key? key,
      required this.deviceConnected,
      required this.discoveredServices,
      required this.deviceId})
      : super(key: key);
  bool deviceConnected;
  List<DiscoveredService> discoveredServices;
  String deviceId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ServiceDiscovery"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // IconButton(
          //     onPressed: () {
          //       Navigator.of(context).pop();
          //     },
          //     icon: Icon(Icons.backup_sharp)),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate.fixed(
                    [
                      if (deviceConnected)
                        _ServiceDiscoveryList(
                          deviceId: deviceId,
                          discoveredServices: discoveredServices,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
