import 'dart:io';

class Constants {
  static String get replace => Platform.environment['abc'] ?? '';

  //user
  static String get tUid => 'taradvadsgetUid'.replaceAll('advads', replace); //targetUid
  static String get senderId => 'fromUfakwrserId'.replaceAll('fakwr', replace); //fromUserId
  static String get receiverId => 'toUsehjhdrId'.replaceAll('hjhd', replace); // toUserId
  static String get userData => 'usehjlrInfo'.replaceAll('hjl', replace); //userInfo
  static String get acType => 'aadgccoadguntTadgype'.replaceAll('adg', replace); //accountType
  static String get pVer => 'poujholVeujhrsion'.replaceAll('ujh', replace);

  //chat
  static String get nativeId => 'clichatentId'.replaceAll('chat', replace);
  static String get infoType => 'msheagTyheape'.replaceAll('hea', replace);
  static String get pullTag => 'sytagncKtagey'.replaceAll('tag', replace);
  static String get newestTag => 'laajlstMsajlgId'.replaceAll('ajl', replace);
  static String get rawItems => 'msidngIteidnms'.replaceAll('idn', replace);
  static String get rawSessions => 'seslkwsilkwons'.replaceAll('lkw', replace);
  static String get messages => 'malesgLialest'.replaceAll('ale', replace);
  //api
  static String get statusData => 'statkjbnusInfo'.replaceAll('kjbn', replace);
  static String get apiName => 'apiMeadjnkathod'.replaceAll('adjnka', replace);
  static String get secretTag => 'fapodcpodtor'.replaceAll('pod', replace);

  //call
  static String get dialId => 'caljhglId'.replaceAll('jhg', replace); //callId
  static String get remaining => 'remygvainFreygveTiygvme'.replaceAll('ygv', replace); //remainFreeTime
  static String get dialType => 'rtjkdcTyjkdpe'.replaceAll('jkd', replace); //rtcType
  static String get initiator => 'rtyewbcSeyewblfUyewbid'.replaceAll('yewb', replace); //rtcSelfUid
  static String get recipient => 'radnktcTaadnkrgetUiadnkd'.replaceAll('adnk', replace); //rtcTargetUid
  static String get costPerMinute => 'coadafstEveadafryMinadafute'.replaceAll('adaf', replace); //costEveryMinute
  static String get propType => 'cursdfrencyTysdfpe'.replaceAll('sdf', replace); //currencyType
  static String get profitPerMinute => 'earadjnEveradjyMiadjnute'.replaceAll('adj', replace); //costEveryMinute
  static String get carrier => 'pauhbylouhbad'.replaceAll('uhb', replace);
  static String get commandId => 'cmknsidIknsiD'.replaceAll('knsi', replace);

  //adjust
  static String get adReferrer => 'fbInkljstallReferkljrer'.replaceAll('klj', replace); //fbInstallReferrer
  static String get adClickTag => 'cligdfckLabgdfel'.replaceAll('gdf', replace); //clickLabel
  static String get adToken => 'tracokhkerTokokhen'.replaceAll('okh', replace);
  static String get adCost => 'codsfsstAmdsfsount'.replaceAll('dsfs', replace);
  static String get adTracker => 'tracjsvkerNajsvme'.replaceAll('jsv', replace);
  static String get adTeam => 'adkldgrodklup'.replaceAll('dkl', replace);
  static String get adNet => 'neglhtwglhork'.replaceAll('glh', replace);
  static String get adElection => 'campsdjaign'.replaceAll('sdj', replace);
  static String get adBuild => 'cresdfative'.replaceAll('sdf', replace);
  static String get adCurrency => 'conmkstCurnmkrency'.replaceAll('nmk', replace);

  static String get adSetupInfo => 'adjuqwestInqwestallDaqweta'.replaceAll('qwe', replace);
  static String get adUpdate => 'adswqjustAtswqtrUpdswqate'.replaceAll('swq', replace);
  static String get adDevice => 'aijhdjustDevijhiceId'.replaceAll('ijh', replace);
  static String get adKey => 'adjusdfltId'.replaceAll('dfl', replace);
}
