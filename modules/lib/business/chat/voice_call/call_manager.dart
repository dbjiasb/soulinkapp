import 'package:modules/base/crypt/apis.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/api_service/api_service_export.dart';

class CallManager {
  //生成单利
  static final CallManager _instance = CallManager._internal();
  factory CallManager() {
    return _instance;
  }
  CallManager._internal();
  static CallManager get instance => _instance;

  Future<ApiResponse> dial({required int userId, int type = 1}) async {
    ApiRequest request = ApiRequest(Apis.security_dial, params: {Security.security_userId: userId, Security.security_type: type});
    ApiResponse response = await ApiService.instance.sendRequest(request);
    return response;
  }

  Future<ApiResponse> cancel({required int callId}) async {
    ApiRequest request = ApiRequest(Apis.security_giveUp, params: {Security.security_dialId: callId});
    return await ApiService.instance.sendRequest(request);
  }

  Future<ApiResponse> hangup({required int callId}) async {
    ApiRequest request = ApiRequest(Apis.security_endCall, params: {Security.security_dialId: callId});
    return await ApiService.instance.sendRequest(request);
  }
}
