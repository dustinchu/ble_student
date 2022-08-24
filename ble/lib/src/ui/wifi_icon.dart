import 'dart:math';

import 'package:flutter/material.dart';
import 'package:signal_strength_indicator/signal_strength_indicator.dart';

class WifiIcon extends StatelessWidget {
  const WifiIcon({Key? key, required this.rssi}) : super(key: key);
  final int rssi;

  double mathValue() {
    int r = rssi * -1;
    if (r < 80) {
      return 1.0;
    } else if (r > 80) {
      return 0.6;
    }
    return 0.3;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Transform.rotate(
        angle: -45 * pi / 180,
        origin: const Offset(-15, 0),
        child: SignalStrengthIndicator.sector(
          value: mathValue(),
          size: 20,
          barCount: 3,
          spacing: 0.6,
          activeColor: const Color(0xff3477F6),
          inactiveColor: Colors.grey,
        ),
      ),
    );
  }
}
