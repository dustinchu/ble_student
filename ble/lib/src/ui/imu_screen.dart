import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_connector.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:provider/provider.dart';

class ImuScreen extends StatefulWidget {
  ImuScreen({Key? key, required this.deviceId}) : super(key: key);
  String deviceId;
  @override
  State<ImuScreen> createState() => _ImuScreenState();
}

Widget _Row(String name, Widget widget) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [Text(name), widget],
  );
}

Widget btn(VoidCallback onTap) {
  return ElevatedButton(
    onPressed: onTap,
    child: const Text('Write',
        style: TextStyle(
          fontSize: 14,
        )),
  );
}

bool imuOnOffSwitch = false;
String outputStr = "";

class _ImuScreenState extends State<ImuScreen> {
  changeImuSwitchStatus(BleDeviceInteractor bleDeviceInteractor, bool status) {
    outputStr = "IMU Low-Power characteristic ${status ? "On" : "Off"}";
    List<int> value = [];
    if (status) {
      value = [01];
    } else {
      value = [00];
    }

    bleDeviceInteractor.writeCharacterisiticWithResponse(
        QualifiedCharacteristic(
            characteristicId: Uuid.parse("FFE0"),
            serviceId: Uuid.parse("FF00"),
            deviceId: widget.deviceId),
        value);
    imuOnOffSwitch = status;
    setState(() {});
  }

  Widget get divider => const Padding(
        padding: EdgeInsets.symmetric(vertical: 4.0),
        child: Divider(thickness: 1.0),
      );

  Widget containerBack(Widget widget) {
    return Container(
        decoration: BoxDecoration(
          color: Color(0xFF243E4D).withOpacity(0.4),
          //设置四周圆角 角度
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: widget,
        padding: EdgeInsets.all(12));
  }

  Widget padding(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Text(name),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Imu Setting"),
        centerTitle: true,
      ),
      body: Consumer2<BleDeviceConnector, BleDeviceInteractor>(
          builder: (_, deviceConnector, serviceDiscoverer, __) {
        write(
            {required String serviceId,
            required String characteristicId,
            required List<int> value}) {
          serviceDiscoverer.writeCharacterisiticWithResponse(
              QualifiedCharacteristic(
                  characteristicId: Uuid.parse(characteristicId),
                  serviceId: Uuid.parse(serviceId),
                  deviceId: widget.deviceId),
              value);
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //part5
                        padding("IMU Sampling Frequency setting"),
                        containerBack(
                          Column(
                            children: [
                              _Row("SRV_FREQ _CONFIG_4HZ", btn(() {
                                outputStr = "SRV_FREQ _CONFIG_4HZ";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFF1",
                                    value: [4, 00]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_FREQ _CONFIG_16HZ", btn(() {
                                outputStr = "RV_FREQ _CONFIG_16HZ";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFF1",
                                    value: [16, 00]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_FREQ _CONFIG_64HZ", btn(() {
                                outputStr = "SRV_FREQ _CONFIG_64HZ";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFF1",
                                    value: [64, 00]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_FREQ _CONFIG_128HZ", btn(() {
                                outputStr = "SRV_FREQ _CONFIG_128HZ";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFF1",
                                    value: [128, 00]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_FREQ _CONFIG_256HZ", btn(() {
                                outputStr = "SRV_FREQ _CONFIG_256HZ";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFF1",
                                    value: [00, 16]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_FREQ _CONFIG_512HZ", btn(() {
                                outputStr = "SRV_FREQ _CONFIG_512HZ";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFF1",
                                    value: [00, 32]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_FREQ _CONFIG_1KHZ:", btn(() {
                                outputStr = "SRV_FREQ _CONFIG_1KHZ:";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFF1",
                                    value: [232, 3]);
                                setState(() {});
                              })),
                            ],
                          ),
                        ),

                        padding("IMU Accelerometer Programmable FSR setting"),
                        containerBack(
                          Column(
                            children: [
                              _Row("SRV_ACC_FSR_SCALE_2G", btn(() {
                                outputStr = "SRV_ACC_FSR_SCALE_2G";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA0",
                                    value: [00]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_ACC_FSR_SCALE_4G", btn(() {
                                outputStr = "SRV_ACC_FSR_SCALE_4G";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA0",
                                    value: [01]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_ACC_FSR_SCALE_8G", btn(() {
                                outputStr = "SRV_ACC_FSR_SCALE_8G";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA0",
                                    value: [02]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_ACC_FSR_SCALE_16G", btn(() {
                                outputStr = "SRV_ACC_FSR_SCALE_16G";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA0",
                                    value: [03]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_ACC_OFF", btn(() {
                                outputStr = "SRV_ACC_OFF";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA0",
                                    value: [99]);
                                setState(() {});
                              })),
                            ],
                          ),
                        ),
                        padding("IMU Gyroscope programmable FSR setting "),
                        containerBack(
                          Column(
                            children: [
                              _Row("SRV_GYRO_SCALE_250", btn(() {
                                outputStr = "SRV_GYRO_SCALE_250";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA2",
                                    value: [00]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_GYRO_SCALE_500", btn(() {
                                outputStr = "SRV_GYRO_SCALE_500";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA2",
                                    value: [01]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_GYRO_SCALE_1000", btn(() {
                                outputStr = "SRV_GYRO_SCALE_1000";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA2",
                                    value: [02]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_GYRO_SCALE_2000", btn(() {
                                outputStr = "SRV_GYRO_SCALE_2000";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA2",
                                    value: [03]);
                                setState(() {});
                              })),
                              divider,
                              _Row("SRV_GYRO_OFF", btn(() {
                                outputStr = "SRV_GYRO_OFF";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFA2",
                                    value: [99]);
                                setState(() {});
                              })),
                            ],
                          ),
                        ),
                        //part6
                        padding("IMU Low-Power "),
                        containerBack(
                          _Row(
                              "LOW_POWER_SETTING_CHAR",
                              CupertinoSwitch(
                                  value: imuOnOffSwitch,
                                  onChanged: (status) {
                                    changeImuSwitchStatus(
                                        serviceDiscoverer, status);
                                  })),
                        ),
                        padding("IMU Low-Noise "),
                        containerBack(
                          Column(
                            children: [
                              _Row("BLE_SRV_LOW_NOISE _RAW", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE _RAW";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [31]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_NORMAL", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_NORMAL";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [07]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_00:", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_00";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [00]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_01:", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_01";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [01]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_02:", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_02";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [02]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_03:", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_03";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [03]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_04:", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_04";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [04]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_05:", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_05";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [05]);
                                setState(() {});
                              })),
                              divider,
                              _Row("BLE_SRV_LOW_NOISE_06:", btn(() {
                                outputStr = "BLE_SRV_LOW_NOISE_06";
                                write(
                                    serviceId: "FF00",
                                    characteristicId: "FFE2",
                                    value: [06]);
                                setState(() {});
                              })),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              padding("Output: $outputStr  OK")
            ],
          ),
        );
      }),
    );
  }
}
