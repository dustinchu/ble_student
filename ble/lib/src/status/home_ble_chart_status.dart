import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/util/hex_to_int.dart';

class HomeBleChartStatus extends ChangeNotifier {
  List<int> value = [];
  var bd = ByteData(4);
  Map<String, int> type = {};
  Map<String, List<List<FlSpot>>> data = {};
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
    data[deviceID] = [[], [], [], [], [], [], [], [], [], []];
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
    data[deviceId] = [[], [], [], [], [], [], [], [], [], []];
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
    if (data[deviceId] != null) {
      if (data[deviceId]![0].isNotEmpty) {
        size = data[deviceId]![0].length;
        // print("size==========$size");
        if (size >= maxx[deviceId]!) {
          if (minx[deviceId] == null)
            minx[deviceId] = 0;
          else
            minx[deviceId] = minx[deviceId]! + 1;
          if (maxx[deviceId] == null)
            maxx[deviceId] = 25;
          else
            maxx[deviceId] = maxx[deviceId]! + 1;

          // print(" data 刪除前size ====${data[0].length}");
          data[deviceId]![0].removeAt(0);
          data[deviceId]![1].removeAt(0);
          data[deviceId]![2].removeAt(0);
          data[deviceId]![3].removeAt(0);
          data[deviceId]![4].removeAt(0);
          data[deviceId]![5].removeAt(0);
          // print(" data 刪除後size ====${data[0].length}");
        }
        data[deviceId]![0].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data1).toDouble()));
        data[deviceId]![1].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data2).toDouble()));
        data[deviceId]![2].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data3).toDouble()));
        data[deviceId]![3].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data4).toDouble()));
        data[deviceId]![4].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data5).toDouble()));
        data[deviceId]![5].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data6).toDouble()));
      } else {
        List<List<FlSpot>> d = [[], [], [], [], [], [], [], [], [], []];

        d[0] = [FlSpot(0.toDouble(), calculate1601(data1).toDouble())];
        d[1] = [FlSpot(0.toDouble(), calculate1601(data2).toDouble())];
        d[2] = [FlSpot(0.toDouble(), calculate1601(data3).toDouble())];
        d[3] = [FlSpot(0.toDouble(), calculate1601(data4).toDouble())];
        d[4] = [FlSpot(0.toDouble(), calculate1601(data5).toDouble())];
        d[5] = [FlSpot(0.toDouble(), calculate1601(data6).toDouble())];
        data[deviceId] = d;
      }
    }
    // print(" data size ====${data[0].length}  min  ==$minx  max==$maxx");
    index[deviceId] = index[deviceId]! + 1;

    notifyListeners();
  }

  set1602Data(String deviceId, List<int> a) {
    showData[deviceId] = a.map((i) => i.toString()).join(",");
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
    // print(a);
    // print(
    //     "data1 ==$data1    0 =${a[0]}  ${a[0].toRadixString(16).padLeft(2, '0')}  1=${a[1]} ${a[1].toRadixString(16).padLeft(2, '0')} ");
    // print(
    //     "data2 ==$data2    0 =${a[2]}  ${a[2].toRadixString(16).padLeft(2, '0')}  1=${a[3]} ${a[3].toRadixString(16).padLeft(2, '0')} ");
    // print(
    //     "data3 ==$data3    0 =${a[4]}  ${a[4].toRadixString(16).padLeft(2, '0')}  1=${a[5]} ${a[5].toRadixString(16).padLeft(2, '0')} ");
    // print(
    //     "data4 ==$data4    0 =${a[6]}  ${a[6].toRadixString(16).padLeft(2, '0')}  1=${a[7]} ${a[7].toRadixString(16).padLeft(2, '0')} ");
    // print(
    //     "data5 ==$data5    0 =${a[7]}  ${a[8].toRadixString(16).padLeft(2, '0')}  1=${a[9]} ${a[9].toRadixString(16).padLeft(2, '0')} ");

    // int data7 = a[12] + a[13];
    // int data8 = a[14] + a[15];
    int size = 0;
    if (data[deviceId] != null) {
      if (data[deviceId]![0].isNotEmpty) {
        size = data[deviceId]![0].length;
        if (size >= maxx[deviceId]!) {
          if (minx[deviceId] == null)
            minx[deviceId] = 0;
          else
            minx[deviceId] = minx[deviceId]! + 1;
          if (maxx[deviceId] == null)
            maxx[deviceId] = 25;
          else
            maxx[deviceId] = maxx[deviceId]! + 1;

          // print(" data 刪除前size ====${data[0].length}");
          data[deviceId]![0].removeAt(0);
          data[deviceId]![1].removeAt(0);
          data[deviceId]![2].removeAt(0);
          data[deviceId]![3].removeAt(0);
          data[deviceId]![4].removeAt(0);
          data[deviceId]![5].removeAt(0);
          // print(" data 刪除後size ====${data[0].length}");
        }
        data[deviceId]![0]
            .add(FlSpot(index[deviceId]! + 1.toDouble(), data1.toDouble()));
        data[deviceId]![1]
            .add(FlSpot(index[deviceId]! + 1.toDouble(), data2.toDouble()));
        data[deviceId]![2]
            .add(FlSpot(index[deviceId]! + 1.toDouble(), data3.toDouble()));
        data[deviceId]![3]
            .add(FlSpot(index[deviceId]! + 1.toDouble(), data4.toDouble()));
        data[deviceId]![4]
            .add(FlSpot(index[deviceId]! + 1.toDouble(), data5.toDouble()));
        data[deviceId]![5]
            .add(FlSpot(index[deviceId]! + 1.toDouble(), data6.toDouble()));
      } else {
        List<List<FlSpot>> d = [[], [], [], [], [], [], [], [], [], []];
        d[0] = [FlSpot(0.toDouble(), data1.toDouble())];
        d[1] = [FlSpot(0.toDouble(), data2.toDouble())];
        d[2] = [FlSpot(0.toDouble(), data3.toDouble())];
        d[3] = [FlSpot(0.toDouble(), data4.toDouble())];
        d[4] = [FlSpot(0.toDouble(), data5.toDouble())];
        d[5] = [FlSpot(0.toDouble(), data6.toDouble())];
        data[deviceId] = d;
      }
    }
    index[deviceId] = index[deviceId]! + 1;

    notifyListeners();
  }

  set1605Data(String deviceId, List<int> a) {
    showData[deviceId] = a.map((i) => i.toString()).join(",");
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    // print(a);
    // print(
    //     "data1 ==${calculate1601(data1)}    1=${a[1]} ${a[1].toRadixString(16).padLeft(2, '0')}  0 =${a[0]} ${a[0].toRadixString(16).padLeft(2, '0')}   ");
    // print(
    //     "data2 ==${calculate1601(data2)}    1=${a[3]} ${a[3].toRadixString(16).padLeft(2, '0')}  0 =${a[2]} ${a[2].toRadixString(16).padLeft(2, '0')}   ");

    // print(
    //     "data3 ==${calculate1601(data3)}    1=${a[5]} ${a[5].toRadixString(16).padLeft(2, '0')}  0 =${a[4]} ${a[4].toRadixString(16).padLeft(2, '0')}   ");

    // int data7 = a[12] + a[13];
    // int data8 = a[14] + a[15];
    int size = 0;
    if (data[deviceId] != null) {
      if (data[deviceId]![0].isNotEmpty) {
        size = data[deviceId]![0].length;
        print("size==========$size");
        if (size >= maxx[deviceId]!) {
          if (minx[deviceId] == null)
            minx[deviceId] = 0;
          else
            minx[deviceId] = minx[deviceId]! + 1;
          if (maxx[deviceId] == null)
            maxx[deviceId] = 25;
          else
            maxx[deviceId] = maxx[deviceId]! + 1;

          // print(" data 刪除前size ====${data[0].length}");
          data[deviceId]![0].removeAt(0);
          data[deviceId]![1].removeAt(0);
          data[deviceId]![2].removeAt(0);
          // print(" data 刪除後size ====${data[0].length}");
        }
        data[deviceId]![0].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data1).toDouble()));
        data[deviceId]![1].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data2).toDouble()));
        data[deviceId]![2].add(FlSpot(
            index[deviceId]! + 1.toDouble(), calculate1601(data3).toDouble()));
      } else {
        List<List<FlSpot>> d = [[], [], [], [], [], [], [], [], [], []];
        d[0] = [FlSpot(0.toDouble(), calculate1601(data1).toDouble())];
        d[1] = [FlSpot(0.toDouble(), calculate1601(data2).toDouble())];
        d[2] = [FlSpot(0.toDouble(), calculate1601(data3).toDouble())];
        data[deviceId] = d;
      }
    }
    index[deviceId] = index[deviceId]! + 1;

    notifyListeners();
  }
}