import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:modules/base/api_service/api_service_export.dart';
import 'package:modules/base/file_manager/file_manager.dart';
import 'package:modules/business/chat/chat_room_cells/chat_audio_message.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import './chat_room_cells/chat_text_cell.dart';
import 'package:dio/dio.dart' as dio;

class TTSResult {
  String ttsUrl;
  int ttsDuration;
  bool success;

  TTSResult(this.ttsUrl, this.ttsDuration, this.success);

  Map<String, dynamic> toJson() {
    return {'ttsUrl': ttsUrl, 'ttsDuration': ttsDuration};
  }

  factory TTSResult.error() {
    return TTSResult('', 0, false);
  }
}

class ChatVoiceManager {
  //生成单例
  static ChatVoiceManager get instance => _instance;
  static final ChatVoiceManager _instance = ChatVoiceManager._internal();

  ChatVoiceManager._internal();

  factory ChatVoiceManager() => _instance;

  String get workDirectory => FileManager.instance.cacheDirectory;

  Future<TTSResult> textToVoice(ChatTextMessage message) async {
    ApiRequest request = ApiRequest('convertContentToVoice',
        params: {'userId': message.senderId, 'content': message.text});

    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      String url = response.data['ttsUrl'] ?? '';
      String path = pathForUrl(url);
      int duration = response.data['time'] ?? 0;
      List<int> bytes = (response.data['result'] as List<dynamic>).map((
          item) => item as int).toList();
      final file = File(path);
      file.writeAsBytesSync(bytes);
      return TTSResult(url, duration, true);
    }
    return TTSResult.error();
  }

  String encodeUrl(String url) {
    return md5.convert(utf8.encode(url)).toString();
  }

  String pathForUrl(String url) {
    String fileName = encodeUrl(url);
    return '$workDirectory/$fileName.mp3';
  }

  String? voicePathForUrl(String url) {
    String fileName = encodeUrl(url);
    String path = '$workDirectory/$fileName.mp3';
    if (File(path).existsSync()) {
      return path;
    }
    return null;
  }

  void downloadSrc(String url) async {
    try {
      final localPath = pathForUrl(url);
      final rsp = await dio.Dio().download(url, localPath, options:
      dio.Options(responseType: dio.ResponseType.bytes));

      if(rsp.statusCode != 200) {
        // 下载失败
        EasyLoading.showToast('cannot download source, please try again later');
      }
    }catch(e){
      EasyLoading.showToast('cannot download source, please try again later');
    }
  }

}
