import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_chart_status.dart';
import 'package:provider/provider.dart';

class TempTextScreen extends StatelessWidget {
  const TempTextScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BleChartStatus bleChartStatus = Provider.of<BleChartStatus>(context);
    return Text(
        "溫度:${bleChartStatus.temp == 0 ? "Wait" : bleChartStatus.temp}°C");
  }
}
