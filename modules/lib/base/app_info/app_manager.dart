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
}
