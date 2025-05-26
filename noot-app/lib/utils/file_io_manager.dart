import 'dart:convert';

import 'package:content_resolver/content_resolver.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:saf_util/saf_util.dart';
import 'package:saf_util/saf_util_platform_interface.dart';

/// Manages the connection to native Android, including:
/// file pickers, opening shared files, folder picker, and asking
/// for persistent permissions.
/// FIXME many magic strings in this file
class FileIOManager extends ChangeNotifier {

  final safUtilPlugin = SafUtil();
  static final FileIOManager _instance = FileIOManager._internal();

  factory FileIOManager() => _instance;

  FileIOManager._internal() {
    _initMethodChannel();
  }

  static const MethodChannel _channel =
      MethodChannel('com.droptablecompanies.todo/io');

  // static const EventChannel _eventsChannel = EventChannel('com.droptablecompanies.todo/events');

  String? _fileUri;
  String? get fileUri => _fileUri;

  void _initMethodChannel() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == "openFile") {
        _fileUri = call.arguments;
        notifyListeners();
      }
    });
  }

  Future<String> saveFileToDirectory(String dir, String fileName,
      {String mimeType = 'text/plain'}) async {
    return await _channel.invokeMethod('saveFileToDirectory', {
      'directory': dir,
      'fileName': fileName,
      'mimeType': mimeType,
    });
  }

  Future<bool> takePersistableUriPermission(String uri) async {
    try {
      await _channel.invokeMethod('takePersistableUriPermission', {
        'uri': uri,
      });
      return true;
    } on PlatformException catch (e) {
      debugPrint("Failed to take persistable URI permission: ${e.message}");
    }
    return false;
  }

  Future<Content> getContent(String uri) async {
    return await ContentResolver.resolveContent(uri);
  }

  Future<String> getContentString(String uri) async {
    final content = await ContentResolver.resolveContent(uri);
    return utf8.decode(content.data);
  }

  Future<String?> pickFile() async {
    const params = OpenFileDialogParams(
        dialogType: OpenFileDialogType.document,
        fileExtensionsFilter: ['txt', 'md'],
        copyFileToCacheDir: false);
    return await FlutterFileDialog.pickFile(params: params);
  }

  Future<String?> pickSimpleFolder() async {
    if (await FlutterFileDialog.isPickDirectorySupported()) {
      return (await FlutterFileDialog.pickDirectory())?.toString();
    }
    return null;
  }

  Future<SafDocumentFile?> pickFolder() async {
    String foldername = "/storage/emulator/0/Android/data/Downloads";
    return await safUtilPlugin.pickDirectory(
        writePermission: true,
        initialUri: foldername,
        persistablePermission: true);
  }

  listFiles(String uriString) {
    return safUtilPlugin.list(uriString);
  }

  void consume() {
    _fileUri = null;
  }
}
