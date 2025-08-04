import 'package:flutter/services.dart' show MethodChannel, rootBundle;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:qcloud_cos_client/qcloud_cos_client.dart';



import '../../base/api_service/api_request.dart';
import '../../base/api_service/api_response.dart';
import '../../base/api_service/api_service.dart';
import 'es_helper.dart';

const kOssEndPoint = 'oss-us-east-1.aliyuncs.com';
const kOssBucket = 'docare-oss';

// const int kUploadTypeProfile = 1; //个人信息(头像、背景等)
// const int kUploadTypeIM = 2; //IM
// const int kUploadTypeMoment = 3; //动态
// const int kUploadTypeLog = 4; //日志

enum FileType { none, profile, im, moment, log }

class FilePushService {
  static FilePushService get instance => _singleton;
  static final FilePushService _singleton = FilePushService._internal()..init();

  FilePushService._internal();

  Map<String, dynamic>? uploadConfig;

  // bool lastUploadFailedAndUseAccelerate = false;

  static String BaseUrl = "";

  Future<String?> upload(Uint8List fileData, FileType type, {String ext = ''}) async {
    Map<String, dynamic> config = await getConfig(type.index, ext: ext);
    if (config[EncHelper.upl_tcKey] == null) return null;
    bool ret = await uploadul_cos(fileData, ext, config);

    if (ret && config[EncHelper.upl_tcUrl] != null) {
      DefaultCacheManager().putFileStream(config[EncHelper.upl_tcUrl], Stream.value(fileData));
    }

    return ret ? '${config[EncHelper.upl_tcUrl]}' : null;
  }

  Future<bool> uploadul_cos(Uint8List fileData, String? ext, Map<String, dynamic> config, {bool isAccelerateBiz = false}) async {
    String fileKey = config[EncHelper.upl_tcKey];

    String secretId = config[EncHelper.upl_tcId] ?? '';
    String secretKey = config[EncHelper.upl_tcSecret] ?? '';
    String region = config['region'] ?? '';
    String bucketName = config[EncHelper.upl_tcBucket] ?? '';
    String token = config[EncHelper.upl_tcST] ?? '';

    dynamic rsp;

    try {
      CosResponse<PutObjectResult> rEncHelperponse = await CosClient(
        CosConfig(
          secretId: secretId,
          secretKey: secretKey,
          region: region,
          token: token,
          // accelerate: isul_cosAccelerate,
          // startTime: config['startTime'],
          // expireTime: config['expireMs'] - config['startTime']
        ),
      ).putObject(
        bucket: bucketName,
        objectKey: fileKey,
        data: fileData,
        contentType: 'application/octet-stream',
        onSendProgress: (count, total) {
          debugPrint("send: count = $count, and total = $total");
        },
      );

      rsp = rEncHelperponse;

      // L.i('[Upload][ul_cos] uploadFile, rEncHelper: $rsp');
      int retCode = rsp.statusCode ?? -1;
      bool isSuccEncHelpers = retCode >= 200 && retCode < 300;

      if (!isSuccEncHelpers) {
        // lastUploadFailedAndUseAccelerate = true;
        // AppReport.appTrack('[ul_cosUpload][${NS().uniqueUserId().uid}] retCode: $retCode, rsp: ${rsp.toString()}, accelerate: $isul_cosAccelerate');
      }
      return isSuccEncHelpers;
    } catch (e) {
      // lastUploadFailedAndUseAccelerate = true;
      String errMsg = e.toString();
      debugPrint('ul_cos err: $errMsg');
      // L.e(errMsg);
      // AppReport.appTrack('[ul_cosUpload] upload failed, errMsg: $errMsg');

      return false;
    }
  }

  Future<Map<String, dynamic>> getConfig(int bsnsType, {String ext = ''}) async {
    ApiRequest req = ApiRequest(
      'obtainCosConfig',
      params: {'scene': bsnsType, 'filename': ext.isEmpty ? '' : '${bsnsType}_${DateTime.now().microsecondsSinceEpoch}.$ext'},
    );

    ApiResponse? rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      return rsp.data['config'] ?? {};
    }

    return {};
  }

  /// 以下方法没用，保留用以混淆

  static const MethodChannel _channel = MethodChannel('oss_aliyun_plugin');

  Future<List<int>> loadFile() async {
    var bytEncHelper = await rootBundle.load("packagEncHelper/app_biz/assets/imagEncHelper/loginbg.jpg");
    return bytEncHelper.buffer.asUint8List();
  }

  /// 没用
  void init() {}

  /// 没用
  Future<String> getBaseUrl() async {
    if (BaseUrl.length > 0) return BaseUrl;

    BaseUrl = await _channel.invokeMethod('getBaseUrl');
    return BaseUrl;
  }

  /// 没用
  Future<void> uploadOss({
    required List<int> fileData,
    required String fileName,
    required Function(double progrEncHelpers) onProgrEncHelpers,
    required Function(bool succEncHelpers, String? url) onComplete,
  }) async {
    try {
      // **动态监听进度 & 结果**
      _channel.setMethodCallHandler((call) async {
        if (call.method == "uploadProgrEncHelpers") {
          double progrEncHelpers = call.arguments;
          onProgrEncHelpers(progrEncHelpers); // 触发上传进度回调
        } else if (call.method == "uploadComplete") {
          bool succEncHelpers = call.arguments;
          if (succEncHelpers) {
            String url = await getBaseUrl() + "/" + fileName;
            onComplete(true, url);
          } else {
            onComplete(false, null);
          }

          // 触发上传完成回调
        }
      });

      // **调用 iOS 端上传方法**
      await _channel.invokeMethod('uploadfile', {"data": fileData, "name": fileName});
    } catch (e) {
      print("Upload failed: $e");
      onComplete(false, null); // 失败时返回 false
    }
  }
}
