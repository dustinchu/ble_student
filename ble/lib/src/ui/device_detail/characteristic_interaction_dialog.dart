import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:flutter_reactive_ble_example/src/ble/ble_device_interactor.dart';
import 'package:flutter_reactive_ble_example/src/status/dialog_status.dart';
import 'package:flutter_reactive_ble_example/util/user.dart';
import 'package:provider/provider.dart';

class CharacteristicInteractionDialog extends StatelessWidget {
  const CharacteristicInteractionDialog({
    required this.characteristic,
    required this.characteristicStr,
    // characteristic
    Key? key,
  }) : super(key: key);
  final QualifiedCharacteristic characteristic;
  final String characteristicStr;

  @override
  Widget build(BuildContext context) => Consumer<BleDeviceInteractor>(
      builder: (context, interactor, _) => _CharacteristicInteractionDialog(
            characteristicStr: characteristicStr,
            characteristic: characteristic,
            readCharacteristic: interactor.readCharacteristic,
            writeWithResponse: interactor.writeCharacterisiticWithResponse,
            writeWithoutResponse:
                interactor.writeCharacterisiticWithoutResponse,
            subscribeToCharacteristic: interactor.subScribeToCharacteristic,
          ));
}

class _CharacteristicInteractionDialog extends StatefulWidget {
  const _CharacteristicInteractionDialog({
    required this.characteristic,
    required this.readCharacteristic,
    required this.writeWithResponse,
    required this.writeWithoutResponse,
    required this.subscribeToCharacteristic,
    required this.characteristicStr,
    Key? key,
  }) : super(key: key);
  final String characteristicStr;
  final QualifiedCharacteristic characteristic;
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
  _CharacteristicInteractionDialogState createState() =>
      _CharacteristicInteractionDialogState();
}

class _CharacteristicInteractionDialogState
    extends State<_CharacteristicInteractionDialog> {
  late String readOutput;
  late String writeOutput;
  late String subscribeOutput;
  late TextEditingController textEditingController;
  StreamSubscription<List<int>>? subscribeStream;

  @override
  void initState() {
    readOutput = '';
    writeOutput = '';
    subscribeOutput = '';
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    print(" subscribeStream?.cancel();");
    subscribeStream?.cancel();
    super.dispose();
  }

// Unhandled Exception: Null check operator used on a null value
  Future<void> subscribeCharacteristic() async {
    print("widget.characteristic===${widget.characteristic}");
    subscribeStream =
        widget.subscribeToCharacteristic(widget.characteristic).listen((event) {
      // if (!mounted) {
      // print(
      //     "subscribeStream    ---------------------------------------$mounted");
      if (subscribeStream != null) {
        if (mounted) {
          Provider.of<DialogStatus>(User.instance.context!, listen: false)
              .setSubscribeOutput(event.toString());
        }
      }

      // }

      // setState(() {
      //   subscribeOutput = event.toString();
      // });
    });
    // if (!mounted) {
    Provider.of<DialogStatus>(User.instance.context!, listen: false)
        .setSubscribeOutput("Notification set");
    // }

    // setState(() {
    //   subscribeOutput = 'Notification set';
    // });
  }

  Future<void> readCharacteristic() async {
    final result = await widget.readCharacteristic(widget.characteristic);
    setState(() {
      readOutput = result.toString();
    });
  }

  List<int> _parseInput() => textEditingController.text
      .split(',')
      .map(
        int.parse,
      )
      .toList();

  Future<void> writeCharacteristicWithResponse() async {
    print("cr ====${widget.characteristic}");
    await widget.writeWithResponse(widget.characteristic, _parseInput());
    // await widget.writeWithResponse(
    //     widget.characteristic, [255, 255, 255, 02, 00, 05, 00, 05]);
    setState(() {
      writeOutput = 'Ok';
    });
  }

  Future<void> writeCharacteristicWithoutResponse() async {
    await widget.writeWithoutResponse(widget.characteristic, _parseInput());
    setState(() {
      writeOutput = 'Done';
    });
  }

  Widget sectionHeader(String text) => Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      );

  List<Widget> get writeSection => [
        sectionHeader('Write characteristic'),
        SizedBox(
          height: 50,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              controller: textEditingController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Value',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: writeCharacteristicWithResponse,
              child: const Text('With\nresponse',
                  style: TextStyle(
                    fontSize: 14,
                  )),
              // With response
            ),
            // ElevatedButton(
            //   onPressed: writeCharacteristicWithoutResponse,
            //   child: const Text('Without\nresponse',
            //       style: TextStyle(
            //         fontSize: 14,
            //       )),
            //   // Without response
            // ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(top: 8.0),
          child: Text('Output: $writeOutput'),
        ),
      ];

  List<Widget> get readSection => [
        sectionHeader('Read characteristic'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: readCharacteristic,
              child: const Text('Read'),
            ),
            Text('Output: $readOutput'),
          ],
        ),
      ];

  List<Widget> subscribeSection(String subscribeOutputText) {
    return [
      sectionHeader('Subscribe / notify'),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ElevatedButton(
            onPressed: subscribeCharacteristic,
            child: const Text('Subscribe'),
          ),
          Text('Output: $subscribeOutputText')
        ],
      ),
    ];
  }

  Widget get divider => const Padding(
        padding: EdgeInsets.symmetric(vertical: 12.0),
        child: Divider(thickness: 2.0),
      );

  @override
  Widget build(BuildContext context) {
    var dialogStatus = Provider.of<DialogStatus>(context);
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          shrinkWrap: true,
          children: [
            const Text(
              'Select an operation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                widget.characteristic.characteristicId.toString(),
              ),
            ),
            widget.characteristicStr.contains("read")
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        divider,
                        ...readSection,
                      ])
                : Container(),
            widget.characteristicStr.contains("write")
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        divider,
                        ...writeSection,
                      ])
                : Container(),
            widget.characteristicStr.contains("notify")
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        divider,
                        ...subscribeSection(dialogStatus.getSubscribeOutput),
                      ])
                : Container(),
            divider,
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('close')),
              ),
            )
          ],
        ),
      ),
    );
  }
}
