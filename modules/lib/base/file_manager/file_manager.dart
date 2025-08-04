import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static FileManager get instance => _instance;
  static final FileManager _instance = FileManager._internal();
  FileManager._internal();
  factory FileManager() => _instance;

  Future<void> init() async {
    await initCacheDirectory();
  }

  String cacheDirectory = '';
  Future<void> initCacheDirectory() async {
    cacheDirectory = '${(await getTemporaryDirectory()).path}/caches/';
    final directory = await Directory(cacheDirectory).create(recursive: true);
    debugPrint('[Audio Downloader] cacheDirectory: $cacheDirectory');
  }
}
