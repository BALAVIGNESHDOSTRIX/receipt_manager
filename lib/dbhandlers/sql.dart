import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

Future<void> InitDatabase() async {
  final appStorage = await getApplicationDocumentsDirectory();
  String dbpath = join(appStorage.path, 'recep.db');
  bool filex = await File(dbpath).exists();
  Database database = await openDatabase(dbpath, version: 1,
      onCreate: (Database db, int version) async {
    // When creating the db, create the table
    if (!filex) {
      await db.execute(
          'CREATE TABLE receipt_bill (ID INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, receipt_title TEXT, recep_bill_date TEXT,recep_bill_path TEXT)');
    }
  });
}

// Get Database Access
Future<Database> DBAccessor() async {
  final appStorage = await getApplicationDocumentsDirectory();
  String dbpath = join(appStorage.path, 'recep.db');
  Database dbs;
  var billdb = await openDatabase(dbpath,
      version: 1, onCreate: (Database db, int version) async {});
  return billdb;
}

Future<dynamic> InsertReceipt(String title, String date, String path) async {
  Database db = await DBAccessor();
  var insre = db.rawInsert(
      "INSERT INTO receipt_bill (receipt_title, recep_bill_date, recep_bill_path) VALUES('${title}', '${date}', '${path}')");
  return insre;
}

Future<List<Map<String, dynamic>>> getAllReceiptBill() async {
  await InitDatabase();
  Database db = await DBAccessor();
  var result =
      db.rawQuery("SELECT * FROM receipt_bill ORDER BY receipt_title ASC");
  return result;
}

Future<List<Map<String, dynamic>>> getReceiptBillbyDate(String date) async {
  await InitDatabase();
  Database db = await DBAccessor();
  var result = db.rawQuery(
      "SELECT * FROM receipt_bill WHERE recep_bill_date = '${date}' ORDER BY receipt_title ASC");
  return result;
}

Future<dynamic> DeleteReceipt(var ids) async {
  Database db = await DBAccessor();
  var del = db.rawDelete("DELETE FROM receipt_bill WHERE ID = '${ids}' ");
  return del;
}

Future<List<Map<String, dynamic>>> getReceiptbyTitle(String title) async {
  await InitDatabase();
  Database db = await DBAccessor();
  var result = db.rawQuery(
      "SELECT * FROM receipt_bill WHERE receipt_title LIKE '%${title}%'");
  return result;
}

Future<List<Map<String, dynamic>>> getTotalItemLength(String date) async {
  await InitDatabase();
  Database db = await DBAccessor();
  var result = db.rawQuery(
      "SELECT id as count FROM receipt_bill WHERE recep_bill_date = '${date}' ORDER BY ID asc LIMIT 1");
  return result;
}

Future<List<Map<String, dynamic>>> getRecordLength() async {
  await InitDatabase();
  Database db = await DBAccessor();
  var result = db.rawQuery("SELECT COUNT(*) as count FROM receipt_bill ");
  return result;
}

Future<List<Map<String, dynamic>>> getRecordLengthByDate(String date) async {
  await InitDatabase();
  Database db = await DBAccessor();
  var result = db.rawQuery(
      "SELECT COUNT(*) as count FROM receipt_bill WHERE recep_bill_date = '${date}'");
  return result;
}
