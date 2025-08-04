import 'dart:io';

class Constants {
  static String get replace => Platform.environment['abc'] ?? '';

  //user
  static String get tUid => 'targetUid'; //targetUid
  static String get senderId => 'fromUserId'; //fromUserId
  static String get receiverId => 'toUserId'; // toUserId
  static String get userData => 'userInfo'; //userInfo
  static String get acType => 'accountType'; //accountType
  static String get pVer => 'poolVersion';

  //chat
  static String get nativeId => 'clientId';
  static String get infoType => 'msgType';
  static String get pullTag => 'syncKey';
  static String get newestTag => 'lastMsgId';
  static String get rawItems => 'msgItems';
  static String get rawSessions => 'sessions';
  static String get messages => 'msgList';
  //api
  static String get statusData => 'statusInfo';
  static String get apiName => 'apiMethod';
  static String get secretTag => 'factor';

  //call
  static String get dialId => 'callId'; //callId
  static String get remaining => 'remainFreeTime'; //remainFreeTime
  static String get dialType => 'rtcType'; //rtcType
  static String get initiator => 'rtcSelfUid'; //rtcSelfUid
  static String get recipient => 'rtcTargetUid'; //rtcTargetUid
  static String get costPerMinute => 'costEveryMinute'; //costEveryMinute
  static String get propType => 'currencyType'; //currencyType
  static String get profitPerMinute => 'earnEveryMinute'; //costEveryMinute
  static String get carrier => 'payload';
  static String get commandId => 'cmdID';

  //adjust
  static String get adReferrer => 'fbInstallReferrer'; //fbInstallReferrer
  static String get adClickTag => 'clickLabel'; //clickLabel
  static String get adToken => 'trackerToken';
  static String get adCost => 'costAmount';
  static String get adTracker => 'trackerName';
  static String get adTeam => 'adgroup';
  static String get adNet => 'network';
  static String get adElection => 'campaign';
  static String get adBuild => 'creative';
  static String get adCurrency => 'costCurrency';

  static String get adSetupInfo => 'adjustInstallData';
  static String get adUpdate => 'adjustAttrUpdate';
  static String get adDevice => 'adjustDeviceId';
  static String get adKey => 'adjustId';
}
