import 'package:modules/base/crypt/security.dart';
import 'dart:convert';

import 'package:modules/base/crypt/constants.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tencent_trtc_cloud/trtc_cloud.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_def.dart';
import 'package:tencent_trtc_cloud/trtc_cloud_listener.dart';

enum RoomEventType { onEnterRoom, onRemoteUserEnterRoom, onConnectionLost, onConnectionRecovery, onRemoteUserLeaveRoom }

class AVEngine {
  //生成单利
  AVEngine._internal();
  static final AVEngine _instance = AVEngine._internal();
  factory AVEngine() => _instance;
  static AVEngine get instance => _instance;

  late TRTCCloud? cloud;
  late int appId;
  late String token;
  late String _userSig;
  late String _userId;

  Function(Map msg)? onReceiveCustomEvent;
  Function(RoomEventType type, dynamic data)? onJoinChannel;

  Future<void> init({required String appId, required String token}) async {
    //初始化
    cloud = await TRTCCloud.sharedInstance();
    this.appId = int.parse(appId);
    this.token = token;

    enableCamera(false);
    registerListener();
  }

  void enableCamera(bool enable) {
    cloud?.muteLocalVideo(!enable);
  }

  void enableMic(bool enable) {
    if (enable) {
      cloud?.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
    } else {
      cloud?.stopLocalAudio();
    }
  }

  void registerListener() {
    cloud?.registerListener(handleCloudEvent);
  }

  void handleCloudEvent(type, params) async {
    // debugPrint('handleCloudEvent: $type, $params');
    switch (type) {
      case TRTCCloudListener.onEnterRoom:
        int result = params;
        if (result > 0) {
          onJoinChannel?.call(RoomEventType.onEnterRoom, params);
        }
        break;

      case TRTCCloudListener.onUserVideoAvailable:
        if (params[Security.security_available]) {
          addRemoteViewStreamID(params[Security.security_userId]);
        } else {
          deleteRemoteViewStreamID(params[Security.security_userId]);
        }
        break;

      case TRTCCloudListener.onError:
        break;
      case TRTCCloudListener.onWarning:
        break;
      case TRTCCloudListener.onSwitchRole:
        break;
      case TRTCCloudListener.onRemoteUserEnterRoom:
        onJoinChannel?.call(RoomEventType.onRemoteUserEnterRoom, params);
        break;
      case TRTCCloudListener.onRemoteUserLeaveRoom:
        onJoinChannel?.call(RoomEventType.onRemoteUserLeaveRoom, params);
        break;
      case TRTCCloudListener.onConnectOtherRoom:
        break;
      case TRTCCloudListener.onDisConnectOtherRoom:
        break;
      case TRTCCloudListener.onUserSubStreamAvailable:
        break;
      case TRTCCloudListener.onUserAudioAvailable:
        break;
      case TRTCCloudListener.onFirstVideoFrame:
        break;
      case TRTCCloudListener.onFirstAudioFrame:
        break;
      case TRTCCloudListener.onNetworkQuality:
        break;
      case TRTCCloudListener.onStatistics:
        break;
      case TRTCCloudListener.onConnectionLost:
        onJoinChannel?.call(RoomEventType.onConnectionLost, params);
        break;
      case TRTCCloudListener.onTryToReconnect:
        break;
      case TRTCCloudListener.onConnectionRecovery:
        onJoinChannel?.call(RoomEventType.onConnectionRecovery, params);
        break;
      case TRTCCloudListener.onCameraDidReady:
        break;
      case TRTCCloudListener.onMicDidReady:
        break;
      case TRTCCloudListener.onDeviceChange:
        break;
      case TRTCCloudListener.onTestMicVolume:
        break;
      case TRTCCloudListener.onTestSpeakerVolume:
        break;
      case TRTCCloudListener.onStartPublishMediaStream:
        break;
      case TRTCCloudListener.onRecvCustomCmdMsg:
        onReceiveCustomEvent?.call(params);
        break;
      default:
        break;
    }
  }

  void addRemoteViewStreamID(String streamID) async {
    // L.i("[AVKit] addRemoteViewStreamID, streamID: $streamID");
    // VideoTalkViewObject? viewObject;
    // if (_mediaType == MediaType.video) {
    //   viewObject = await createVideoObject(false, streamID, (viewId) {
    //     startPlayingStream(streamID, viewObject!.viewID);
    //   });
    // }

    // onAddStream?.call(streamID, viewObject);
  }

  void deleteRemoteViewStreamID(String streamID) async {
    stopPlayingStream(streamID);

    // onDeleteStream?.call(streamID);
  }

  void clearEventCallback() {
    cloud?.unRegisterListener(handleCloudEvent);
  }

  Future<void> destroy() async {
    clearEventCallback();
    await TRTCCloud.destroySharedInstance();
  }

  Future<void> joinRoom(String roomId, String userId) async {
    // L.i("[AVKit][AVEngineTrtc] joinRoom, roomId: $roomId, mediaType: $_mediaType, userId: $strUid");

    _userId = userId;
    TRTCParams params = TRTCParams();
    params.sdkAppId = appId;
    params.strRoomId = roomId;
    params.userId = _userId;
    params.userSig = token;
    cloud?.enterRoom(params, TRTCCloudDef.TRTC_APP_SCENE_AUDIOCALL);

    // if (false) {
    //   TRTCVideoEncParam encParams = TRTCVideoEncParam();
    //   encParams.videoResolution = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_960_540;
    //   encParams.videoFps = 15;
    //   encParams.videoBitrate = 1200;
    //   encParams.videoResolutionMode = TRTCCloudDef.TRTC_VIDEO_RESOLUTION_MODE_PORTRAIT;
    //   cloud?.setVideoEncoderParam(encParams);
    // }

    cloud?.getDeviceManager().setSystemVolumeType(TRTCCloudDef.TRTCSystemVolumeTypeMedia);

    // setupBeauty();
  }

  void enableSpeaker(bool isEnable) {
    int type = isEnable ? TRTCCloudDef.TRTC_AUDIO_ROUTE_SPEAKER : TRTCCloudDef.TRTC_AUDIO_ROUTE_EARPIECE;
    cloud?.getDeviceManager().setAudioRoute(type);
  }

  Future<void> startPreview(String streamID) async {
    // L.i("[AVKit] startPreview, streamID: $streamID");
    // if (_mediaType == MediaType.video) {
    //   await [Permission.microphone, Permission.camera].request();
    //
    //   await _trtcCloud?.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
    //   VideoTalkViewObject viewObject = await createVideoObject(true, streamID, (viewId) {
    //     _trtcCloud?.startLocalPreview(true, viewId);
    //   });
    //   return viewObject;
    // }

    await [Permission.microphone].request();
    await cloud?.startLocalAudio(TRTCCloudDef.TRTC_AUDIO_QUALITY_SPEECH);
  }

  Future<void> stopPlayingStream(String streamID) async {
    // await cloud?.stopRemoteView(streamID, TRTCCloudDef.TRTC_VIDEO_STREAM_TYPE_BIG);
  }

  Future<void> exitRoom() async {
    await cloud?.stopLocalAudio();
    await cloud?.stopLocalPreview();

    await cloud?.exitRoom();

    await TRTCCloud.destroySharedInstance();
  }

  static int breakNum = 0;
  void interruptAI(int receiverId) {
    Map data = {
      Security.security_type: 20001,
      Security.security_sender: _userId,
      Security.security_receiver: ['$receiverId'],
      Constants.carrier: {Security.security_id: '$_userId-$receiverId-${breakNum++}', Security.security_timestamp: DateTime.now().millisecondsSinceEpoch ~/ 1000},
    };
    try {
      String encodedData = jsonEncode(data);
      cloud?.sendCustomCmdMsg(2, encodedData, false, false);
    } catch (e) {}
  }
}
