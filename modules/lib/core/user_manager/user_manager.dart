import 'package:modules/base/crypt/apis.dart';
import 'package:modules/base/crypt/security.dart';
import 'dart:convert';
import 'package:modules/base/api_service/api_service_export.dart';

class UserInfo {
  Map<String, dynamic> data;
  UserInfo(this.data);

  String get coverImageUrl {
    return data[Security.security_coverUrl] ?? '';
  }

  UserInfo.none() : data = {} ; // 修复构造函数语法

  bool isNone() {
    return data.isEmpty;
  }

  @override
  String toString() {
    return jsonEncode(data);
  }
}

class UserManager {
  //生成单利
  static final UserManager _instance = UserManager._internal();
  UserManager._internal();
  factory UserManager() => _instance;
  static UserManager get instance => _instance;

  Future<UserInfo> getUserInfo(int userId) async {
    ApiRequest request = ApiRequest(Apis.security_fetchUserData, params: {Security.security_userId: userId});
    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      return UserInfo(response.data[Security.security_param]);
    } else {
      return UserInfo.none();
    }
  }
}
