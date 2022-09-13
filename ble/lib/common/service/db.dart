import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DB {
  Future copy() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "mydatabase.db");

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      log("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data =
          await rootBundle.load(join("assets", "data/mydatabase.db"));
      List<int> bytes =
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      log("Opening existing database");
    }
  }

  Future<Database> openDB() async {
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "mydatabase.db");
    var exists = await databaseExists(path);
    var db = await openDatabase(path, readOnly: false);
    return db;
  }

  Future<List<Map<String, Object?>>> select(String queryCode) async {
    var db = await openDB();
    try {
      var list = await db.rawQuery(queryCode);
      return list;
    } catch (e) {
      log("error $e");
    } finally {
      db.close();
    }
    return [];
  }

  Future createTeble(String code) async {
    var db = await openDB();
    try {
      await db.execute(code);
    } catch (e) {
      log("create error= $e");
    } finally {
      db.close();
    }
  }

  close() async {
    var db = await openDB();
    db.close();
  }

  Future insertFolderValue(String name, String dt) async {
    var db = await openDB();
    try {
      int recordId = await db
          .rawInsert("INSERT INTO folder (name, dt) VALUES ('$name', '$dt')");
      log("inset record id  name ==$name  ==$recordId");
    } catch (e) {
      log("create error= $e");
    } finally {
      db.close();
    }
  }

  Future insert1601(String name, String dt, int qx, int qy, int qz, int ax,
      int ay, int az) async {
    var db = await openDB();
    try {
      int recordId = await db.rawInsert(
          "INSERT INTO six (name, dt, qx, qy, qz, ax, ay, az) VALUES ('$name','$dt',$qx,$qy,$qz,$ax,$ay,$az)");
      log("1601 inset record id  ==$recordId");
    } catch (e) {
      log("create error= $e");
    } finally {
      db.close();
    }
  }

  Future insert1606(String name, String dt, int ax, int ay, int az) async {
    var db = await openDB();
    try {
      int recordId = await db.rawInsert(
          "INSERT INTO acc (name, dt, ax, ay, az) VALUES ('$name','$dt',$ax,$ay,$az)");
      log("inset record id  ==$recordId");
    } catch (e) {
      log("1605 create error= $e");
    } finally {
      db.close();
    }
  }

  Future insert1605(String name, String dt, int qx, int qy, int qz) async {
    var db = await openDB();
    try {
      int recordId = await db.rawInsert(
          "INSERT INTO gyro (name, dt, qx, qy, qz) VALUES ('$name','$dt',$qx,$qy,$qz)");
      log("inset record id  ==$recordId");
    } catch (e) {
      log("1605 create error= $e");
    } finally {
      db.close();
    }
  }

  Future insert1602(String name, String dt, double qw, double qx, double qy,
      double qz, int ax, int ay, int az, int gx, int gy, int gz) async {
    var db = await openDB();
    try {
      int recordId = await db.rawInsert(
          "INSERT INTO dmp_a (name, dt, qw, qx, qy,qz,ax,ay,az,gx,gy,gz) VALUES ('$name','$dt',$qw,$qx,$qy,$qz,$ax,$ay,$az,$gx,$gy,$gz)");
      log("inset record id  ==$recordId");
    } catch (e) {
      log("1605 create error= $e");
    } finally {
      db.close();
    }
  }

  Future insert1604(String name, String dt, double qw, double qx, double qy,
      double qz, int gx, int gy, int gz) async {
    var db = await openDB();
    print(
        "insert===${"INSERT INTO dmp_g (name, dt, qw, qx, qy,qz,gx,gy,gz) VALUES ('$name','$dt',$qw,$qx,$qy,$qz,$gx,$gy,$gz)"}");
    try {
      int recordId = await db.rawInsert(
          "INSERT INTO dmp_g (name, dt, qw, qx, qy,qz,gx,gy,gz) VALUES ('$name','$dt',$qw,$qx,$qy,$qz,$gx,$gy,$gz)");
      log("inset record id  ==$recordId");
    } catch (e) {
      log("1605 create error= $e");
    } finally {
      db.close();
    }
  }

  Future delete(String name, String dbName) async {
    var db = await openDB();

    try {
      var count =
          await db.delete("folder", where: 'name = ?', whereArgs: [dbName]);
      log("delete1 count ==$count");
      count = await db.delete(name, where: 'name = ?', whereArgs: [dbName]);
      log("delete2 count ==$count");
    } catch (e) {
      log("create error= $e");
    } finally {
      db.close();
    }
  }
}
