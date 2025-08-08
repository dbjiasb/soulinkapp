import 'package:package_info_plus/package_info_plus.dart';

class AppManager {
  //生成单利
  static final AppManager _instance = AppManager._internal();

  factory AppManager() {
    return _instance;
  }

  AppManager._internal();

  static AppManager get instance => _instance;

  late final PackageInfo packageInfo;

  Future<void> init() async {
    packageInfo = await PackageInfo.fromPlatform();
  }

  String get appVersion => packageInfo.version;

  static const cdn = 'cdn.heartink.online';

  String get createOcHtml => 'https://$cdn/soulink/createoc.html';

  String get privacyHtml => 'https://$cdn/soulink/soulink_privacy.html';

  String get termsHtml => 'https://$cdn/soulink/soulink_terms_of_service.html';
}
