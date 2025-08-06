import 'package:modules/base/crypt/security.dart';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/preferences/preferences.dart';
import 'package:modules/business/chat/chat_voice_manager.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/shared/alert.dart';
import 'package:uuid/uuid.dart';

import '../chat_voice_player.dart';
import './chat_message.dart';
import 'chat_cell.dart';

//### TextMessage
class ChatTextMessage extends ChatMessage {
  String text = '';
  var audioStatus = ChatTextAudioStatus.unlock.obs;

  ChatTextMessage({
    required super.id,
    required super.senderId,
    required super.receiverId,
    required super.date,
    required super.ownerId,
    required super.type,
    required super.uuid,
    required super.info,
    required super.lockInfo,
    required super.nativeId,
  });

  @override
  Map<String, dynamic> toServer() {
    return {...super.toServer(), Security.security_content: text};
  }

  @override
  Map<String, Object?> toDatabase() {
    return {...super.toDatabase(), Security.security_content: text};
  }

  // 修复后的 fromDatabase 构造函数
  ChatTextMessage.fromDatabase(Map<String, Object?> map) : super.fromLocalData(map) {
    text = (map[Security.security_content] as String?) ?? '';
    sessionId = (map[Security.security_sessionId] as String?) ?? '';
    sendState = ChatMessageSendStatus.fromDigit(map[Security.security_sendState] as int? ?? 0).obs;
    bool locked = lockInfo[Security.security_unlock] == 1;
    audioStatus = ChatTextAudioStatus.fromDigit(locked ? ChatTextAudioStatus.ready.digit : 0).obs;
  }

  ChatTextMessage.fromServer(Map map) : super.fromServerData(map) {
    text = map[Security.security_content] ?? '';
    int sessionType = map[Security.security_sessionType] ?? 0;
    sessionId = sessionType == 0 ? (senderId == ownerId ? receiverId : senderId).toString() : (map[Security.security_sessionId] ?? '');
    sendState = ChatMessageSendStatus.fromDigit(0).obs;
    bool locked = map[Security.security_unlock]?[Security.security_unlock] == 1;
    audioStatus = ChatTextAudioStatus.fromDigit(locked ? ChatTextAudioStatus.ready.digit : 0).obs;
  }

  // 改为构造函数
  ChatTextMessage.fromText(this.text, int receiverId)
    : super(
        id: DateTime.now().microsecondsSinceEpoch,
        senderId: AccountService.instance.account.userId,
        receiverId: receiverId,
        date: DateTime.now(),
        ownerId: AccountService.instance.account.userId,
        type: ChatMessageType.text,
        uuid: '',
        info: '',
        lockInfo: {},
        nativeId: (const Uuid().v4()).replaceAll('-', ''),
      ) {
    sendState = ChatMessageSendStatus.sending.obs;
  }

  @override
  String get externalText => text;

  Map<String, dynamic>? _decodedInfo;

  Map<String, dynamic> get decodedInfo {
    _decodedInfo ??= JsonDecoder().convert(info);
    return _decodedInfo!;
  }

  int get unlockPrice => lockInfo[Security.security_cost];

  int get unlockCurrency => lockInfo[Security.security_costType];

  @override
  set info(String value) {
    super.info = value;
    _decodedInfo = null;
  }

  @override
  int get audioDuration => decodedInfo[Security.security_ttsDuration] ?? 0;

  @override
  String get audioUrl => decodedInfo[Security.security_ttsUrl] ?? '';
}

class ChatTextCell extends ChatCell {
  ChatTextCell(ChatTextMessage super.message, {super.key, super.resend, super.onTap, super.unlock, super.reload, super.download});

  ChatTextMessage get textMessage => super.message as ChatTextMessage;

  bool get isMine => textMessage.isMine();

  Widget renderMainView() {
    return Row(
      textDirection: isMine ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Flexible(
          child: GestureDetector(
            onTap: () {
              onTap?.call(message);
            },
            child: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isMine ? Color(0xFFFFF9B4).withValues(alpha: 0.9) : Color(0xFF272533).withValues(alpha: 0.9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                  bottomLeft: Radius.circular(isMine ? 12 : 4),
                  bottomRight: Radius.circular(isMine ? 4 : 12),
                ),
              ),
              child: Text(textMessage.text, style: TextStyle(color: isMine ? Color(0xFF3D3734) : Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            ),
          ),
        ),
        if (isMine) Obx(() => buildSendStatusView()),
        SizedBox(width: 70),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() => Container(padding: EdgeInsets.only(bottom: 8, top: textMessage.focused.value ? 16 : 0), child: renderMainView())),
        Obx(
          () => textMessage.focused.value ? Positioned(child: ChatTextAudioView(message: textMessage, unlock: unlock, download: download)) : SizedBox.shrink(),
        ),
      ],
    );
  }
}

class ChatTextAudioView extends StatelessWidget {
  ChatMessage message;
  final Function(ChatMessage message)? unlock;
  final Function(ChatMessage message)? download;

  ChatTextAudioView({super.key, required this.message, required this.unlock, required this.download});

  ChatTextMessage get textMessage => message as ChatTextMessage;

  Widget buildAudioStatusIcon() {
    ChatTextAudioStatus status = textMessage.audioStatus.value;
    switch (status) {
      case ChatTextAudioStatus.unlock:
        return Image.asset(ImagePath.unlock, width: 16, height: 16);
      case ChatTextAudioStatus.loading:
        return Container(
          padding: EdgeInsets.all(2),
          child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
        );
      case ChatTextAudioStatus.ready:
        return Image.asset(ImagePath.audio_to_speak, width: 16, height: 16);
      case ChatTextAudioStatus.playing:
        return Image.asset(ImagePath.audio_speaking, width: 16, height: 16);
      case ChatTextAudioStatus.pause:
        return Image.asset(ImagePath.audio_to_speak, width: 16, height: 16);
    }
  }

  static String kChatTTSPrompted = Security.security_kChatTTSPrompted;

  bool get prompted => Preferences.instance.getString(kChatTTSPrompted) != null;

  set prompted(bool value) {
    if (value) {
      Preferences.instance.setString(kChatTTSPrompted, '$kChatTTSPrompted:1');
    } else {
      Preferences.instance.remove(kChatTTSPrompted);
    }
  }

  void showUnlockAlertIfNeeded() {
    // 会员解锁
    if (MyAccount.isWkPrem && MyAccount.freeAdoLeftTimes > 0 || MyAccount.isMthPrem || MyAccount.isYrPrem) {
      unlockMessage(1);
      return;
    }

    // 普通解锁
    if (textMessage.unlockPrice > 0 && !prompted) {
      showUnlockAlert();
    } else {
      unlockMessage(0);
    }
  }

  void showUnlockAlert() {
    showConfirmAlert(
      'Unlock Audio',
      'Unlocking will cost ${textMessage.unlockPrice} ${textMessage.unlockCurrency == 1 ? 'Gems' : 'Coins'}',
      onConfirm: () {
        //解锁资源
        unlockMessage(0);
        prompted = true;
      },
    );
  }

  void unlockMessage(int usePrem) async {
    textMessage.audioStatus.value = ChatTextAudioStatus.loading; //解锁中
    bool success = await unlock?.call(message);
    debugPrint('unlockMessage success: $success');
    if (!success) {
      textMessage.audioStatus.value = ChatTextAudioStatus.unlock;
      return;
    }
    if (usePrem == 1) {
      if (MyAccount.isWkPrem) {
        EasyLoading.showToast('Premium Benefits for Audio, used: ${MyAccount.freeAdoUsedTimes},total: ${MyAccount.freeAdoLeftTimes + MyAccount.freeAdoUsedTimes}');
      } else {
        EasyLoading.showToast('Premium Benefits for Audio, unlimited');
      }
    }
  }

  void play() async {
    //1.判断资源是否存在
    String? path = ChatVoiceManager.instance.voicePathForUrl(textMessage.audioUrl);

    if (path == null) {
      //下载
      await download?.call(message);
    }

    ChatVoicePlayer.instance.play(textMessage);
  }

  void continuePlay() {
    textMessage.audioStatus.value = ChatTextAudioStatus.playing;
  }

  void pause() {
    textMessage.audioStatus.value = ChatTextAudioStatus.pause;
  }

  void onTap() {
    ChatTextAudioStatus status = textMessage.audioStatus.value;
    switch (status) {
      case ChatTextAudioStatus.unlock:
        //弹窗
        showUnlockAlertIfNeeded();
        break;
      case ChatTextAudioStatus.loading:
        break;
      case ChatTextAudioStatus.ready:
        play();
        break;
      case ChatTextAudioStatus.playing:
        pause();
        break;
      case ChatTextAudioStatus.pause:
        continuePlay();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          // gradient: MyAccount.isSubscribed?LinearGradient(
          //   colors: [Color(0xFFF6C2D8), Color(0xFFDB80F9), Color(0xFFC07CF7), Color(0xFF6F71F6)],
          //   begin: Alignment.centerLeft,
          //   end: Alignment.centerRight,
          // ):null,
          color:
          // MyAccount.isSubscribed ?null :
          Color(0xFF997B2F),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() => buildAudioStatusIcon()),
            if (textMessage.audioDuration > 0)
              Container(
                margin: EdgeInsets.only(left: 4),
                child: Text('${textMessage.audioDuration}"', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}
