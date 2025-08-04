import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:modules/base/app_info/app_manager.dart';
import 'package:modules/base/crypt/constants.dart';
import 'package:modules/base/preferences/preferences.dart';
import 'package:uuid/uuid.dart';

import '../crypt/crypt.dart';
import 'api_config.dart';
import 'api_request.dart';
import 'api_response.dart';

const kDeviceId = 'kDeviceId';

class ApiService {
  //生成单利
  static final ApiService _instance = ApiService._internal();
  factory ApiService() {
    return _instance;
  }

  late final Dio _dio;
  late Map<String, dynamic> _headers;
  final Map<String, String> _tokens = {};
  ApiService._internal() {
    init();
  }

  static ApiService get instance => _instance;

  void init() {
    _headers = {'Content-Type': 'application/json', 'Accept': 'application/json'};
    _dio = Dio(
      BaseOptions(baseUrl: ApiConfig.baseUrl, connectTimeout: const Duration(seconds: 30), receiveTimeout: const Duration(seconds: 30), headers: _headers),
    );
  }

  //headers
  void addHeaders(Map<String, dynamic> headers) {
    _headers.addAll(headers);
  }

  addTokens(Map<String, String> tokens) {
    _tokens.addAll(tokens);
  }

  String _deviceId = '';
  String get deviceId {
    if (_deviceId.isEmpty) {
      try {
        _deviceId = Preferences.instance.getString(kDeviceId) ?? '';
      } catch (e) {
        debugPrint('[ApiService] [deviceId] $e');
      }
    }
    if (_deviceId.isEmpty) {
      _deviceId = (const Uuid().v4()).replaceAll('-', '');
      try {
        Preferences.instance.setString(kDeviceId, _deviceId);
        debugPrint('[ApiService] [deviceId] is: $_deviceId');
      } catch (e) {
        debugPrint('[ApiService] [deviceId] $e');
      }
    }
    return _deviceId;
  }

  Map<String, dynamic> base() {
    return {
      ..._tokens,
      "did": deviceId,

      /// guid
      "platform": "1",

      /// platform
      "app": "lumina&apple",

      ///channel
      "lang": "en",
      "ver": AppManager.instance.appVersion,
      "build": "1",

      /// versionname
      "sysVer": "9.168.68.41",
      "zone": "UTC-6",

      /// timezone
      "deviceModel": "deviceName",
    };
  }

  Future<ApiResponse> sendRequest(ApiRequest request) async {
    debugPrint('[apiService] start sendRequest ${request.toString()}');
    try {
      Map<String, dynamic> body = {
        'method': request.method,
        'data': [
          {'base': base(), ...request.params},
          {'encode': true, 'key': cryptKey},
        ],
      };

      Map data = {};
      data[Constants.apiName] = request.method;
      data['body'] = Encryptor.encryptMap(body);

      Dio dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          validateStatus: (status) => status! < 500,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json', 'Crypt-Tag': cryptTag, 'Crypt-Key': cryptKey, ..._tokens}, // 默认 Header
        ),
      );

      final response = await dio.post(ApiConfig.path, data: data);
      ApiResponse apiResponse = ApiResponse.withResponse(response.data);
      debugPrint('[apiService] end sendRequest ${apiResponse.toString()}');
      return apiResponse;
    } catch (e) {
      debugPrint('[apiService] end error ${e.toString()}');
      return ApiResponse.withError({'code': -1, 'description': 'Network error, please try again later'});
    }
  }
}
