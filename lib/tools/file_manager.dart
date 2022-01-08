import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:mime_type/mime_type.dart';
import 'package:mime/mime.dart';
import 'dart:math';

const _chars = 'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
Random _rnd = Random();

String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
    length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

Future<dynamic> SaveFilePermenately(PlatformFile file) async {
  final appStorage = await getApplicationDocumentsDirectory();
  String refile = await FileNamer(file.name);
  final newfile = File('${appStorage.path}/${refile}');
  File(file.path!).copy(newfile.path);
  return refile;
}

Future<dynamic> DeleteFile(String path) async {
  final appStorage = await getApplicationDocumentsDirectory();
  final _localfile = File('${appStorage.path}/${path}');
  bool check = await _localfile.exists();
  if (check) {
    await _localfile.delete();
    return 2;
  }
  return 0;
}

Future<dynamic> FileNamer(String path) async {
  final appStorage = await getApplicationDocumentsDirectory();
  final _localfile = File('${appStorage.path}/${path}');
  bool check = await _localfile.exists();
  if (check) {
    return getRandomString(10) + '_' + path;
  }
  return path;
}

IconsPredict(String mime) {
  if (mime == 'application/pdf') {
    return FontAwesomeIcons.filePdf;
  }
  if (mime == 'application/png' ||
      mime == 'application/jpeg' ||
      mime == 'image/png' ||
      mime == 'image/jpeg') {
    return FontAwesomeIcons.fileImage;
  }
  if (mime == 'application/msword') {
    return FontAwesomeIcons.fileWord;
  }
  return FontAwesomeIcons.fileImage;
}

IconsColor(String mime) {
  if (mime == 'application/pdf') {
    return Colors.red;
  }
  if (mime == 'application/png' ||
      mime == 'application/jpeg' ||
      mime == 'image/png' ||
      mime == 'image/jpeg') {
    return Colors.black;
  }
  if (mime == 'application/msword') {
    return Colors.blue;
  }
}

// Future<dynamic> ReadFileByte(String filePath) async {
//   Uri myUri = Uri.parse(filePath);
//   File imageFile = new File.fromUri(myUri);
//   return await imageFile.readAsBytes();
// }

Future<File> SaveImagePermenately(var image) async {
  var filename = basename(image.path);
  final appStorage = await getApplicationDocumentsDirectory();
  final newfile = File('${appStorage.path}/${filename}');
  return File(image.path).copy(newfile.path);
}

Future<dynamic> ReturnFilePath(String filename) async {
  final appStorage = await getApplicationDocumentsDirectory();
  return '${appStorage.path}/${filename}';
}

dynamic MimeType(String filename) {
  return lookupMimeType(filename);
}

Future<dynamic> DeleteCache() async {
  final CacheDir = await getTemporaryDirectory();
  final AppSupDir = await getApplicationSupportDirectory();
  if (CacheDir.existsSync()) {
    CacheDir.deleteSync(recursive: true);
  }
  if (AppSupDir.existsSync()) {
    AppSupDir.deleteSync(recursive: true);
  }
}
