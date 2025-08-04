import 'av_engine.dart';

class AVService {
  static final AVService _instance = AVService._internal();
  factory AVService() {
    return _instance;
  }
  AVService._internal();
  static AVService get instance => _instance;

  AVEngine get engine => AVEngine.instance;

  Future<void> init({required String appId, required String token}) async {
    return await engine.init(appId: appId, token: token);
  }

  void dealloc() {
    engine.destroy();
  }
}
