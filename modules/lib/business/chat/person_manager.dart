
import 'package:modules/base/api_service/api_request.dart';
import 'package:modules/base/api_service/api_service.dart';

import '../../core/user_manager/user_manager.dart';

class PersonManager {
  //生成单利
  static final PersonManager _instance = PersonManager._internal();
  PersonManager._internal();
  factory PersonManager() => _instance;
  static PersonManager get instance => _instance;

  Future<UserInfo> getUserInfo(int userId) async {
    return await UserManager.instance.getUserInfo(userId);
  }

  Future<bool> followUser(int userId,int todo) async{
    final req = ApiRequest('star',params: {'otherUid':userId,'action':todo});
    final rsp = await ApiService.instance.sendRequest(req);
    if(rsp.isSuccess){
      return true;
    }
    return false;
  }
}
