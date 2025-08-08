import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:modules/base/app_info/app_manager.dart';
import 'package:modules/base/crypt/constants.dart';
import 'package:modules/base/crypt/copywriting.dart';
import 'package:modules/base/crypt/other.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/preferences/preferences.dart';
import 'package:uuid/uuid.dart';

import '../casual/casual.dart';
import '../crypt/crypt.dart';
import 'api_config.dart';
import 'api_request.dart';
import 'api_response.dart';

String kDeviceId = Security.security_kDeviceId;

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
    _headers = {Other.security_content_Type: Other.security_application_json, Security.security_Accept: Other.security_application_json};
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

  String _randomIP = '';
  String get randomIP {
    if (_randomIP.isEmpty) {
      _randomIP = Casual.randomIP();
    }
    return _randomIP;
  }

  String _randomTimeZone = '';
  String get randomTimeZone {
    if (_randomTimeZone.isEmpty) {
      _randomTimeZone = Casual.randomTimeZone();
    }
    return _randomTimeZone;
  }

  Map<String, dynamic> base() {
    return {
      ..._tokens,
      Security.security_did: deviceId,

      /// guid
      Security.security_platform: "1",

      /// platform
      Security.security_app: "soulink&apple",

      ///channel
      Security.security_lang: Security.security_en,
      Security.security_ver: AppManager.instance.appVersion,
      Security.security_build: "1",

      /// versionname
      Security.security_sysVer: randomIP,
      Security.security_zone: randomTimeZone,

      /// timezone
      Security.security_deviceModel: Security.security_deviceName,
    };
  }

  Future<ApiResponse> sendRequest(ApiRequest request) async {
    debugPrint('[apiService] start sendRequest ${request.toString()}');
    try {
      Map<String, dynamic> body = {
        Security.security_method: request.method,
        Security.security_data: [
          {Security.security_base: base(), ...request.params},
          {Security.security_encode: true, Security.security_key: cryptKey},
        ],
      };

      Map data = {};
      data[Constants.apiName] = request.method;
      data[Security.security_body] = Encryptor.encryptMap(body);

      Dio dio = Dio(
        BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          validateStatus: (status) => status! < 500,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            Other.security_content_Type: Other.security_application_json,
            Other.security_crypt_Tag: cryptTag,
            Other.security_crypt_Key: cryptKey,
            ..._tokens,
          }, // 默认 Header
        ),
      );

      final response = await dio.post(ApiConfig.path, data: data);
      ApiResponse apiResponse = ApiResponse.withResponse(response.data);
      debugPrint('[apiService] end sendRequest ${apiResponse.toString()}');
      return apiResponse;
    } catch (e) {
      debugPrint('[apiService] end error ${e.toString()}');
      return ApiResponse.withError({Security.security_code: -1, Security.security_description: Copywriting.security_network_error__please_try_again_later});
    }
  }
}
