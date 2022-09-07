import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/util/hex_to_int.dart';

class HomeBleChartStatus extends ChangeNotifier {
  List<int> value = [];
  var bd = ByteData(4);
  Map<String, int> type = {};
  Map<String, List<List<FlSpot>>> six = {};
  Map<String, List<List<FlSpot>>> dmp = {};
  Map<String, List<List<FlSpot>>> acc = {};
  Map<String, String> showData = {};
  Map<String, int> minx = {};
  Map<String, int> maxx = {};
  var rng = Random();
  Map<String, int> index = {};
  Map<String, int> lineCount = {};
  Map<String, int> miny = {};
  Map<String, int> maxy = {};
  Map<String, dynamic> qValue = {};
  // double qw = 0.0, qx = 0.0, qy = 0.0, qz = 0.0;
  cleanDmpData(String deviceID) {
    Map<String, double> v = {"qw": 0.0, "qx": 0.0, "qy": 0.0, "qz": 0.0};
    qValue[deviceID] = v;
  }

  init(String deviceID) {
    minx[deviceID] = 0;
    maxx[deviceID] = 25;
    index[deviceID] = 0;
    lineCount[deviceID] = 6;
    type[deviceID] = 1601;
    six[deviceID] = [[], [], [], [], [], [], [], [], [], []];
    dmp[deviceID] = [[], [], [], [], [], [], [], [], [], []];
    acc[deviceID] = [[], [], [], [], [], [], [], [], [], []];
    miny[deviceID] = -32768;
    maxy[deviceID] = 32767;
    Map<String, double> v = {"qw": 0.0, "qx": 0.0, "qy": 0.0, "qz": 0.0};
    qValue[deviceID] = v;
    showData[deviceID] = "";
  }

  double electricityDmp(int one, int two, int three, int four) {
    bd.setUint8(3, one);
    bd.setUint8(2, two);
    bd.setUint8(1, three);
    bd.setUint8(0, four);
    return bd.getFloat32(0);
  }

  dmpData(String deviceID, List<int> value) {
    double qw = electricityDmp(value[0], value[1], value[2], value[3]);
    double qx = electricityDmp(value[4], value[5], value[6], value[7]);
    double qy = electricityDmp(value[8], value[9], value[10], value[11]);
    double qz = electricityDmp(value[12], value[13], value[14], value[15]);
    Map<String, double> v = {"qw": qw, "qx": qx, "qy": qy, "qz": qz};
    qValue[deviceID] = v;
    notifyListeners();
  }

  setType(String deviceId, int t) {
    type[deviceId] = t;
    notifyListeners();
  }

  cleanData(String deviceId) {
    index[deviceId] = 0;
    minx[deviceId] = 0;
    maxx[deviceId] = 25;
  }

  setLineCount(
      {required String deviceId,
      required int line_count,
      required int min_y,
      required int max_y}) {
    lineCount[deviceId] = line_count;
    miny[deviceId] = min_y;
    maxy[deviceId] = max_y;
    // data = [[], [], [], [], [], [], [], [], [], []];
  }

  int calculate1601(int value) {
    if (value > 32767) {
      return 32767 - value;
    }
    return value;
  }

  List<FlSpot> list1601Move(int index, double d, String deviceId) {
    List<FlSpot> f = [];
    for (var i = 0; i < 24; i++) {
      // print(
      //     "value  index ==$index=====$i   ${data[index][i + 1].y}    len ==${data[index].length}");
      double x = i.toDouble();
      double y = six[deviceId]![index][i + 1].y;
      f.add(FlSpot(x, y));
    }
    f.add(FlSpot(25, d));
    // print("f====$f");
    return f;
  }

  set1601Data(String deviceId, List<int> a) {
    showData[deviceId] = a.map((i) => i.toString()).join(",");
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
    if (six[deviceId] != null) {
      if (six[deviceId]![0].isNotEmpty) {
        size = six[deviceId]![0].length;
        // print("size==========$size");
        if (size >= maxx[deviceId]!) {
          if (minx[deviceId] == null) minx[deviceId] = 0;
          if (maxx[deviceId] == null) maxx[deviceId] = 25;

          six[deviceId]![0] =
              list1601Move(0, calculate1601(data1).toDouble(), deviceId);
          six[deviceId]![1] =
              list1601Move(1, calculate1601(data2).toDouble(), deviceId);
          six[deviceId]![2] =
              list1601Move(2, calculate1601(data3).toDouble(), deviceId);
          six[deviceId]![3] =
              list1601Move(3, calculate1601(data4).toDouble(), deviceId);
          six[deviceId]![4] =
              list1601Move(4, calculate1601(data5).toDouble(), deviceId);
          six[deviceId]![5] =
              list1601Move(5, calculate1601(data6).toDouble(), deviceId);
        } else {}
        six[deviceId]![0].add(FlSpot(six[deviceId]![0].length.toDouble(),
            calculate1601(data1).toDouble()));
        six[deviceId]![1].add(FlSpot(six[deviceId]![1].length.toDouble(),
            calculate1601(data2).toDouble()));
        six[deviceId]![2].add(FlSpot(six[deviceId]![2].length.toDouble(),
            calculate1601(data3).toDouble()));
        six[deviceId]![3].add(FlSpot(six[deviceId]![3].length.toDouble(),
            calculate1601(data4).toDouble()));
        six[deviceId]![4].add(FlSpot(six[deviceId]![4].length.toDouble(),
            calculate1601(data5).toDouble()));
        six[deviceId]![5].add(FlSpot(six[deviceId]![5].length.toDouble(),
            calculate1601(data6).toDouble()));
      } else {
        List<List<FlSpot>> d = [[], [], [], [], [], [], [], [], [], []];

        d[0] = [FlSpot(0.toDouble(), calculate1601(data1).toDouble())];
        d[1] = [FlSpot(0.toDouble(), calculate1601(data2).toDouble())];
        d[2] = [FlSpot(0.toDouble(), calculate1601(data3).toDouble())];
        d[3] = [FlSpot(0.toDouble(), calculate1601(data4).toDouble())];
        d[4] = [FlSpot(0.toDouble(), calculate1601(data5).toDouble())];
        d[5] = [FlSpot(0.toDouble(), calculate1601(data6).toDouble())];
        six[deviceId] = d;
      }
    }
    // print(" data size ====${data[0].length}  min  ==$minx  max==$maxx");
    index[deviceId] = index[deviceId]! + 1;

    notifyListeners();
  }

  List<FlSpot> list1605Move(int index, double d, bool is1606, String deviceId) {
    List<FlSpot> f = [];
    for (var i = 0; i < 24; i++) {
      // print(
      //     "value  index ==$index=====$i   ${data[index][i + 1].y}    len ==${data[index].length}");
      double x = i.toDouble();
      double y = is1606
          ? acc[deviceId]![index][i + 1].y
          : dmp[deviceId]![index][i + 1].y;
      f.add(FlSpot(x, y));
    }
    f.add(FlSpot(25, d));
    print("f====$f");
    return f;
  }

  set1605DmpData(String deviceId, List<int> a) {
    showData[deviceId] = a.map((i) => i.toString()).join(",");
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    int size = 0;
    if (dmp[deviceId] != null) {
      if (dmp[deviceId]![0].isNotEmpty) {
        size = dmp[deviceId]![0].length;
        print("size==========$size");
        if (size >= maxx[deviceId]!) {
          if (minx[deviceId] == null) minx[deviceId] = 0;
          if (maxx[deviceId] == null) maxx[deviceId] = 25;

          dmp[deviceId]![0] =
              list1605Move(0, calculate1601(data1).toDouble(), false, deviceId);
          dmp[deviceId]![1] =
              list1605Move(1, calculate1601(data2).toDouble(), false, deviceId);
          dmp[deviceId]![2] =
              list1605Move(2, calculate1601(data3).toDouble(), false, deviceId);
        } else {
          dmp[deviceId]![0].add(FlSpot(dmp[deviceId]![0].length.toDouble(),
              calculate1601(data1).toDouble()));

          dmp[deviceId]![1].add(FlSpot(dmp[deviceId]![1].length.toDouble(),
              calculate1601(data1).toDouble()));
          dmp[deviceId]![2].add(FlSpot(dmp[deviceId]![2].length.toDouble(),
              calculate1601(data1).toDouble()));
        }
      } else {
        List<List<FlSpot>> d = [[], [], [], [], [], [], [], [], [], []];
        d[0] = [FlSpot(0.toDouble(), calculate1601(data1).toDouble())];
        d[1] = [FlSpot(0.toDouble(), calculate1601(data2).toDouble())];
        d[2] = [FlSpot(0.toDouble(), calculate1601(data3).toDouble())];
        dmp[deviceId] = d;
      }
    }

    notifyListeners();
  }

  set1606accData(String deviceId, List<int> a) {
    showData[deviceId] = a.map((i) => i.toString()).join(",");
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    int size = 0;
    if (acc[deviceId] != null) {
      if (acc[deviceId]![0].isNotEmpty) {
        size = acc[deviceId]![0].length;
        print("size==========$size");
        if (size >= maxx[deviceId]!) {
          if (minx[deviceId] == null) minx[deviceId] = 0;
          if (maxx[deviceId] == null) maxx[deviceId] = 25;

          acc[deviceId]![0] =
              list1605Move(0, calculate1601(data1).toDouble(), true, deviceId);
          acc[deviceId]![1] =
              list1605Move(1, calculate1601(data2).toDouble(), true, deviceId);
          acc[deviceId]![2] =
              list1605Move(2, calculate1601(data3).toDouble(), true, deviceId);
        } else {
          acc[deviceId]![0].add(FlSpot(acc[deviceId]![0].length.toDouble(),
              calculate1601(data1).toDouble()));

          acc[deviceId]![1].add(FlSpot(acc[deviceId]![1].length.toDouble(),
              calculate1601(data1).toDouble()));
          acc[deviceId]![2].add(FlSpot(acc[deviceId]![2].length.toDouble(),
              calculate1601(data1).toDouble()));
        }
      } else {
        List<List<FlSpot>> d = [[], [], [], [], [], [], [], [], [], []];
        d[0] = [FlSpot(0.toDouble(), calculate1601(data1).toDouble())];
        d[1] = [FlSpot(0.toDouble(), calculate1601(data2).toDouble())];
        d[2] = [FlSpot(0.toDouble(), calculate1601(data3).toDouble())];
        acc[deviceId] = d;
      }
    }

    notifyListeners();
  }
}
