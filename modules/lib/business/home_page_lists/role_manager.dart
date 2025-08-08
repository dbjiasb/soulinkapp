import 'package:modules/base/crypt/apis.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/api_service/api_service_export.dart';

enum RoleListType {
  ai_and_script(0),
  ai(1),
  script(2),
  real(3),
  custom_ai(4),
  share_ai(5),
  robot_and_real(6),
  role_play(8),
  ugc(9),
  dating(10),
  pro_only(11),
  theater(1000);

  final int value;

  const RoleListType(this.value);
}

class RoleManager {
  static final RoleManager _instance = RoleManager._internal();
  RoleManager._internal();
  factory RoleManager() => _instance;
  static RoleManager get instance => _instance;

  Future<ApiResponse> getRoleList({int version = 0, int pageIndex = 0, int targetUid = 0, RoleListType type = RoleListType.ai, int pageSize = 20}) async {
    Map<String, dynamic> params = {};
    params[Security.security_version] = version;
    params[Security.security_index] = pageIndex;
    params[Security.security_length] = pageSize;
    params[Security.security_type] = type.value;
    params[Security.security_userId] = targetUid;

    ApiRequest request = ApiRequest(Apis.security_fetchUsers, params: params);
    return await ApiService.instance.sendRequest(request);
  }
}
