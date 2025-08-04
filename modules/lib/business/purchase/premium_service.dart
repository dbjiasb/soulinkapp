import 'package:modules/base/crypt/security.dart';
// import 'package:modules/base/api_service/api_request.dart';
// import 'package:modules/base/api_service/api_service.dart';
// import 'package:get/get.dart';
// import 'package:modules/base/event_center/event_center.dart';
// import 'package:intl/intl.dart';
//
// import '../../core/account/account_service.dart';
//
// class PremiumService {
//   // api
//   static String get queryPremiumCardsApi => 'queryPremiumCards'; //getPremiumInfoV2
//   static String get queryMyPremiumInfoApi => 'queryMyPremiumInfo'; //getUserOwnPremiumInfo
//
//   static String get trUid => 'targetRobotUid';
//
//   static String get rItem => 'rechargeItem';
//
//   static String get pItems => 'premiumItems';
//
//   static String get prmType => Security.security_premiumCardType;
//
//   static String get prmItmType => 'premiumItemType';
//
//   static String get successTips => 'You\'re now a premium member!\nYour benefits are unlocked.\nExplore your new perks!';
//
//   static String get slogan => 'Chat beyond reality, role play without limits';
//
//   static String get usageDetail => 'Benefits Usage Detail';
//
//   static String get costType => Security.security_currencyType;
//
//   static String get statusInfo => Security.security_statusInfo;
//
//   static PremiumService? _instance;
//
//   PremiumService._();
//
//   static PremiumService get instance {
//     _instance ??= PremiumService._();
//     return _instance!;
//   }
//
//   bool get isPremium => premiumInfo[Security.security_status] == 1;
//
//   bool get isYearMember => isPremium && premiumInfo[prmType] == 12;
//
//   bool get isMonthMember => isPremium && premiumInfo[prmType] == 2;
//
//   bool get isWeakMember => isPremium && premiumInfo[prmType] == 1;
//
//   int get premiumEndTime => premiumInfo[Security.security_endTime];
//
//   String get premiumFormattedEndTime => DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(premiumInfo[Security.security_endTime]));
//
//   bool get hasFreeImage => isMonthMember || isYearMember || (isPremium && imageLeftCount > 0);
//
//   int get imageLeftCount => isPremium ? (premiumInfo[Security.security_usedInfo]?['1']?[Security.security_leftTimes] ?? 0) : 0;
//
//   set imageLeftCount(int count) => premiumInfo[Security.security_usedInfo]?['1']?[Security.security_leftTimes] = count;
//
//   bool get hasFreeVideo => isMonthMember || isYearMember || (isPremium && videoLeftCount > 0);
//
//   int get videoLeftCount => isPremium ? (premiumInfo[Security.security_usedInfo]?['3']?[Security.security_leftTimes] ?? 0) : 0;
//
//   set videoLeftCount(int count) => premiumInfo[Security.security_usedInfo]?['3']?[Security.security_leftTimes] = count;
//
//   bool get hasFreeAudio => isMonthMember || isYearMember || (isPremium && audioLeftCount > 0);
//
//   int get audioLeftCount => isPremium ? (premiumInfo[Security.security_usedInfo]?['2']?[Security.security_leftTimes] ?? 0) : 0;
//
//   set audioLeftCount(int count) => premiumInfo[Security.security_usedInfo]?['2']?[Security.security_leftTimes] = count;
//
//   int get createGroupLeftCount => isPremium ? (premiumInfo[Security.security_usedInfo]?['12']?[Security.security_leftTimes] ?? 0) : 0;
//
//   set createGroupLeftCount(int count) => premiumInfo[Security.security_usedInfo]?['12']?[Security.security_leftTimes] = count;
//
//   int get createGroupUsedCount => isPremium ? (premiumInfo[Security.security_usedInfo]?['12']?[Security.security_useTimes] ?? 0) : 0;
//
//   int get createOCLeftCount => isPremium ? (premiumInfo[Security.security_usedInfo]?['10']?[Security.security_leftTimes] ?? 0) : 0;
//
//   set createOCLeftCount(int count) => premiumInfo[Security.security_usedInfo]?['10']?[Security.security_leftTimes] = count;
//
//   int get createOCUsedCount => isPremium ? (premiumInfo[Security.security_usedInfo]?['10']?[Security.security_useTimes] ?? 0) : 0;
//
//   int renewalStatus = 0;
//   RxMap premiumInfo = {}.obs;
//
//   void init() {
//     EventCenter.instance.addListener(kEventCenterUserDidLogin, (event){
//       actionAfterLogin();
//     });
//     EventCenter.instance.addListener(kEventCenterUserDidLogout, (event){
//       onLogout();
//     });
//   }
//
//   Future<Map?> queryPremiumCards() async {
//     try {
//       final req = ApiRequest(queryPremiumCardsApi, params: {});
//       final res = await ApiService.instance.sendRequest(req);
//       // todo check rtn
//     } catch (e) {
//       return null;
//     }
//   }
//
//   void actionAfterLogin() {
//     queryMyPremiumInfo();
//   }
//
//   Future refreshMyPremiumInfo(info) async {
//     premiumInfo.value = info;
//     premiumInfo.refresh();
//   }
//
//   Future queryMyPremiumInfo() async {
//     try {
//       final req = ApiRequest(queryMyPremiumInfoApi, params: {});
//       final rsp = await ApiService.instance.sendRequest(req);
//       // todo check rtn
//       if(rsp.isSuccess){
//         premiumInfo.value = rsp.data[Security.security_ownPremium];
//       }
//     } catch (e) {}
//   }
//
//   Future onLogout() async {
//     premiumInfo.value = {};
//     premiumInfo.refresh();
//   }
// }
