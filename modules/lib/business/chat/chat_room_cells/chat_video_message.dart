import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/preferences/preferences.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/shared/alert.dart';
import 'package:modules/shared/app_theme.dart';

import './chat_cell.dart';
import 'chat_message.dart';

class ChatVideoMessage extends ChatMessage {
  ChatVideoMessage({
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

  ChatVideoMessage.fromDatabase(Map<String, Object?> map) : super.fromLocalData(map);

  ChatVideoMessage.fromServer(Map map) : super.fromServerData(map) {}

  Map<String, dynamic>? _decodedMap;
  Map<String, dynamic> get decodedMap {
    _decodedMap ??= jsonDecode(info);
    return _decodedMap ?? {};
  }

  String get coverUrl => decodedMap['coverUrl'] ?? '';
  String get videoUrl => decodedMap['url'] ?? '';
  bool get prepared => decodedMap['prepared'] == 1;

  String get thumbnailBase64 {
    return decodedMap['base64'] ?? '';
  }

  bool get locked => lockInfo['unlock'] == 1;
  int get unlockPrice => lockInfo['cost'] ?? 0;
  int get currencyType => lockInfo['costType'] ?? 0;

  bool get canReload => locked && renewInfo['reload'] == 1;

  int get reloadPrice => renewInfo['cost'] ?? 0;
  int get reloadCurrencyType => renewInfo['costType'] ?? 0;
}

class ChatVideoCell extends ChatCell {
  ChatVideoCell(super.message, {super.unlock});

  ChatVideoMessage get videoMessage => message as ChatVideoMessage;
  bool get isInChat => type == ChatCellType.chat;
  Widget renderPlayButton() {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routers.videoPlayer.name, arguments: {'videoUrl': videoMessage.videoUrl});
      },
      child: Center(
        child: Container(
          padding: EdgeInsets.all(isInChat ? 16 : 8),
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.circular(50)),
          child: const Icon(Icons.play_arrow, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  Widget buildVideoView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (videoMessage.prepared && videoMessage.locked)
            Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(imageUrl: videoMessage.coverUrl, fit: BoxFit.cover),
                //生成一个播放按钮
                renderPlayButton(),
              ],
            )
          else
            renderImageMask(),
        ],
      ),
    );
  }

  Widget buildChatCell() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        children: [
          Row(children: [SizedBox(width: 172, height: 256, child: buildVideoView())]),
          renderReloadViewIfNeeded(),
        ],
      ),
    );
  }

  Widget buildVideoCell() {
    return AspectRatio(aspectRatio: 109 / 168, child: buildVideoView());
  }

  @override
  Widget build(BuildContext context) {
    return type == ChatCellType.chat ? buildChatCell() : buildVideoCell();
  }

  static const kChatVideoUnlockPromptKey = 'kChatVideoUnlockPromptKey';

  bool get prompted => Preferences.instance.getString(kChatVideoUnlockPromptKey) != null;
  set prompted(bool value) {
    if (value) {
      Preferences.instance.setString(kChatVideoUnlockPromptKey, '$kChatVideoUnlockPromptKey:1');
    } else {
      Preferences.instance.remove(kChatVideoUnlockPromptKey);
    }
  }

  void showUnlockDialogIfNeeded() {
    // 会员解锁
    if (MyAccount.isWkPrem && MyAccount.freeVdoLeftTimes > 0 || MyAccount.isMthPrem || MyAccount.isYrPrem) {
      unlock?.call(videoMessage);
      return;
    }

    // 普通解锁
    if (videoMessage.unlockPrice > 0 && !prompted) {
      showUnlockDialog();
    } else {
      unlock?.call(videoMessage);
    }
  }

  void showUnlockDialog() {
    showConfirmAlert(
      'Unlock Video',
      'Unlocking will cost ${videoMessage.unlockPrice} ${videoMessage.currencyType == 1 ? 'Gems' : 'Coins'}',
      onConfirm: () {
        prompted = true;
        unlock?.call(videoMessage);
      },
    );
  }

  Widget renderReloadViewIfNeeded() {
    //使Container根据自身内容自适应宽度
    if (!videoMessage.canReload) return SizedBox.shrink();
    String text = videoMessage.reloadPrice == 0 ? 'Free' : '${videoMessage.reloadPrice} ${videoMessage.reloadCurrencyType == 1 ? 'Gems' : 'Coins'}';

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            super.reload?.call(videoMessage);
          },
          child: Container(
            height: 20,
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(10)), color: Color(0x33000000)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Image.asset('packages/modules/assets/images/chat/chat_res_refresh.png', width: 12, height: 12),
                SizedBox(width: 4),
                Text(text, style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: AppFonts.medium)),
              ],
            ),
          ),
        ),
        Expanded(child: Container()),
      ],
    );
  }

  Widget renderImageMask() {
    return Stack(
      fit: StackFit.expand,
      children: [
        videoMessage.thumbnailBase64.isNotEmpty
            ? Image.memory(base64Decode(videoMessage.thumbnailBase64), fit: BoxFit.cover)
            : CachedNetworkImage(imageUrl: videoMessage.coverUrl, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
          //显示imageMessage的thumbnailBase64
          child: Container(color: Colors.transparent),
        ),
        //如果图片已经准备好
        if (videoMessage.prepared) renderUnlockMaskIfNeeded() else renderLoadingMask(),
      ],
    );
  }

  Widget renderUnlockMaskIfNeeded() {
    return Container(
      padding: EdgeInsets.only(top: isInChat ? 56 : 40, bottom: isInChat ? 20 : 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInChat) Image.asset('packages/modules/assets/images/chat/chat_lock_video.png', width: 36, height: 36),
              SizedBox(height: 8),
              if (!MyAccount.isSubscribed || MyAccount.isWkPrem && MyAccount.freeVdoLeftTimes == 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      videoMessage.currencyType == 1 ? 'packages/modules/assets/images/gem.png' : 'packages/modules/assets/images/coin.png',
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 4),
                    Text('${videoMessage.unlockPrice}', style: TextStyle(color: Colors.white, fontWeight: AppFonts.black, fontSize: 16)),
                  ],
                ),
            ],
          ),
          GestureDetector(
            onTap: () {
              //解锁图片
              showUnlockDialogIfNeeded();
            },

            child: SizedBox(
              height: isInChat ? 36 : 28,
              width: isInChat ? 132 : 90,
              child: Stack(
                children: [
                  MyAccount.isSubscribed
                      ? Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Color(0xFF110803).withValues(alpha: 0.4)),
                        child: Row(
                          spacing: 7,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('packages/modules/assets/images/account/premium_gem.png', width: 16, height: 16),
                            Text('Pro Free', style: TextStyle(color: Color(0xFFFFE96F), fontSize: 14, fontWeight: AppFonts.medium)),
                          ],
                        ),
                      )
                      : Container(
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: AppColors.primary),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset('packages/modules/assets/images/chat/chat_res_lock.png', width: 16, height: 16),
                            SizedBox(width: 4),
                            Text('Unlock', style: TextStyle(color: Colors.white, fontWeight: AppFonts.medium, fontSize: 14)),
                          ],
                        ),
                      ),
                  if (MyAccount.isWkPrem)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF000000).withValues(alpha: 0.11),
                          borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomLeft: Radius.circular(8)),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Obx(
                                () => Text(
                                  '${MyAccount.freeVdoUsedTimes}/${MyAccount.freeVdoLeftTimes + MyAccount.freeVdoUsedTimes}',
                                  style: TextStyle(color: Color(0xFFE9E7C3), fontSize: 9, fontWeight: FontWeight.w400),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // GestureDetector(
          //   onTap: () {
          //     //解锁视频
          //     showUnlockDialogIfNeeded();
          //   },
          //   child: Container(
          //     width: 132,
          //     height: 36,
          //     decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: AppColors.primary),
          //     alignment: Alignment.center,
          //     child: Row(
          //       mainAxisSize: MainAxisSize.min,
          //       children: [
          //         Image.asset('packages/modules/assets/images/chat/chat_res_lock.png', width: 16, height: 16),
          //         SizedBox(width: 4),
          //         Text('Unlock', style: TextStyle(color: Colors.white, fontWeight: AppFonts.medium, fontSize: 14)),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget renderLoadingMask() {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppColors.main, strokeWidth: 2)),
    );
  }
}
