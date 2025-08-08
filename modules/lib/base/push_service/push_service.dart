import 'package:modules/base/crypt/other.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:modules/base/crypt/constants.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../api_service/api_config.dart';
import '../api_service/api_service.dart';
import '../crypt/crypt.dart';

String kEventCenterKickOff = Security.security_kEventCenterKickOff;
String kEventCenterDidPushNewMessages = Security.security_kEventCenterDidPushNewMessages;

enum PushServiceState { disconnected, connecting, connected }

class PushId {
  static int get kPushBaseId => Platform.environment[Security.security_TEMP] == Security.security_Lumina ? 0 : (50 * 2);
  static int get kHeartbeatId => kPushBaseId + 8;

  static int get kHeartbeatType => kPushBaseId + 9;

  static int get kLoginResultId => kPushBaseId + 1;

  static int get kLogoutId => kPushBaseId + 3;

  static int get kKickOffId => kPushBaseId + (100 + 3);

  static int get kChatMessageId => kPushBaseId + (202 - 1);

  static int get kBusinessStartId => Platform.environment[Security.security_TEMP] == Security.security_Lumina ? 0 : (100 * 1000);
  static int get kBatchMessageKey => kBusinessStartId + 5;
}

class PushKey {
  static String get noticeId => Security.security_iUabcri.replaceAll(Security.security_abc, Platform.environment[Security.security_TEMP] ?? '');

  static String get noticeContent => Security.security_bohjkdy.replaceAll(Security.security_hjk, Platform.environment[Security.security_TEMP] ?? '');

  static String get noticeUri => noticeId.toLowerCase().substring(1);

  static String get noticeKey => Security.security_jsorghnMsg.replaceAll(Security.security_rgh, Platform.environment[Security.security_TEMP] ?? '');
}

class PushObject {
  final int type;
  final Map data;

  PushObject(this.type, this.data);

  @override
  String toString() {
    return 'type: $type, data: $data';
  }
}

class PushService {
  //生成单利
  static final PushService _instance = PushService._internal();
  factory PushService() {
    return _instance;
  }
  PushService._internal();
  static PushService get instance => _instance;

  final String confirm = Security.security_confirm;
  WebSocketChannel? _channel;

  bool get loggedIn => _secretKey != '0';
  bool isForeground = true;
  PushServiceState state = PushServiceState.disconnected;

  int reconnectCount = 0;

  //心跳包定时器
  Timer? _timer;

  //通讯密钥
  String _secretKey = '0';
  set secretKey(String value) {
    debugPrint('secretKey value is $value');
    if (_secretKey == value) return;
    _secretKey = value;
    if (_secretKey == '0') {
      disconnect();
    } else {
      reconnect();
    }
  }

  String get _secretTag => _secretKey.padRight(16, '0');

  //初始化
  void init() {
    //监听app生命周期
    SystemChannels.lifecycle.setMessageHandler((message) async {
      isForeground = (message?.endsWith(Other.security__resumed) ?? false) || (message?.endsWith(Other.security__active) ?? false);
      if (isForeground && state == PushServiceState.disconnected) {
        //重新连接
        connect();
      }
      return Future.value(message);
    });

    //连接
    connect();
  }

  void connect() {
    //连接
    if (state != PushServiceState.disconnected) return;

    if (!loggedIn) {
      debugPrint(' [PushService] secretKey is $_secretKey');
      return;
    }
    final uri = Uri.parse(ApiConfig.wsUrl);
    try {
      state = PushServiceState.connecting;
      _channel = WebSocketChannel.connect(uri);
      _channel?.stream.listen(didReceiveEvent, onError: onConnectError, onDone: onConnectDone);
    } catch (e) {
      debugPrint('连接失败：$e');
      reconnect();
    }
    _channel?.sink.add(confirm);
  }

  reconnect() {
    //重新连接
    if (!isForeground) return;
    reconnectCount++;
    int delay = 10;
    if (reconnectCount > 10) {
      delay = 60;
      reconnectCount = 0;
    }
    Future.delayed(Duration(seconds: delay), () {
      connect();
    });
  }

  void didReceiveEvent(event) {
    if (event == confirm) {
      onConnectSuccess();
      return;
    }

    parseData(event);
  }

  void parseData(dynamic data) {
    // 解析数据
    if (data is! Uint8List) return;
    Uint8List bytes = data;
    Map event = decryptBytes(bytes);

    String uriKey = PushKey.noticeUri;

    if (event[uriKey] == null) return;

    var eventId = (event[uriKey] ?? 0.0).toInt();

    //这里应该由业务注册uri，在业务中处理消息。后续优化
    if (eventId == PushId.kLoginResultId) {
      debugPrint('[PushService] login success');
      startTimer();
    } else if (eventId == PushId.kLogoutId) {
      debugPrint('[PushService] logout success');
    } else if (eventId == PushId.kHeartbeatType) {
      debugPrint('[PushService] heartbeat');
    } else if (eventId == PushId.kKickOffId) {
      debugPrint('[PushService] kick off');
      EventCenter.instance.sendEvent(kEventCenterKickOff, null);
    } else if (eventId == PushId.kChatMessageId) {
      debugPrint('[PushService] received chat message');
      try {
        String bodyStr = event[PushKey.noticeContent];
        Map body = const JsonDecoder().convert(bodyStr);
        Map map = const JsonDecoder().convert(body[PushKey.noticeKey]);
        PushObject object = PushObject(body[PushKey.noticeId], map);
        debugPrint('[PushService] PushObject:${object.toString()}');
        EventCenter.instance.sendEvent(kEventCenterDidPushNewMessages, {Security.security_userInfo: object});
      } catch (e) {
        debugPrint('[PushService] decode error ${e.toString()}');
      }
    }
  }

  void onConnectSuccess() {
    state = PushServiceState.connected;
    confirmConnection();
  }

  void confirmConnection() {
    sendData({}, 100);
  }

  void sendData(Map data, int type) async {
    // debugPrint('[PushService] sendData, data type: $type, data: $data');

    try {
      Uint8List bytes = utf8.encode(encryptData(data, type));
      _channel?.sink.add(bytes);
    } catch (e) {
      debugPrint('[PushService], sendData error ${e.toString()}');
    }
  }

  onConnectError(error) {
    debugPrint('连接错误：$error');
    disconnect();
    reconnect();
  }

  onConnectDone() {
    debugPrint('连接关闭');
    disconnect();
    reconnect();
  }

  disconnect() {
    //断开连接
    stopTimer();
    state = PushServiceState.disconnected;
    _channel?.sink.close();
    _channel = null;
  }

  //#----心跳包----#
  startTimer() {
    stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 30), (timer) {
      onTimeout();
    });
  }

  onTimeout() {
    if (_channel == null) {
      reconnect();
    } else {
      sendHeartbeatPackage();
    }
  }

  sendHeartbeatPackage() {
    Map map = {
      Security.security_yyid.replaceAll('i', ''): 0,
      Security.security_iInAjhgpp.replaceAll(Security.security_jhg, ''): isForeground ? 1 : 0,
      Security.security_status: '1',
    };
    sendData(map, 108);
  }

  stopTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  //#----加密解密----#
  String encryptData(Map data, int type) {
    Map base = ApiService.instance.base();
    base[Security.security_guid] = base[Security.security_did];
    base[Security.security_channel] = base[Security.security_app];
    base[Security.security_versionName] = base[Security.security_ver];

    data[Security.security_status] = 0;
    data[Security.security_tId] = base;

    Map origin = {Security.security_id: 0, Security.security_appId: 0, Security.security_uri: type, Security.security_type: type, Security.security_body: data};

    String str = Encryptor.encryptMap(origin, secretKey: _secretTag);

    Map packMap = {};
    packMap[Constants.secretTag] = _secretTag;
    packMap[Security.security_type] = type;
    packMap[Security.security_pack] = str;

    return jsonEncode(packMap);
  }

  Map decryptBytes(Uint8List bytes) {
    Map result = {};
    try {
      String str = utf8.decode(bytes);
      result = decryptData(str);
    } catch (e) {
      debugPrint('[PushService] decryptBytes error ${e.toString()}');
    }
    return result;
  }

  Map decryptData(String message) {
    String str = Decryptor.decrypt(message, secretKey: _secretTag);
    return const JsonDecoder().convert(str);
  }
}
