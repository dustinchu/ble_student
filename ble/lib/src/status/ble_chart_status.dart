import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/util/hex_to_int.dart';

class BleChartStatus extends ChangeNotifier {
  List<int> value = [];
  var bd = ByteData(4);
  int type = 1601;
  List<List<FlSpot>> six = [[], [], [], [], [], [], [], [], [], []];
  List<List<FlSpot>> dmp = [[], [], [], [], [], [], [], [], [], []];
  List<List<FlSpot>> acc = [[], [], [], [], [], [], [], [], [], []];
  String showData = "";
  int minx = 0;
  int maxx = 25;
  var rng = Random();
  int index = 0;
  int lineCount = 6;
  int miny = -32768;
  int maxy = 32767;
  int electricity = 0;
  double temp = .0;
  double qw = 0.0, qx = 0.0, qy = 0.0, qz = 0.0;
  int btn = 0;
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

  Future<void> cleanData() async {
    index = 0;
    minx = 0;
    maxx = 25;
    // data.clear();
  }

  Future<void> setLineCount(
      {required int line_count, required int min_y, required int max_y}) async {
    lineCount = line_count;
    miny = min_y;
    maxy = max_y;
  }

  int calculate1601(int value) {
    if (value > 32767) {
      return 32767 - value;
    }
    return value;
  }

  setTemp(List<int> a) {
    temp = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
            a[0].toRadixString(16).padLeft(2, '0')) /
        100;
    notifyListeners();
  }

  setElectricity(int value) {
    electricity = value;
    notifyListeners();
  }

  setBtn(int value) {
    btn = value;
    notifyListeners();
  }

  List<FlSpot> list1601Move(int index, double d) {
    List<FlSpot> f = [];
    for (var i = 0; i < 24; i++) {
      // print(
      //     "value  index ==$index=====$i   ${data[index][i + 1].y}    len ==${data[index].length}");
      double x = i.toDouble();
      double y = six[index][i + 1].y;
      f.add(FlSpot(x, y));
    }
    f.add(FlSpot(25, d));
    // print("f====$f");
    return f;
  }

  set1601Data(List<int> a) {
    showData = a.map((i) => i.toString()).join(",");
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

    int size = 0;
    if (six[0].isNotEmpty) {
      size = six[0].length;

      // print(
      //     "size==========$size   min ===$minx    maxx ==$maxx  data  ==${data[0]}");
      if (size >= maxx && six[0].isNotEmpty) {
        print("size====$size");
        six[0] = list1601Move(0, calculate1601(data1).toDouble());
        six[1] = list1601Move(1, calculate1601(data2).toDouble());
        six[2] = list1601Move(2, calculate1601(data3).toDouble());
        six[3] = list1601Move(3, calculate1601(data4).toDouble());
        six[4] = list1601Move(4, calculate1601(data5).toDouble());
        six[5] = list1601Move(5, calculate1601(data6).toDouble());
      } else {
        print(
            "index ===$index   data 3==${six[4]}   ${six[4].isEmpty}   ||  $data4   len  ${six[4].length}   index ==$index   data==${calculate1601(data1).toDouble()}");
        six[0].add(
            FlSpot(six[0].length.toDouble(), calculate1601(data1).toDouble()));
        six[1].add(
            FlSpot(six[1].length.toDouble(), calculate1601(data2).toDouble()));
        six[2].add(
            FlSpot(six[2].length.toDouble(), calculate1601(data3).toDouble()));
        six[3].add(
            FlSpot(six[3].length.toDouble(), calculate1601(data4).toDouble()));
        six[4].add(
            FlSpot(six[4].length.toDouble(), calculate1601(data5).toDouble()));
        six[5].add(
            FlSpot(six[5].length.toDouble(), calculate1601(data6).toDouble()));
      }
    } else {
      six[0] = [
        FlSpot(six[0].length.toDouble(), calculate1601(data1).toDouble())
      ];
      six[1] = [
        FlSpot(six[1].length.toDouble(), calculate1601(data2).toDouble())
      ];
      six[2] = [
        FlSpot(six[2].length.toDouble(), calculate1601(data3).toDouble())
      ];
      six[3] = [
        FlSpot(six[3].length.toDouble(), calculate1601(data4).toDouble())
      ];
      six[4] = [
        FlSpot(six[4].length.toDouble(), calculate1601(data5).toDouble())
      ];
      six[5] = [
        FlSpot(six[5].length.toDouble(), calculate1601(data6).toDouble())
      ];
    }
    index += 1;

    notifyListeners();
  }

  List<FlSpot> list1605Move(int index, double d, bool is1606) {
    List<FlSpot> f = [];
    for (var i = 0; i < 24; i++) {
      // print(
      //     "value  index ==$index=====$i   ${data[index][i + 1].y}    len ==${data[index].length}");
      double x = i.toDouble();
      double y = is1606 ? acc[index][i + 1].y : dmp[index][i + 1].y;
      f.add(FlSpot(x, y));
    }
    f.add(FlSpot(25, d));
    // print("f====$f");
    return f;
  }

  set1605DmpData(List<int> a) {
    showData = a.map((i) => i.toString()).join(",");
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    int size = 0;
    if (dmp[0].isNotEmpty) {
      size = dmp[0].length;
      // print("size==========$size");
      if (size >= maxx && dmp[0].isNotEmpty) {
        dmp[0] = list1605Move(0, calculate1601(data1).toDouble(), false);
        dmp[1] = list1605Move(1, calculate1601(data2).toDouble(), false);
        dmp[2] = list1605Move(2, calculate1601(data3).toDouble(), false);
      } else {
        dmp[0].add(
            FlSpot(dmp[0].length.toDouble(), calculate1601(data1).toDouble()));

        dmp[1].add(
            FlSpot(dmp[1].length.toDouble(), calculate1601(data1).toDouble()));
        dmp[2].add(
            FlSpot(dmp[2].length.toDouble(), calculate1601(data1).toDouble()));
      }
    } else {
      dmp[0].add(
          FlSpot(dmp[0].length.toDouble(), calculate1601(data1).toDouble()));

      dmp[1].add(
          FlSpot(dmp[1].length.toDouble(), calculate1601(data1).toDouble()));
      dmp[2].add(
          FlSpot(dmp[2].length.toDouble(), calculate1601(data1).toDouble()));
    }
    notifyListeners();
  }

  set1606AccData(List<int> a) {
    showData = a.map((i) => i.toString()).join(",");
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    int size = 0;
    if (acc[0].isNotEmpty) {
      size = acc[0].length;
      print("size==========$size");
      if (size >= maxx && acc[0].isNotEmpty) {
        acc[0] = list1605Move(0, calculate1601(data1).toDouble(), true);
        acc[1] = list1605Move(1, calculate1601(data2).toDouble(), true);
        acc[2] = list1605Move(2, calculate1601(data3).toDouble(), true);
      } else {
        acc[0].add(
            FlSpot(acc[0].length.toDouble(), calculate1601(data1).toDouble()));

        acc[1].add(
            FlSpot(acc[1].length.toDouble(), calculate1601(data1).toDouble()));
        acc[2].add(
            FlSpot(acc[2].length.toDouble(), calculate1601(data1).toDouble()));
      }
    } else {
      acc[0].add(
          FlSpot(acc[0].length.toDouble(), calculate1601(data1).toDouble()));

      acc[1].add(
          FlSpot(acc[1].length.toDouble(), calculate1601(data1).toDouble()));
      acc[2].add(
          FlSpot(acc[2].length.toDouble(), calculate1601(data1).toDouble()));
    }
    notifyListeners();
  }
}
