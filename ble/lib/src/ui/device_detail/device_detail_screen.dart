import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_chart_status.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_detail/device_log_tab.dart';
import 'package:provider/provider.dart';

import 'device_interaction_tab.dart';

class DeviceDetailScreen extends StatelessWidget {
  final DiscoveredDevice device;

  const DeviceDetailScreen({required this.device, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceConnector>(
        builder: (_, deviceConnector, __) => _DeviceDetail(
          device: device,
          disconnect: deviceConnector.disconnect,
        ),
      );
}

class _DeviceDetail extends StatefulWidget {
  _DeviceDetail({
    Key? key,
    required this.device,
    required this.disconnect,
  }) : super(key: key);

  final DiscoveredDevice device;
  final void Function(String deviceId) disconnect;
  @override
  State<_DeviceDetail> createState() => __DeviceDetailState();
}

class __DeviceDetailState extends State<_DeviceDetail> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      Provider.of<BleChartStatus>(context, listen: false).setType(1601);
    });
  }

  Widget build(BuildContext context) => WillPopScope(
        onWillPop: () async {
          // disconnect(device.id);
          return true;
        },
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              title: Text(widget.device.name),
              bottom: !kReleaseMode
                  ? const TabBar(
                      tabs: [
                        Tab(
                          icon: Icon(Icons.padding_outlined),
                        ),
                        Tab(
                          icon: Icon(
                            Icons.find_in_page_sharp,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),
            body: kReleaseMode
                ? DeviceInteractionTab(
                    device: widget.device,
                  )
                : TabBarView(
                    children: [
                      DeviceInteractionTab(
                        device: widget.device,
                      ),
                      const DeviceLogTab(),
                    ],
                  ),
          ),
        ),
      );
}
