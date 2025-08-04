import 'dart:convert';
import 'package:get/get.dart';

import 'package:flutter/cupertino.dart';
import 'package:modules/base/advertisement/ad_manager.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:modules/base/push_service/push_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../base/api_service/api_service_export.dart';
import '../../base/preferences/preferences.dart';
import 'package:modules/base/crypt/constants.dart';
const String kEventCenterUserDidLogout = 'kEventCenterUserDidLogout';
const String kEventCenterUserDidLogin = 'kEventCenterUserDidLogin';

//生成一个账户类型的枚举，包含email, google, apple.其中email的值是11, apple是4，google是7
enum AccountType {
  email(11),
  apple(4),
  google(7);

  final int value;
  const AccountType(this.value);
}

class Account {
  // 账户信息
  String get id => userId.toString();
  int get userId => userBase['uid'] ?? 0;
  bool get isLoggedIn => userId > 0;

  String token;
  RxMap _userInfo = {}.obs;

  Map get userInfo => _userInfo;
  Map get userBase => userInfo['baseInfo'] ?? {};
  String get name => userBase['nickName'] ?? '';
  String get avatar => userBase['avatarUrl'] ?? '';

  String get bio => userInfo['bio'] ?? '';

  String get gender {
    switch (userInfo['baseInfo']?['gender'] ?? 0) {
      case 1:
        return 'Male';
      case 2:
        return 'Female';
      default:
        return 'unknown';
    }
  }

  int get birthday => userInfo['birthday'] ?? 0;

  Account(this.token, Map user) {
    _userInfo.value = user;
  }
  Account.fromJson(Map<String, dynamic> json) : token = json['token'] ?? '' {
    _userInfo.value = (json['userInfo'] ?? {});
  }

  String toJson() {
    return JsonEncoder().convert({'token': token, 'userInfo': userInfo});
  }

  void _updateUserInfo(Map userInfo) {
    _userInfo.value = userInfo;
  }

  Account.none() : token = '', _userInfo = {}.obs;

  // 钱包信息
  RxMap wealthInfo = {}.obs;
  int get coins => wealthInfo['0'] ?? 0;
  int get gems => wealthInfo['1'] ?? 0;

  // 会员权限
  RxMap premInfo = {}.obs;
  int get premStatus => premInfo['status'] ?? 0;
  int get premEdTm => premInfo['endTime'] ?? 0;
  int get premCdType => premInfo['premiumCardType'] ?? 0;
  List get premBenfs => premInfo['premiums'] ?? [];

  Map get premUsedInfo => premInfo['usedInfo'] ?? {};

  bool get isSubscribed => premStatus == 1;
  bool get isWkPrem => isSubscribed && premCdType == 1;
  bool get isMthPrem => isSubscribed && premCdType == 2;
  bool get isYrPrem => isSubscribed && premCdType == 4;

  int get freeImgUsedTimes => isSubscribed? premUsedInfo['1']['useTimes']:0;
  int get freeVdoUsedTimes => isSubscribed? premUsedInfo['3']['useTimes']:0;
  int get freeAdoUsedTimes => isSubscribed? premUsedInfo['2']['useTimes']:0;
  int get freeOcUsedTimes => isSubscribed? premUsedInfo['10']['useTimes']:0;

  int get freeImgLeftTimes => isSubscribed? premUsedInfo['1']['leftTimes']:0;
  int get freeVdoLeftTimes => isSubscribed? premUsedInfo['3']['leftTimes']:0;
  int get freeAdoLeftTimes => isSubscribed? premUsedInfo['2']['leftTimes']:0;
  int get freeOcLeftTimes => isSubscribed? premUsedInfo['10']['leftTimes']:0;

  void setPremInfo(data) {
    if(data == null)return;
    premInfo.value = data;
    premInfo.refresh();
  }

}

Account get MyAccount => AccountService.instance.account;

class AccountService {
  static String kAccountKey = 'kAccountKey';

  //生成单利
  AccountService._internal();
  static final AccountService _instance = AccountService._internal();
  factory AccountService() {
    return _instance;
  }
  static AccountService get instance => _instance;

  bool get loggedIn => account.isLoggedIn;

  Account account = Account.none();


  init() {
    //从本地获取账户信息
    account = getAccount();
    if (loggedIn) {
      handleLoggedIn();
      refreshBalance();
      getMyPremInfo();
    }

    //监听登录、注销事件
    EventCenter.instance.addListener(kEventCenterKickOff, (data) {
      logout();
    });

  }

  Future<ApiResponse> getVerifyCode(String account, AccountType type) async {
    ApiRequest request = ApiRequest('fetchVerificationCode', params: {'account': account, 'type': type.value});
    ApiResponse response = await ApiService.instance.sendRequest(request);
    return response;
  }

  Future<ApiResponse> loginWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName]);
    String? name = appleCredential.givenName;
    if (appleCredential.familyName != null) {
      name = '$name ${appleCredential.familyName}';
    }

    return await login(appleCredential.email ?? '', appleCredential.identityToken ?? '', AccountType.apple, thirdName: name ?? '');
  }

  Future<ApiResponse> loginWithEmail(String email, String password) async {
    return login(email, password, AccountType.email);
  }

  //登录
  Future<ApiResponse> login(String account, String password, AccountType accountType, {String thirdName = ''}) async {
    ApiRequest request = ApiRequest(
      'signIn',
      params: {
        'account': account,
        'token': password,
        'type': accountType.value,
        Constants.adUpdate: 1,
        Constants.adSetupInfo: AdManager.instance.data,
        Constants.adDevice: await AdManager.instance.platformAdId,
        Constants.adKey: await AdManager.instance.adId,
      },
    );

    ApiResponse response = await ApiService.instance.sendRequest(request);
    debugPrint('login response is ${response.data}');
    if (response.isSuccess) {
      analyseResponse(response);
    }
    return response;
  }

  void analyseResponse(ApiResponse response) {
    Map<String, dynamic> userInfo = response.data['userInfo'] ?? {};
    String token = response.data['token'] ?? '';

    account = Account(token, userInfo);
    saveAccount();
    if (loggedIn) {
      handleLoggedIn();
      refreshBalance();
      getMyPremInfo();
    }
  }

  void saveAccount() {
    //保存账户信息
    Preferences.instance.setString(kAccountKey, account.toJson());
  }

  Account getAccount() {
    //获取账户信息
    String json = Preferences.instance.getString(kAccountKey) ?? '{}';
    return Account.fromJson(jsonDecode(json));
  }

  void handleLoggedIn() {
    ApiService.instance.addTokens({'token': account.token, 'uid': account.id});
    EventCenter.instance.sendEvent(kEventCenterUserDidLogin, null);
    PushService.instance.secretKey = account.id;
  }

  void logout() {
    account = Account.none();
    Preferences.instance.remove(kAccountKey);
    ApiService.instance.addTokens({'token': account.token, 'uid': account.id});
    EventCenter.instance.sendEvent(kEventCenterUserDidLogout, null);
    PushService.instance.secretKey = '0';
  }

  Future<ApiResponse> deleteAccount() async {
    ApiRequest request = ApiRequest('deleteAccount', params: {});
    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      logout();
    }
    return response;
  }


  //enum EUpdateFlag
  //     {
  //         NICKNAME   = 1,   //更新昵称
  //         AVATAR_URL = 2,   //更新头像
  //         GENDER     = 4,   //更新性别
  //         BIRTHDAY   = 8,   //更新生日
  //         BIO        = 16,  //更新简介
  //         EDUCATION  = 32,  //更新教育信息
  //         CAREER     = 64,  //更新职业信息
  //         HOBBY      = 128, //更新爱好信息
  //         CHARACTER  = 256, //更新性格偏好信息
  //         SEXUAL_ORIENTATION   = 512, //更新性取向
  //     };
  // 按位标识，同时更新多个用户信息可做或运算0

  Future<bool> updateMyInfo({String? name, String? birthday, int? gender, String? bio, String? avatar}) async {

    int flag = 0;
    if (name != null) flag |= 1;
    if (avatar != null) flag |= 2;
    if (gender != null) flag |= 4;
    if (birthday != null) flag |= 8;
    if (bio != null) flag |= 16;


    final req = ApiRequest('updateUserInfo', params: {
      'flag': flag,
      'nickName': name ?? '',
      'birthday': birthday ?? '',
      'gender': gender ?? 0,
      'bio': bio ?? '',
      'avatarUrl': avatar ?? '',
    });
    final rsp = await ApiService.instance.sendRequest(req);
    if (!rsp.isSuccess) return false;
    return true;
  }

  Future<void> updateMyAvatar(String avatarUrl) async {
    updateMyInfo(avatar: avatarUrl);
  }

  /// balance
  void refreshBalance() async {
    final req = ApiRequest('fetchBalance', params: {
      'uid': account.id
    });
    final rsp = await ApiService.instance.sendRequest(req);

    if (rsp.statusCode != 200 || rsp.bsnsCode != 0) return;

    if ((rsp.data['balance'] ?? {}).isEmpty) return;
    account.wealthInfo.value = rsp.data['balance'];
  }

  void getMyPremInfo() async {
    final req = ApiRequest('queryMyPremiumInfo', params: {});
    final rsp = await ApiService.instance.sendRequest(req);

    if (rsp.statusCode != 200 || rsp.bsnsCode != 0) return;

    if ((rsp.data['ownPremium'] ?? {}).isEmpty) return;
    account.premInfo.value = rsp.data['ownPremium'];
  }
}
