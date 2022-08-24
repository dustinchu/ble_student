import 'package:cupertino_radio_choice/cupertino_radio_choice.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/common/dialog.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/lib/color_picker/colorpicker.dart';
import 'package:flutter_reactive_ble_example/src/lib/color_picker/src/palette.dart';
import 'package:flutter_reactive_ble_example/src/status/ble_controller_status.dart';
import 'package:flutter_reactive_ble_example/util/hex_to_int.dart';
import 'package:provider/provider.dart';

class LED extends StatelessWidget {
  const LED({
    required this.mac,
    // characteristic
    Key? key,
  }) : super(key: key);
  final String mac;
  @override
  Widget build(BuildContext context) => Consumer<BleDeviceInteractor>(
      builder: (context, interactor, _) => LedScreen(
            mac: mac,
            readCharacteristic: interactor.readCharacteristic,
            writeWithResponse: interactor.writeCharacterisiticWithResponse,
            writeWithoutResponse:
                interactor.writeCharacterisiticWithoutResponse,
            subscribeToCharacteristic: interactor.subScribeToCharacteristic,
          ));
}

class LedScreen extends StatefulWidget {
  LedScreen({
    Key? key,
    required this.mac,
    required this.readCharacteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
  }) : super(key: key);
  final String mac;
  final Future<List<int>> Function(QualifiedCharacteristic characteristic)
      readCharacteristic;
  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithResponse;

  final Stream<List<int>> Function(QualifiedCharacteristic characteristic)
      subscribeToCharacteristic;

  final Future<void> Function(
          QualifiedCharacteristic characteristic, List<int> value)
      writeWithoutResponse;

  @override
  State<LedScreen> createState() => _LedScreenState();
}

Color selectColor = Color.fromARGB(0, 255, 0, 0);
bool ledOnOffSwitch = false;
String sendMsg = "";
String blink = "00";
String startText = "00,00";
String endText = "00,00";
String output = "";

class _LedScreenState extends State<LedScreen> {
  TextEditingController startTextEditingController = TextEditingController();
  TextEditingController endTextEditingController = TextEditingController();
  changeColor(Color color) {
    selectColor = color;
    setState(() {});
  }

  write(bool status) async {
    QualifiedCharacteristic qualified =
        Provider.of<BleControllerStatus>(context, listen: false)
            .getQualifiedCharacteristic(widget.mac, "ffc1");
    await widget.writeWithResponse(qualified, status ? [01] : [00]);
  }

  changeLedSwitchStatus(bool status) async {
    write(status);
    ledOnOffSwitch = status;
    setState(() {});
  }

  Widget sectionHeader(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  List<Widget> writeSection(
          String lText, TextEditingController textEditingController) =>
      [
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: textEditingController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: lText,
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
            ),
          ),
        ),
      ];

  sendLedValue() async {
    QualifiedCharacteristic qualified =
        Provider.of<BleControllerStatus>(context, listen: false)
            .getQualifiedCharacteristic(widget.mac, "ffc2");

    List<String> msg = sendMsg.split(",");
    List<int> msgValue = [];

    for (var i = 0; i < msg.length; i++) {
      if (i == 3) {
        msgValue.add(int.parse(msg[i]));
      } else {
        msgValue.add(hexToInt(msg[i]));
      }
    }
    try {
      await widget.writeWithResponse(qualified, msgValue);
      output = "$sendMsg  OK";
    } catch (e) {
      output = "Fail";
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    startTextEditingController.addListener(() {
      textEditListener(startTextEditingController, true);
    });
    endTextEditingController.addListener(() {
      textEditListener(endTextEditingController, false);
    });
  }

  textEditListener(TextEditingController textEditingController, bool isStart) {
    if (textEditingController.text == "") {
      textEditingController.text = "";
      isStart ? startText = "00,00" : endText = "00,00";
    } else {
      if (int.parse(textEditingController.text) > 65535) {
        dialog(context);
        textEditingController.text = "";
        isStart ? startText = "00,00" : endText = "00,00";
      } else {
        String controllerText = int.parse(textEditingController.text)
            .toRadixString(16)
            .padLeft(4, '0');
        controllerText = controllerText.substring(0, 2) +
            "," +
            controllerText.substring(2, 4);
        isStart ? startText = controllerText : endText = controllerText;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    sendMsg = (selectColor.red.toRadixString(16).padLeft(2, '0')) +
        "," +
        (selectColor.green.toRadixString(16).padLeft(2, '0')) +
        "," +
        (selectColor.blue.toRadixString(16).padLeft(2, '0')) +
        "," +
        blink +
        "," +
        startText +
        "," +
        endText;

    return Scaffold(
      appBar: AppBar(
        title: Text("LED Setting"),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(sendMsg),
                )
              ],
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "LED",
                    style: TextStyle(fontSize: 20),
                  ),
                  CupertinoSwitch(
                      value: ledOnOffSwitch, onChanged: changeLedSwitchStatus)
                ],
              ),
            ),
            ledOnOffSwitch
                ? Expanded(
                    child: ListView(
                      children: [
                        ColorPicker(
                          colorPickerWidth: 200,
                          pickerColor: selectColor,
                          onColorChanged: changeColor,
                          paletteType: PaletteType.hueWheel,
                          pickerAreaHeightPercent: 1,
                          enableAlpha: false,
                          showLabel: false,
                          onEndColor: (Color) {},
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("R\n${selectColor.red} "),
                            const SizedBox(
                              width: 40,
                            ),
                            Text("G\n${selectColor.green}"),
                            const SizedBox(
                              width: 40,
                            ),
                            Text("B\n${selectColor.blue}"),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Center(
                          child: CupertinoRadioChoice(
                              choices: const {
                                'blinkOnce': 'Blink once',
                                'blink': 'Blink',
                                'keepLight': 'Keep light'
                              },
                              notSelectedColor: Colors.transparent,
                              onChange: (selectedGender) {
                                switch (selectedGender) {
                                  case "blinkOnce":
                                    blink = "00";
                                    break;
                                  case "blink":
                                    blink = "01";
                                    break;
                                  case "keepLight":
                                    blink = "02";
                                    break;
                                }
                                setState(() {});
                              },
                              initialKeyValue: 'male'),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 5),
                          child: Column(
                            children: writeSection(
                                "High Time", startTextEditingController),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 5),
                          child: Column(
                            children: writeSection(
                                "Low Time", endTextEditingController),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 40),
                                child: ElevatedButton(
                                  onPressed: sendLedValue,
                                  child: const Text('Write',
                                      style: TextStyle(
                                        fontSize: 14,
                                      )),
                                  // With response
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: EdgeInsetsDirectional.only(top: 8.0),
                              child: Text('Output:  $output'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : Container()
          ],
        ),
      ),
      // Use Material color picker:
      //
      // child: MaterialPicker(
      //   pickerColor: pickerColor,
      //   onColorChanged: changeColor,
      //   showLabel: true, // only on portrait mode
      // ),
      //
      // Use Block color picker:
      //
      // child: BlockPicker(
      //   pickerColor: currentColor,
      //   onColorChanged: changeColor,
      // ),
      //
      // child: MultipleChoiceBlockPicker(
      //   pickerColors: currentColors,
      //   onColorsChanged: changeColors,
      // ),
    );
  }
}
