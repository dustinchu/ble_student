import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../../util/user.dart';
import 'multiple_chart.dart';

//ignore_for_file: annotate_overrides

class MultipleChartScreen extends StatelessWidget {
  final Map<String, DiscoveredDevice> device;

  const MultipleChartScreen({
    required this.device,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multiple"),
        centerTitle: true,
      ),
      body: Builder(builder: (context) {
        final list = device.values.toList();
        List<Widget> widget = [];

        for (DiscoveredDevice d in list) {
          if (Platform.isAndroid) {
            User.instance.ble!.requestMtu(deviceId: d.id, mtu: 32);
          }
          widget.add(Expanded(
            child: MultipleChart(
              device: d,
            ),
          ));
        }

        return Column(children: widget);
      }),
    );
  }
}
