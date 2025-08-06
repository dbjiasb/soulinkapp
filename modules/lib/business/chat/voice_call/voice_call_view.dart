import 'package:modules/base/crypt/security.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_service_export.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/constants.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/shared/formatters/date_formatter.dart';
import 'package:svgaplayer_3/svgaplayer_flutter.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../chat_session.dart';
import './av_service.dart';
import './call_manager.dart';

enum CallStatus { connecting, userSpeaking, aiThinking, aiSpeaking }

class CallInfo {
  Map<String, dynamic> data;
  CallInfo(this.data);
  int get callId => data[Constants.dialId] ?? 0;
  String get token => data[Security.security_token] ?? '';
  int get remainFreeTime => data[Constants.remaining] ?? 0;
  int get rtcType => data[Constants.dialType] ?? 0;
  String get appId => data[Security.security_appId] ?? '';
  String get rtcSelfUid => data[Constants.initiator] ?? '';
  String get rtcTargetUid => data[Constants.recipient] ?? '';
  String get roomId => data[Security.security_roomId] ?? '';
  int get ai => data[Security.security_ai] ?? 0;
  int get costEveryMinute => data[Constants.costPerMinute] ?? 0;
  int get currencyType => data[Constants.propType] ?? 0;
  double get earnEveryMinute => data[Constants.profitPerMinute] ?? 0;
  int get anchor => data[Security.security_anchor] ?? 0;
}

class VoiceCallView extends StatelessWidget {
  VoiceCallView({super.key});

  VoiceCallViewController viewController = Get.put(VoiceCallViewController());

  String get statusText {
    if (viewController.muted.value) return 'You have muted';
    CallStatus status = viewController.callStatus.value;
    if (status == CallStatus.connecting) return 'Connecting...';
    if (status == CallStatus.aiThinking) return 'I\'m thinking...';
    if (status == CallStatus.aiSpeaking) return 'Interrupt AI';
    if (status == CallStatus.userSpeaking) return 'I\'am listening...';
    return Security.security_nothing;
  }

  Widget callStatusView() {
    switch (viewController.callStatus.value) {
      case CallStatus.connecting:
        return Column(
          children: [SizedBox(height: 184), Text('Connecting...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFABABAD)))],
        );
      case CallStatus.aiThinking:
        return Column(
          children: [SizedBox(height: 184), Text('I\'m thinking...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFABABAD)))],
        );
      case CallStatus.aiSpeaking:
        return Column(
          children: [
            Image.asset(ImagePath.triangle_arrow, width: 24, height: 12),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 43),
              child: Container(
                height: 96,
                width: double.infinity,
                decoration: BoxDecoration(
                  //左上角和右上角圆角12
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x40000000), Color(0x00000000)]),
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(8),
                  child: Text(viewController.speechContent.value, style: TextStyle(color: Color(0xB3FFFFFF), fontSize: 13, fontWeight: FontWeight.normal)),
                ),
              ),
            ),
            SizedBox(height: 40),
            GestureDetector(
              onTap: viewController.interruptAI,
              child: Image.asset(ImagePath.interrupt_talk, width: 32, height: 32),
            ),
            SizedBox(height: 4),
            Text('Interrupt AI', style: TextStyle(fontSize: 14, color: Color(0xFFABABAD), fontWeight: FontWeight.w500)),
          ],
        );
      case CallStatus.userSpeaking:
        return Column(
          children: [
            SizedBox(height: 144),
            SizedBox(height: 24, child: SVGASimpleImage(assetsName: ImagePath.speaking)),
            SizedBox(height: 16),
            Text('I\'am listening...', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFFABABAD))),
          ],
        );
    }
  }

  Widget _buildBackgroundView() {
    if (viewController.session.backgroundUrl.value.isNotEmpty) {
      return CachedNetworkImage(imageUrl: viewController.session.backgroundUrl.value, fit: BoxFit.cover);
    } else {
      return SizedBox.shrink();
    }
  }

  Widget buildCostWidget(bool hidden) {
    return Container(
      margin: EdgeInsets.only(right: hidden ? 16 : 0, left: hidden ? 0 : 16),
      child: Text(
        '${viewController.callInfo?.costEveryMinute ?? 30} ${viewController.callInfo?.currencyType == 1 ? 'Gems' : 'Coins'} / Min',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: hidden ? Colors.transparent : Colors.white,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 使用 BackdropFilter 为 CachedNetworkImage 添加高斯模糊效果
          // 先放置原始的背景图
          Obx(() => _buildBackgroundView()),
          // 再放置带有模糊效果的层
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0), // 调整模糊程度
            child: Container(
              color: Colors.transparent, // 确保容器透明
            ),
          ),

          SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(0, 8, 0, 56),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildCostWidget(false),
                      Column(
                        children: [
                          Text('Call Duration', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white)),
                          Obx(
                            () => Text(
                              DateFormatter.formatSeconds(viewController.duration.value),
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      buildCostWidget(true),
                    ],
                  ),
                  Column(
                    //设置主轴从下往上
                    // mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 124,
                        height: 124,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(image: NetworkImage(viewController.session.avatar), fit: BoxFit.cover),
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(viewController.session.name, style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                      SizedBox(height: 12),
                      Obx(() => callStatusView()),
                      SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: viewController.onCallCancel,
                            child: Image.asset(ImagePath.hang_up, width: 64, height: 64),
                          ),
                          SizedBox(width: 60),
                          GestureDetector(
                            onTap: () {
                              viewController.mute(!viewController.muted.value);
                            },
                            child: Obx(
                              () => !viewController.muted.value
                                  ?Image.asset(ImagePath.open_mic, width: 64, height: 64):
                                  Container(
                                    height: 64,
                                    width: 64,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xff000000).withValues(alpha: 0.2)
                                    ),
                                    child: Icon(Icons.mic_off_rounded,size: 32,),
                                  )
                            )
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VoiceCallViewController extends GetxController {
  final ChatSession session = ChatSession.fromRouter(jsonDecode(Get.arguments[Security.security_session]));
  CallInfo? callInfo;
  bool isEnd = false;
  bool isEngineCreated = false;
  Timer? timer;

  var duration = 0.obs;
  var callStatus = CallStatus.connecting.obs;
  var muted = false.obs;
  var speechContent = ''.obs;

  int get accountId => AccountService.instance.account.userId;
  String get streamId => '${callInfo?.callId ?? ''}-$accountId';
  @override
  void onInit() {
    super.onInit();
    WakelockPlus.enable();
  }

  @override
  void onReady() {
    super.onReady();
    dial();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  void mute(bool mute) {
    muted.value = mute;
    enableMic(!mute);
  }

  void onCallCancel() {
    disconnect();
  }

  void dial() async {
    ApiResponse response = await CallManager.instance.dial(userId: int.parse(session.id));

    int callId = response.data[Constants.dialId] ?? 0;
    String appId = response.data[Security.security_appId] ?? '';

    if (!response.isSuccess || callId == 0 || appId.isEmpty) {
      close();
      EasyLoading.showError(response.description);
      return;
    }

    if (isClosed) {
      CallManager.instance.cancel(callId: callId);
      return;
    }

    callInfo = CallInfo(response.data as Map<String, dynamic>);

    //创建引擎
    await createEngine();
    //开始连接
    connect();
  }

  void close() {
    WakelockPlus.disable();
    stopTimer();

    if (isEngineCreated) {
      AVService.instance.engine.stopPlayingStream(streamId);
      AVService.instance.engine.exitRoom();
      AVService.instance.engine.destroy();
      isEngineCreated = false;
    }

    if (isClosed || isEnd) return;
    isEnd = true;
    Get.back();
  }

  //创建引擎
  Future<void> createEngine() async {
    if (isEngineCreated) return;
    //初始化
    await AVService.instance.init(appId: callInfo!.appId, token: callInfo!.token);
    AVService.instance.engine.onReceiveCustomEvent = (data) {
      onReceiveCustomEvent(data);
    };
    isEngineCreated = true;
  }

  onReceiveCustomEvent(Map data) {
    if (data[Constants.commandId] == 1) {
      String json = data[Security.security_message];
      try {
        handleCustomEvent(jsonDecode(json));
      } catch (e) {
        debugPrint('onReceiveCustomEvent error: $e');
      }
    }
  }

  void handleCustomEvent(Map event) {
    int eventId = event[Security.security_type] ?? 0;
    switch (eventId) {
      case 10003:
        {
          callStatus.value = CallStatus.userSpeaking;
          startTimer();
          break;
        }
      case 10000: //字幕
        {
          String sender = event[Security.security_sender];
          String text = event[Constants.carrier]?[Security.security_text] ?? '';
          bool isEnd = event[Constants.carrier]?[Security.security_end] ?? false;
          // String round = event[Constants.carrier]?['roundid'] ?? '';
          // int? startMs = event[Constants.carrier]?['start_time_ms'] ?? -1;
          // String target = '';

          if (sender == accountId.toString()) {
            if (isEnd) {
              //结束
              callStatus.value = CallStatus.aiThinking;
            } else {
              //拉取消息
            }
          } else {
            speechContent.value = text;
          }

          break;
        }

      case 10001:
        {
          int? state = event[Constants.carrier][Security.security_state] ?? 0;
          // int? timestamp = event[Constants.carrier][Security.security_timestamp] ?? 0;
          switch (state) {
            case 1: // 聆听中
              /// 在短时间内拨打下一个电话的时候没有回调ready导致没有计时，这里判断一下开启计时
              if (callStatus.value == CallStatus.connecting) startTimer();
              callStatus.value = CallStatus.userSpeaking;
              break;
            case 2: // 思考中
              callStatus.value = CallStatus.aiThinking;
              break;
            case 3: // 说话中
              callStatus.value = CallStatus.aiSpeaking;

              break;
            case 4: // 被打断
              callStatus.value = CallStatus.userSpeaking;
              break;
            default:
              break;
          }
          break;
        }

      default:
        break;
    }
  }

  void connect() async {
    //开始连接
    // await createEngine();

    addJoinRoomListener();
    String userId = callInfo?.rtcSelfUid ?? '';
    await AVService.instance.engine.joinRoom(callInfo?.roomId ?? '', userId);
    onSpeakerAction(true);
    startPreview();
  }

  disconnect() async {
    if (callInfo?.callId == null || callInfo?.callId == 0) {
      close();
      return;
    }

    if (callStatus.value == CallStatus.connecting) {
      CallManager.instance.cancel(callId: callInfo!.callId);
      close();
      return;
    } else {
      CallManager.instance.hangup(callId: callInfo!.callId);
    }

    close();
  }

  Future<void> addJoinRoomListener() async {
    AVService.instance.engine.onJoinChannel = (type, params) {
      debugPrint('onJoinChannel: $type, $params');
    };
  }

  void onSpeakerAction(bool isSpeaker) {
    AVService.instance.engine.enableSpeaker(isSpeaker);
  }

  Future<void> startPreview() async {
    await AVService.instance.engine.startPreview(streamId);
  }

  void interruptAI() async {
    AVService.instance.engine.interruptAI(int.parse(callInfo?.rtcTargetUid ?? '0'));
  }

  void enableMic(bool enable) {
    AVService.instance.engine.enableMic(enable);
  }

  //#Timer
  void startTimer() {
    debugPrint('startTimer');
    if (timer != null) return;
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      onTimeout(timer);
    });
  }

  void onTimeout(Timer timer) {
    debugPrint('onTimeout');
    duration.value++;
  }

  void stopTimer() {
    debugPrint('stopTimer');
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
  }
}
