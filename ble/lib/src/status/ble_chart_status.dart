import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/util/hex_to_int.dart';

class BleChartStatus extends ChangeNotifier {
  List<int> value = [];
  var bd = ByteData(4);
  int type = 1601;
  List<List<FlSpot>> data = [[], [], [], [], [], [], [], [], [], []];

  int minx = 0;
  int maxx = 25;
  var rng = Random();
  int index = 0;
  int lineCount = 6;
  int miny = -32768;
  int maxy = 32767;
  int electricity = 0;
  double qw = 0.0, qx = 0.0, qy = 0.0, qz = 0.0;
  cleanDmpData() {
    qw = 0.0;
    qx = 0.0;
    qy = 0.0;
    qz = 0.0;
  }

  double electricityDmp(int one, int two, int three, int four) {
    bd.setUint8(3, one);
    bd.setUint8(2, two);
    bd.setUint8(1, three);
    bd.setUint8(0, four);
    return bd.getFloat32(0);
  }

  dmpData(List<int> value) {
    qw = electricityDmp(value[0], value[1], value[2], value[3]);
    qx = electricityDmp(value[4], value[5], value[6], value[7]);
    qy = electricityDmp(value[8], value[9], value[10], value[11]);
    qz = electricityDmp(value[12], value[13], value[14], value[15]);
    notifyListeners();
  }

  setType(int t) {
    type = t;
    notifyListeners();
  }

  cleanData() {
    index = 0;
    minx = 0;
    maxx = 25;
    data.clear();
    data = [[], [], [], [], [], [], [], [], [], []];
  }

  setLineCount(
      {required int line_count, required int min_y, required int max_y}) {
    lineCount = line_count;
    miny = min_y;
    maxy = max_y;
    // data = [[], [], [], [], [], [], [], [], [], []];
  }

  int calculate1601(int value) {
    if (value > 32767) {
      return 32767 - value;
    }
    return value;
  }

  setElectricity(int value) {
    electricity = value;
    notifyListeners();
  }

  set1601Data(List<int> a) {
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    int data4 = hexToInt(a[7].toRadixString(16).padLeft(2, '0') +
        a[6].toRadixString(16).padLeft(2, '0'));
    int data5 = hexToInt(a[9].toRadixString(16).padLeft(2, '0') +
        a[8].toRadixString(16).padLeft(2, '0'));
    int data6 = hexToInt(a[11].toRadixString(16).padLeft(2, '0') +
        a[10].toRadixString(16).padLeft(2, '0'));
    // print(a);
    // print(
    //     "data1 ==${calculate1601(data1)}    1=${a[1]} ${a[1].toRadixString(16).padLeft(2, '0')}  0 =${a[0]} ${a[0].toRadixString(16).padLeft(2, '0')}   ");
    // print(
    //     "data2 ==${calculate1601(data2)}    1=${a[3]} ${a[3].toRadixString(16).padLeft(2, '0')}  0 =${a[2]} ${a[2].toRadixString(16).padLeft(2, '0')}   ");

    // print(
    //     "data3 ==${calculate1601(data3)}    1=${a[5]} ${a[5].toRadixString(16).padLeft(2, '0')}  0 =${a[4]} ${a[4].toRadixString(16).padLeft(2, '0')}   ");

    // print(
    //     "data4 ==${calculate1601(data4)}    1=${a[7]} ${a[7].toRadixString(16).padLeft(2, '0')}  0 =${a[6]} ${a[6].toRadixString(16).padLeft(2, '0')}   ");

    // print(
    //     "data5 ==${calculate1601(data5)}    1=${a[9]} ${a[9].toRadixString(16).padLeft(2, '0')}  0 =${a[8]} ${a[8].toRadixString(16).padLeft(2, '0')}   ");
    // print(
    //     "data5 ==${calculate1601(data6)}    1=${a[11]} ${a[11].toRadixString(16).padLeft(2, '0')}  0 =${a[10]} ${a[10].toRadixString(16).padLeft(2, '0')}   ");

    // int data7 = a[12] + a[13];
    // int data8 = a[14] + a[15];
    int size = 0;
    if (data[0].isNotEmpty) {
      size = data[0].length;
      // print("size==========$size");
      if (size >= maxx) {
        minx += 1;
        maxx += 1;
        // print(" data 刪除前size ====${data[0].length}");
        data[0].removeAt(0);
        data[1].removeAt(0);
        data[2].removeAt(0);
        data[3].removeAt(0);
        data[4].removeAt(0);
        data[5].removeAt(0);
        // print(" data 刪除後size ====${data[0].length}");
      }
      data[0]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data1).toDouble()));
      data[1]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data2).toDouble()));
      data[2]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data3).toDouble()));
      data[3]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data4).toDouble()));
      data[4]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data5).toDouble()));
      data[5]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data6).toDouble()));
    } else {
      data[0] = [FlSpot(0.toDouble(), calculate1601(data1).toDouble())];
      data[1] = [FlSpot(0.toDouble(), calculate1601(data2).toDouble())];
      data[2] = [FlSpot(0.toDouble(), calculate1601(data3).toDouble())];
      data[3] = [FlSpot(0.toDouble(), calculate1601(data4).toDouble())];
      data[4] = [FlSpot(0.toDouble(), calculate1601(data5).toDouble())];
      data[5] = [FlSpot(0.toDouble(), calculate1601(data6).toDouble())];
    }
    // print(" data size ====${data[0].length}  min  ==$minx  max==$maxx");
    index += 1;

    notifyListeners();
  }

  set1602Data(List<int> a) {
    int data1 = hexToInt(a[0].toRadixString(16).padLeft(2, '0') +
        a[1].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0') +
        a[3].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[4].toRadixString(16).padLeft(2, '0') +
        a[5].toRadixString(16).padLeft(2, '0') +
        a[6].toRadixString(16).padLeft(2, '0') +
        a[7].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[8].toRadixString(16).padLeft(2, '0') +
        a[9].toRadixString(16).padLeft(2, '0') +
        a[10].toRadixString(16).padLeft(2, '0') +
        a[11].toRadixString(16).padLeft(2, '0'));
    int data4 = hexToInt(a[6].toRadixString(12).padLeft(2, '0') +
        a[13].toRadixString(16).padLeft(2, '0') +
        a[14].toRadixString(16).padLeft(2, '0') +
        a[15].toRadixString(16).padLeft(2, '0'));
    int data5 = hexToInt(a[16].toRadixString(16).padLeft(2, '0') +
        a[17].toRadixString(16).padLeft(2, '0'));
    int data6 = hexToInt(a[10].toRadixString(16).padLeft(2, '0') +
        a[11].toRadixString(16).padLeft(2, '0'));
    int data7 = hexToInt(a[10].toRadixString(16).padLeft(2, '0') +
        a[11].toRadixString(16).padLeft(2, '0'));
    int data8 = hexToInt(a[10].toRadixString(16).padLeft(2, '0') +
        a[11].toRadixString(16).padLeft(2, '0'));
    int data9 = hexToInt(a[10].toRadixString(16).padLeft(2, '0') +
        a[11].toRadixString(16).padLeft(2, '0'));
    int data10 = hexToInt(a[10].toRadixString(16).padLeft(2, '0') +
        a[11].toRadixString(16).padLeft(2, '0'));
    print(a);
    print(
        "data1 ==$data1    0 =${a[0]}  ${a[0].toRadixString(16).padLeft(2, '0')}  1=${a[1]} ${a[1].toRadixString(16).padLeft(2, '0')} ");
    print(
        "data2 ==$data2    0 =${a[2]}  ${a[2].toRadixString(16).padLeft(2, '0')}  1=${a[3]} ${a[3].toRadixString(16).padLeft(2, '0')} ");
    print(
        "data3 ==$data3    0 =${a[4]}  ${a[4].toRadixString(16).padLeft(2, '0')}  1=${a[5]} ${a[5].toRadixString(16).padLeft(2, '0')} ");
    print(
        "data4 ==$data4    0 =${a[6]}  ${a[6].toRadixString(16).padLeft(2, '0')}  1=${a[7]} ${a[7].toRadixString(16).padLeft(2, '0')} ");
    print(
        "data5 ==$data5    0 =${a[7]}  ${a[8].toRadixString(16).padLeft(2, '0')}  1=${a[9]} ${a[9].toRadixString(16).padLeft(2, '0')} ");

    // int data7 = a[12] + a[13];
    // int data8 = a[14] + a[15];
    int size = 0;
    if (data[0].isNotEmpty) {
      size = data[0].length;
      print("size==========$size");
      if (size >= maxx) {
        minx += 1;
        maxx += 1;
        // print(" data 刪除前size ====${data[0].length}");
        data[0].removeAt(0);
        data[1].removeAt(0);
        data[2].removeAt(0);
        data[3].removeAt(0);
        data[4].removeAt(0);
        data[5].removeAt(0);
        // print(" data 刪除後size ====${data[0].length}");
      }
      data[0].add(FlSpot(index + 1.toDouble(), data1.toDouble()));
      data[1].add(FlSpot(index + 1.toDouble(), data2.toDouble()));
      data[2].add(FlSpot(index + 1.toDouble(), data3.toDouble()));
      data[3].add(FlSpot(index + 1.toDouble(), data4.toDouble()));
      data[4].add(FlSpot(index + 1.toDouble(), data5.toDouble()));
      data[5].add(FlSpot(index + 1.toDouble(), data6.toDouble()));
    } else {
      data[0] = [FlSpot(0.toDouble(), data1.toDouble())];
      data[1] = [FlSpot(0.toDouble(), data2.toDouble())];
      data[2] = [FlSpot(0.toDouble(), data3.toDouble())];
      data[3] = [FlSpot(0.toDouble(), data4.toDouble())];
      data[4] = [FlSpot(0.toDouble(), data5.toDouble())];
      data[5] = [FlSpot(0.toDouble(), data6.toDouble())];
    }
    print(" data size ====${data[0].length}  min  ==$minx  max==$maxx");
    index += 1;

    notifyListeners();
  }

  set1605Data(List<int> a) {
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    print(a);
    print(
        "data1 ==${calculate1601(data1)}    1=${a[1]} ${a[1].toRadixString(16).padLeft(2, '0')}  0 =${a[0]} ${a[0].toRadixString(16).padLeft(2, '0')}   ");
    print(
        "data2 ==${calculate1601(data2)}    1=${a[3]} ${a[3].toRadixString(16).padLeft(2, '0')}  0 =${a[2]} ${a[2].toRadixString(16).padLeft(2, '0')}   ");

    print(
        "data3 ==${calculate1601(data3)}    1=${a[5]} ${a[5].toRadixString(16).padLeft(2, '0')}  0 =${a[4]} ${a[4].toRadixString(16).padLeft(2, '0')}   ");

    // int data7 = a[12] + a[13];
    // int data8 = a[14] + a[15];
    int size = 0;
    if (data[0].isNotEmpty) {
      size = data[0].length;
      print("size==========$size");
      if (size >= maxx) {
        minx += 1;
        maxx += 1;
        // print(" data 刪除前size ====${data[0].length}");
        data[0].removeAt(0);
        data[1].removeAt(0);
        data[2].removeAt(0);
        // print(" data 刪除後size ====${data[0].length}");
      }
      data[0]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data1).toDouble()));
      data[1]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data2).toDouble()));
      data[2]
          .add(FlSpot(index + 1.toDouble(), calculate1601(data3).toDouble()));
    } else {
      data[0] = [FlSpot(0.toDouble(), calculate1601(data1).toDouble())];
      data[1] = [FlSpot(0.toDouble(), calculate1601(data2).toDouble())];
      data[2] = [FlSpot(0.toDouble(), calculate1601(data3).toDouble())];
    }
    print(" data size ====${data[0].length}  min  ==$minx  max==$maxx");
    index += 1;

    notifyListeners();
  }
}
