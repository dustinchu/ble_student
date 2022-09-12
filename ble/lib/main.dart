import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_scanner.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_status_monitor.dart';
import 'package:flutter_reactive_ble_example/src/ui/device_list.dart';
import 'package:provider/provider.dart';

import 'src/ble/ble_logger.dart';
import 'src/status/ble_chart_status.dart';
import 'src/status/ble_controller_status.dart';
import 'src/status/connect.dart';
import 'src/status/dialog_status.dart';
import 'src/status/home_ble_chart_status.dart';
import 'src/status/multiple_chart_status.dart';
import 'src/ui/ble_status_screen.dart';

const _themeColor = Colors.lightGreen;
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final _bleLogger = BleLogger();
  final _ble = FlutterReactiveBle();
  final _scanner = BleScanner(ble: _ble, logMessage: _bleLogger.addToLog);
  final _monitor = BleStatusMonitor(_ble);
  final _connector = BleDeviceConnector(
    ble: _ble,
    logMessage: _bleLogger.addToLog,
  );

  final _serviceDiscoverer = BleDeviceInteractor(
    bleDiscoverServices: _ble.discoverServices,
    readCharacteristic: _ble.readCharacteristic,
    writeWithResponse: _ble.writeCharacteristicWithResponse,
    writeWithOutResponse: _ble.writeCharacteristicWithoutResponse,
    subscribeToCharacteristic: _ble.subscribeToCharacteristic,
    logMessage: _bleLogger.addToLog,
    readRssi: _ble.readRssi,
  );
  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: _scanner),
        Provider.value(value: _monitor),
        Provider.value(value: _connector),
        Provider.value(value: _serviceDiscoverer),
        Provider.value(value: _bleLogger),
        ChangeNotifierProvider.value(value: DialogStatus()),
        ChangeNotifierProvider.value(value: BleControllerStatus()),
        ChangeNotifierProvider.value(value: BleChartStatus()),
        ChangeNotifierProvider.value(value: Connect()),
        ChangeNotifierProvider.value(value: MultipleChartStatus()),
        ChangeNotifierProvider.value(value: HomeBleChartStatus()),
        StreamProvider<BleScannerState?>(
          create: (_) => _scanner.state,
          initialData: const BleScannerState(
            discoveredDevices: [],
            scanIsInProgress: false,
          ),
        ),
        StreamProvider<BleStatus?>(
          create: (_) => _monitor.state,
          initialData: BleStatus.unknown,
        ),
        StreamProvider<ConnectionStateUpdate>(
          create: (_) => _connector.state,
          initialData: const ConnectionStateUpdate(
            deviceId: 'Unknown device',
            connectionState: DeviceConnectionState.disconnected,
            failure: null,
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.dark,
        darkTheme: FlexThemeData.dark(
          scheme: FlexScheme.bahamaBlue,
          surfaceMode: FlexSurfaceMode.highScaffoldLowSurface,
          blendLevel: 18,
          appBarStyle: FlexAppBarStyle.background,
          appBarOpacity: 0.95,
          appBarElevation: 0,
          transparentStatusBar: true,
          tabBarStyle: FlexTabBarStyle.forAppBar,
          tooltipsMatchBackground: true,
          swapColors: false,
          darkIsTrueBlack: false,
          useSubThemes: true,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          subThemesData: const FlexSubThemesData(
            useTextTheme: true,
            fabUseShape: true,
            interactionEffects: true,
            bottomNavigationBarElevation: 0,
            bottomNavigationBarOpacity: 0.95,
            inputDecoratorIsFilled: true,
            inputDecoratorBorderType: FlexInputBorderType.outline,
            inputDecoratorUnfocusedHasBorder: true,
            blendOnColors: true,
            blendTextTheme: true,
            popupMenuOpacity: 0.95,
          ),
        ),
        color: _themeColor,
        theme: ThemeData(primarySwatch: _themeColor),
        home: const HomeScreen(),
      ),
    ),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) => Consumer<BleStatus?>(
        builder: (_, status, __) {
          // return ImuScreen();
          if (status == BleStatus.ready) {
            return const DeviceListScreen();
          } else {
            return BleStatusScreen(status: status ?? BleStatus.unknown);
          }
        },
      );
}

// class CheckBoxTest extends StatelessWidget {
//   const CheckBoxTest({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: CupertinoRadioChoice(
//             choices: const {
//               '1601': '1601',
//               '1602': '1602',
//               '1603': '1603',
//               '1604': '1604',
//               '1605': '1605'
//             },
//             notSelectedColor: Colors.transparent,
//             onChange: (selectedGender) {
//               switch (selectedGender) {
//                 case "1601":
//                   break;
//                 case "1602":
//                   break;
//                 case "1603":
//                   break;
//                 case "1604":
//                   break;
//                 case "1605":
//                   break;
//               }
//             },
//             initialKeyValue: 'state'),
//       ),
//     );
//   }
// }
