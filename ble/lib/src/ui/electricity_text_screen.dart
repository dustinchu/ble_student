import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_chart_status.dart';
import 'package:provider/provider.dart';

class ElectricityTextScreen extends StatelessWidget {
  const ElectricityTextScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BleChartStatus bleChartStatus = Provider.of<BleChartStatus>(context);

    return Text("電池電量:${bleChartStatus.electricity}%");
  }
}
