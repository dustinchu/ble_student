import 'dart:math';
import 'dart:typed_data';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble_example/util/hex_to_int.dart';

import '../../common/service/db.dart';

class BleChartStatus extends ChangeNotifier {
  List<int> value = [];
  var bd = ByteData(4);
  int type = 1601;
  DB db = DB();
  List<List<FlSpot>> six = [[], [], [], [], [], [], [], [], [], []];
  List<List<FlSpot>> acc = [[], [], [], [], [], [], [], [], [], []];
  List<List<FlSpot>> gyro = [[], [], [], [], [], [], [], [], [], []];
  List<List<FlSpot>> dmpa = [[], [], [], [], [], [], [], [], [], []];
  List<List<FlSpot>> dmpg = [[], [], [], [], [], [], [], [], [], []];
  String showData = "";
  int minx = 0;
  int maxx = 300;
  var rng = Random();
  int index = 0;
  int lineCount = 6;
  int miny = -32768;
  int maxy = 32767;
  int electricity = 0;
  double temp = .0;
  double qw = 0.0, qx = 0.0, qy = 0.0, qz = 0.0;
  int btn = 0;
  bool saveStatus = false;
  String dbTableName = "";
  changeSavaStatus() {
    saveStatus = !saveStatus;
    notifyListeners();

    if (saveStatus) {
      insetFolder();
    } else {
      dbTableName = "";
    }
  }

// UserInfo={NSLocalizedDescription=near "10": syntax error
  String chartName() {
    switch (type) {
      case 1601:
        return "SIX";
      case 1606:
        return "ACC";
      case 1605:
        return "GYRO";
      case 1602:
        return "DMP_A";
      case 1604:
        return "DMP_G";

      default:
        return "";
    }
  }

  String dtStr() {
    DateTime dt = DateTime.now();
    return "${dt.year}-${dt.month}-${dt.day} ${dt.hour}:${dt.minute}:${dt.second}";
  }

  insetFolder() async {
    String dt = dtStr();
    dbTableName = chartName() + "-" + dt;
    print("insert folder  ==$dbTableName");
    await db.insertFolderValue(dbTableName, dt);
    // await db.select("select * from folder");
  }

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
    maxx = 300;
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
      return value - 65535;
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
    for (var i = 0; i < maxx - 1; i++) {
      double x = i.toDouble();
      double y = six[index][i + 1].y;
      f.add(FlSpot(x, y));
    }
    f.add(FlSpot(maxx.toDouble(), d));
    return f;
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
    showData =
        "qx:$data1\nqy:$data2\nqz:$data3\nax:$data4\nay:$data5\naz:$data6";
    if (dbTableName != "") {
      // Domain=FMDatabase Code=1 "near "10": syntax error" UserInfo={NSLocalizedDescription=near "10": syntax error
      db.insert1601(
          dbTableName, dtStr(), data1, data2, data3, data4, data5, data6);
    }

    int size = 0;
    if (six[0].isNotEmpty) {
      size = six[0].length;

      // print(
      //     "size==========$size   min ===$minx    maxx ==$maxx  data  ==${data[0]}");
      if (size >= maxx && six[0].isNotEmpty) {
        six[0] = list1601Move(0, calculate1601(data1).toDouble());
        six[1] = list1601Move(1, calculate1601(data2).toDouble());
        six[2] = list1601Move(2, calculate1601(data3).toDouble());
        six[3] = list1601Move(3, calculate1601(data4).toDouble());
        six[4] = list1601Move(4, calculate1601(data5).toDouble());
        six[5] = list1601Move(5, calculate1601(data6).toDouble());
      } else {
        // print(
        //     "index ===$index   data 3==${six[4]}   ${six[4].isEmpty}   ||  $data4   len  ${six[4].length}   index ==$index   data==${calculate1601(data1).toDouble()}");
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

  List<FlSpot> list1605Move(int index, double d, int value) {
    List<FlSpot> f = [];
    for (var i = 0; i < maxx - 1; i++) {
      // print(
      //     "value  index ==$index=====$i   ${data[index][i + 1].y}    len ==${data[index].length}");
      double x = i.toDouble();
      double y = 0;
      switch (value) {
        case 1606:
          y = gyro[index][i + 1].y;
          break;
        case 1605:
          y = acc[index][i + 1].y;
          break;
        case 1602:
          y = dmpa[index][i + 1].y;
          break;

        case 1604:
          y = dmpg[index][i + 1].y;
          break;
      }
      f.add(FlSpot(x, y));
    }
    f.add(FlSpot(maxx.toDouble(), d));
    return f;
  }

  set1605accData(List<int> a) {
    showData = a.map((i) => i.toString()).join(",");
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    if (dbTableName != "") {
      // Domain=FMDatabase Code=1 "near "10": syntax error" UserInfo={NSLocalizedDescription=near "10": syntax error
      db.insert1605(dbTableName, dtStr(), data1, data2, data3);
    }
    int size = 0;
    if (acc[0].isNotEmpty) {
      size = acc[0].length;
      // print("size==========$size");
      if (size >= maxx && acc[0].isNotEmpty) {
        acc[0] = list1605Move(0, calculate1601(data1).toDouble(), 1605);
        acc[1] = list1605Move(1, calculate1601(data2).toDouble(), 1605);
        acc[2] = list1605Move(2, calculate1601(data3).toDouble(), 1605);
      } else {
        acc[0].add(
            FlSpot(acc[0].length.toDouble(), calculate1601(data1).toDouble()));

        acc[1].add(
            FlSpot(acc[1].length.toDouble(), calculate1601(data2).toDouble()));
        acc[2].add(
            FlSpot(acc[2].length.toDouble(), calculate1601(data3).toDouble()));
      }
    } else {
      acc[0].add(
          FlSpot(acc[0].length.toDouble(), calculate1601(data1).toDouble()));

      acc[1].add(
          FlSpot(acc[1].length.toDouble(), calculate1601(data2).toDouble()));
      acc[2].add(
          FlSpot(acc[2].length.toDouble(), calculate1601(data3).toDouble()));
    }
    notifyListeners();
  }

  set1606gyroData(List<int> a) {
    showData = a.map((i) => i.toString()).join(",");
    int data1 = hexToInt(a[1].toRadixString(16).padLeft(2, '0') +
        a[0].toRadixString(16).padLeft(2, '0'));
    int data2 = hexToInt(a[3].toRadixString(16).padLeft(2, '0') +
        a[2].toRadixString(16).padLeft(2, '0'));
    int data3 = hexToInt(a[5].toRadixString(16).padLeft(2, '0') +
        a[4].toRadixString(16).padLeft(2, '0'));
    if (dbTableName != "") {
      // Domain=FMDatabase Code=1 "near "10": syntax error" UserInfo={NSLocalizedDescription=near "10": syntax error
      db.insert1606(dbTableName, dtStr(), data1, data2, data3);
    }
    int size = 0;
    if (gyro[0].isNotEmpty) {
      size = gyro[0].length;
      if (size >= maxx && gyro[0].isNotEmpty) {
        gyro[0] = list1605Move(0, calculate1601(data1).toDouble(), 1606);
        gyro[1] = list1605Move(1, calculate1601(data2).toDouble(), 1606);
        gyro[2] = list1605Move(2, calculate1601(data3).toDouble(), 1606);
      } else {
        gyro[0].add(
            FlSpot(gyro[0].length.toDouble(), calculate1601(data1).toDouble()));

        gyro[1].add(
            FlSpot(gyro[1].length.toDouble(), calculate1601(data2).toDouble()));
        gyro[2].add(
            FlSpot(gyro[2].length.toDouble(), calculate1601(data3).toDouble()));
      }
    } else {
      gyro[0].add(
          FlSpot(gyro[0].length.toDouble(), calculate1601(data1).toDouble()));

      gyro[1].add(
          FlSpot(gyro[1].length.toDouble(), calculate1601(data2).toDouble()));
      gyro[2].add(
          FlSpot(gyro[2].length.toDouble(), calculate1601(data3).toDouble()));
    }
    notifyListeners();
  }

  set1602Data(List<int> value) {
    print("1602===$value");
    qw = electricityDmp(value[0], value[1], value[2], value[3]);
    qx = electricityDmp(value[4], value[5], value[6], value[7]);
    qy = electricityDmp(value[8], value[9], value[10], value[11]);
    qz = electricityDmp(value[12], value[13], value[14], value[15]);
    showData = "qw:$qw\nqx:$qx\nqy:$qy\nqz:$qz";
    int data1 = hexToInt(value[17].toRadixString(16).padLeft(2, '0') +
        value[16].toRadixString(16).padLeft(2, '0'));

    int data2 = hexToInt(value[19].toRadixString(16).padLeft(2, '0') +
        value[18].toRadixString(16).padLeft(2, '0'));

    int data3 = hexToInt(value[21].toRadixString(16).padLeft(2, '0') +
        value[20].toRadixString(16).padLeft(2, '0'));

    int data4 = hexToInt(value[23].toRadixString(23).padLeft(2, '0') +
        value[22].toRadixString(16).padLeft(2, '0'));

    int data5 = hexToInt(value[25].toRadixString(23).padLeft(2, '0') +
        value[24].toRadixString(16).padLeft(2, '0'));

    int data6 = hexToInt(value[27].toRadixString(23).padLeft(2, '0') +
        value[26].toRadixString(16).padLeft(2, '0'));
    if (dbTableName != "") {
      // Domain=FMDatabase Code=1 "near "10": syntax error" UserInfo={NSLocalizedDescription=near "10": syntax error
      db.insert1602(dbTableName, dtStr(), qw, qx, qy, qz, data1, data2, data3,
          data4, data5, data6);
    }
    int size = 0;
    if (dmpa[0].isNotEmpty) {
      size = dmpa[0].length;
      if (size >= maxx && dmpa[0].isNotEmpty) {
        dmpa[0] = list1605Move(0, calculate1601(data1).toDouble(), 1602);
        dmpa[1] = list1605Move(1, calculate1601(data2).toDouble(), 1602);
        dmpa[2] = list1605Move(2, calculate1601(data3).toDouble(), 1602);
        dmpa[3] = list1605Move(3, calculate1601(data4).toDouble(), 1602);
        dmpa[4] = list1605Move(4, calculate1601(data5).toDouble(), 1602);
        dmpa[5] = list1605Move(5, calculate1601(data6).toDouble(), 1602);
      } else {
        dmpa[0].add(
            FlSpot(dmpa[0].length.toDouble(), calculate1601(data1).toDouble()));
        dmpa[1].add(
            FlSpot(dmpa[1].length.toDouble(), calculate1601(data2).toDouble()));
        dmpa[2].add(
            FlSpot(dmpa[2].length.toDouble(), calculate1601(data3).toDouble()));
        dmpa[3].add(
            FlSpot(dmpa[3].length.toDouble(), calculate1601(data4).toDouble()));
        dmpa[4].add(
            FlSpot(dmpa[4].length.toDouble(), calculate1601(data5).toDouble()));
        dmpa[5].add(
            FlSpot(dmpa[5].length.toDouble(), calculate1601(data6).toDouble()));
      }
    } else {
      dmpa[0].add(
          FlSpot(dmpa[0].length.toDouble(), calculate1601(data1).toDouble()));
      dmpa[1].add(
          FlSpot(dmpa[1].length.toDouble(), calculate1601(data2).toDouble()));
      dmpa[2].add(
          FlSpot(dmpa[2].length.toDouble(), calculate1601(data3).toDouble()));
      dmpa[3].add(
          FlSpot(dmpa[3].length.toDouble(), calculate1601(data4).toDouble()));
      dmpa[4].add(
          FlSpot(dmpa[4].length.toDouble(), calculate1601(data5).toDouble()));
      dmpa[5].add(
          FlSpot(dmpa[5].length.toDouble(), calculate1601(data6).toDouble()));
    }
    notifyListeners();
  }

  set1604Data(List<int> value) {
    qw = electricityDmp(value[0], value[1], value[2], value[3]);
    qx = electricityDmp(value[4], value[5], value[6], value[7]);
    qy = electricityDmp(value[8], value[9], value[10], value[11]);
    qz = electricityDmp(value[12], value[13], value[14], value[15]);
    showData = "qw:$qw\nqx:$qx\nqy:$qy\nqz:$qz";
    int data1 = hexToInt(value[17].toRadixString(16).padLeft(2, '0') +
        value[16].toRadixString(16).padLeft(2, '0'));

    int data2 = hexToInt(value[19].toRadixString(16).padLeft(2, '0') +
        value[18].toRadixString(16).padLeft(2, '0'));

    int data3 = hexToInt(value[21].toRadixString(16).padLeft(2, '0') +
        value[20].toRadixString(16).padLeft(2, '0'));
    if (dbTableName != "") {
      // Domain=FMDatabase Code=1 "near "10": syntax error" UserInfo={NSLocalizedDescription=near "10": syntax error
      db.insert1604(dbTableName, dtStr(), qw, qx, qy, qz, data1, data2, data3);
    }
    int size = 0;
    if (dmpg[0].isNotEmpty) {
      size = dmpg[0].length;
      if (size >= maxx && dmpg[0].isNotEmpty) {
        dmpg[0] = list1605Move(0, calculate1601(data1).toDouble(), 1604);
        dmpg[1] = list1605Move(1, calculate1601(data2).toDouble(), 1604);
        dmpg[2] = list1605Move(2, calculate1601(data3).toDouble(), 1604);
      } else {
        dmpg[0].add(
            FlSpot(dmpg[0].length.toDouble(), calculate1601(data1).toDouble()));
        dmpg[1].add(
            FlSpot(dmpg[1].length.toDouble(), calculate1601(data2).toDouble()));
        dmpg[2].add(
            FlSpot(dmpg[2].length.toDouble(), calculate1601(data3).toDouble()));
      }
    } else {
      dmpg[0].add(
          FlSpot(dmpg[0].length.toDouble(), calculate1601(data1).toDouble()));
      dmpg[1].add(
          FlSpot(dmpg[1].length.toDouble(), calculate1601(data2).toDouble()));
      dmpg[2].add(
          FlSpot(dmpg[2].length.toDouble(), calculate1601(data3).toDouble()));
    }
    notifyListeners();
  }
}
