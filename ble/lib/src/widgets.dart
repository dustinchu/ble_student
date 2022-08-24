import 'package:flutter/material.dart';

class BluetoothIcon extends StatelessWidget {
  BluetoothIcon({Key? key, required this.connectStatus}) : super(key: key);
  bool connectStatus;
  @override
  Widget build(BuildContext context) =>
      Icon(connectStatus ? Icons.bluetooth : Icons.bluetooth_disabled,
          size: 40, color: connectStatus ? Colors.blue : Colors.black);
}

class StatusMessage extends StatelessWidget {
  const StatusMessage({
    required this.text,
    Key? key,
  }) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      );
}
