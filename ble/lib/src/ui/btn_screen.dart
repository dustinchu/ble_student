import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_chart_status.dart';
import 'package:provider/provider.dart';

class BtnScreen extends StatelessWidget {
  const BtnScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    BleChartStatus bleChartStatus = Provider.of<BleChartStatus>(context);

    return Text("按鈕:${bleChartStatus.btn} ");
  }
}
