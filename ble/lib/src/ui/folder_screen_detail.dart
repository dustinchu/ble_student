import 'dart:io';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../common/dialog.dart';
import '../../common/service/db.dart';

class FolderDetailScreen extends StatefulWidget {
  FolderDetailScreen({Key? key, required this.title, required this.dt})
      : super(key: key);
  String title;
  String dt;
  @override
  State<FolderDetailScreen> createState() => _FolderDetailScreenState();
}

class _FolderDetailScreenState extends State<FolderDetailScreen> {
  DB db = DB();
  List<Map<String, Object?>> data = [];
  late List<List<dynamic>> employeeData;
  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() async {
    data = await db.select(
        "select ${widget.title}.* from folder , ${widget.title}  where  folder.name = ${widget.title}.name ");
    setState(() {});
  }

  getCsvData() async {
    employeeData = List<List<dynamic>>.empty(growable: true);
    switch (widget.title) {
      case "SIX":
        employeeData
            .add(["name", "qx", "qy", "qz", "ax", "ay", "az", "dataTime"]);
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = List.empty(growable: true);
          row.add(widget.title);
          row.add(data[i]["qx"]);
          row.add(data[i]["qy"]);
          row.add(data[i]["qz"]);
          row.add(data[i]["ax"]);
          row.add(data[i]["ay"]);
          row.add(data[i]["az"]);
          row.add(data[i]["dt"]);
          employeeData.add(row);
        }
        break;
      case "GYRO":
        employeeData.add(["name", "qx", "qy", "qz", "dataTime"]);
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = List.empty(growable: true);
          row.add(widget.title);
          row.add(data[i]["qx"]);
          row.add(data[i]["qy"]);
          row.add(data[i]["qz"]);
          row.add(data[i]["dt"]);
          employeeData.add(row);
        }
        break;
      case "DMP_G":
        employeeData.add(
            ["name", "qw", "qx", "qy", "qz", "gx", "gy", "gz", "dataTime"]);
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = List.empty(growable: true);
          row.add(widget.title);
          row.add(data[i]["qw"]);
          row.add(data[i]["qx"]);
          row.add(data[i]["qy"]);
          row.add(data[i]["qz"]);
          row.add(data[i]["gx"]);
          row.add(data[i]["gy"]);
          row.add(data[i]["gz"]);
          row.add(data[i]["dt"]);
          employeeData.add(row);
        }
        break;
      case "DMP_A":
        employeeData.add([
          "name",
          "qw",
          "qx",
          "qy",
          "qz",
          "ax",
          "ay",
          "az",
          "gx",
          "gy",
          "gz",
          "dataTime"
        ]);
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = List.empty(growable: true);
          row.add(widget.title);
          row.add(data[i]["qw"]);
          row.add(data[i]["qx"]);
          row.add(data[i]["qy"]);
          row.add(data[i]["qz"]);
          row.add(data[i]["ax"]);
          row.add(data[i]["ay"]);
          row.add(data[i]["az"]);
          row.add(data[i]["gx"]);
          row.add(data[i]["gy"]);
          row.add(data[i]["gz"]);
          row.add(data[i]["dt"]);
          employeeData.add(row);
        }

        break;
      case "ACC":
        employeeData.add(["name", "ax", "ay", "az", "dataTime"]);
        for (int i = 0; i < data.length; i++) {
          List<dynamic> row = List.empty(growable: true);
          row.add(widget.title);
          row.add(data[i]["ax"]);
          row.add(data[i]["ay"]);
          row.add(data[i]["az"]);
          row.add(data[i]["dt"]);
          employeeData.add(row);
        }

        break;

      default:
        employeeData.add([]);
    }
  }

  String dtStr() {
    DateTime dt = DateTime.now();
    return "${dt.month}${dt.day}${dt.hour}${dt.minute}${dt.second}";
  }

//  Unhandled Exception: FileSystemException: Cannot open file, path =
  save() async {
    await getCsvData();
    if (await Permission.storage.request().isGranted) {
      Directory generalDownloadDir = Directory('/storage/emulated/0/Download');
      File f =
          File(generalDownloadDir.path + "/${widget.title}-${dtStr()}.csv");
      String csv = const ListToCsvConverter().convert(employeeData);
      f.writeAsString(csv);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return msgDialog(context, "成功", "CSV寫入成功");
          });
    } else {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.storage,
      ].request();
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return msgDialog(context, "錯誤", "沒有寫入權限");
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.title} Detail"),
        centerTitle: true,
        actions: [
          Platform.isAndroid
              ? IconButton(
                  icon: Icon(
                    Icons.download,
                    color: data.length > 0 ? Colors.white : Colors.white54,
                  ),
                  onPressed: () async {
                    if (data.length > 0) {
                      await save();
                    }
                  },
                )
              : Container(),
          IconButton(
              onPressed: () async {
                // SIX-2022-9-12 13:12:13
                //             SIX-2022-9-12 13:12:13

                await db.delete(widget.title, widget.title + "-" + widget.dt);
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return msgDialog(context, "成功", "刪除成功");
                    }).then((value) => Navigator.of(context).pop());
              },
              icon: Icon(Icons.delete))
        ],
      ),
      body: ListView.builder(
        itemCount: data.length,
        itemBuilder: (context, index) {
          return Column(
            children: <Widget>[
              ListTile(
                title: Text(data[index].toString()),
              ),
              Divider(), //                           <-- Divider
            ],
          );
        },
      ),
      // body: Column(
      //   children: [Text(data.length > 0 ? data[0].toString() : "")],
      // ),
    );
  }
}
