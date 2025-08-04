import 'package:modules/base/crypt/security.dart';
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
import 'package:uuid/uuid.dart';

import '../chat_room_cells/chat_cell.dart';
import 'chat_message.dart';

class ChatImageMessage extends ChatMessage {
  ChatImageMessage({
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
    return {...super.toServer(), Security.security_jsonBody: info, Security.security_id: id};
  }

  @override
  Map<String, Object?> toDatabase() {
    return {...super.toDatabase()};
  }

  ChatImageMessage.fromDatabase(Map<String, Object?> map) : super.fromLocalData(map) {}

  ChatImageMessage.fromServer(Map map) : super.fromServerData(map) {}

  ChatImageMessage.fromImage(String url, String? base64, int receiverId)
    : super(
        id: DateTime.now().microsecondsSinceEpoch,
        senderId: AccountService.instance.account.userId,
        receiverId: receiverId,
        date: DateTime.now(),
        ownerId: AccountService.instance.account.userId,
        type: ChatMessageType.image,
        uuid: '',
        info: '',
        lockInfo: {},
        nativeId: (const Uuid().v4()).replaceAll('-', ''),
      ) {
    Map body = {Security.security_url: url, Security.security_base64: base64 ?? ''};
    info = jsonEncode(body);
  }

  Map<String, dynamic>? _decodedMap;

  Map<String, dynamic> get decodedMap {
    _decodedMap ??= jsonDecode(info);
    return _decodedMap ?? {};
  }

  String get imageUrl => decodedMap[Security.security_url] ?? '';
  bool get prepared => decodedMap[Security.security_prepared] == 1 || (decodedMap[Security.security_prepared] == null && imageUrl.isNotEmpty);

  String get thumbnailBase64 {
    return decodedMap[Security.security_base64] ?? '';
  }

  bool get locked => lockInfo.isEmpty || lockInfo[Security.security_unlock] == 1;

  int get unlockPrice => lockInfo[Security.security_cost] ?? 0;

  int get currencyType => lockInfo[Security.security_costType] ?? 0;

  bool get canReload => locked && renewInfo[Security.security_reload] == 1;

  int get reloadPrice => renewInfo[Security.security_cost] ?? 0;

  int get reloadCurrencyType => renewInfo[Security.security_costType] ?? 0;
}

class ChatImageCell extends ChatCell {
  ChatImageCell(super.message, {super.key, super.resend, super.unlock, super.reload});

  ChatImageMessage get imageMessage => message as ChatImageMessage;

  Widget buildImageView() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageMessage.prepared && imageMessage.locked)
            GestureDetector(
              onTap: () {
                Get.toNamed(Routers.imageBrowser.name, arguments: {Security.security_imageUrl: imageMessage.imageUrl});
              },
              child: CachedNetworkImage(imageUrl: imageMessage.imageUrl, fit: BoxFit.cover),
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
          Row(
            mainAxisAlignment: imageMessage.isMine() ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [SizedBox.fromSize(size: Size(172, 256), child: buildImageView())],
          ),
          renderReloadViewIfNeeded(),
        ],
      ),
    );
  }

  Widget buildImageCell() {
    return AspectRatio(aspectRatio: 109 / 168, child: buildImageView());
  }

  @override
  Widget build(BuildContext context) {
    return type == ChatCellType.category ? buildImageCell() : buildChatCell();
  }

  Widget renderReloadViewIfNeeded() {
    //使Container根据自身内容自适应宽度
    if (!imageMessage.canReload || type == ChatCellType.category) return SizedBox.shrink();
    String text = imageMessage.reloadPrice == 0 ? Security.security_Free : '${imageMessage.reloadPrice} ${imageMessage.reloadCurrencyType == 1 ? 'Gems' : 'Coins'}';

    return Row(
      children: [
        GestureDetector(
          onTap: () {
            super.reload?.call(imageMessage);
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
        imageMessage.thumbnailBase64.isNotEmpty
            ? Image.memory(base64Decode(imageMessage.thumbnailBase64), fit: BoxFit.cover)
            : CachedNetworkImage(imageUrl: imageMessage.imageUrl, fit: BoxFit.cover),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 100.0, sigmaY: 100.0),
          //显示imageMessage的thumbnailBase64
          child: Container(color: Colors.transparent),
        ),
        //如果图片已经准备好
        if (imageMessage.prepared) renderUnlockMaskIfNeeded() else renderLoadingMask(),
      ],
    );
  }

  static String kChatImageUnlockPromptKey = Security.security_kChatImageUnlockPromptKey;

  bool get prompted => Preferences.instance.getString(kChatImageUnlockPromptKey) != null;

  set prompted(bool value) {
    if (value) {
      Preferences.instance.setString(kChatImageUnlockPromptKey, '$kChatImageUnlockPromptKey:1');
    } else {
      Preferences.instance.remove(kChatImageUnlockPromptKey);
    }
  }

  void showUnlockDialogIfNeeded() {
    // 会员解锁
    if (MyAccount.isWkPrem && MyAccount.freeImgLeftTimes > 0 || MyAccount.isMthPrem || MyAccount.isYrPrem) {
      unlock?.call(imageMessage);
      return;
    }

    // 普通解锁
    if (imageMessage.unlockPrice > 0 && !prompted) {
      showUnlockDialog();
    } else {
      unlock?.call(imageMessage);
    }
  }

  void showUnlockDialog() {
    showConfirmAlert(
      'Unlock Image',
      'Unlocking will cost ${imageMessage.unlockPrice} ${imageMessage.currencyType == 1 ? 'Gems' : 'Coins'}',
      onConfirm: () {
        prompted = true;
        unlock?.call(imageMessage);
      },
    );
  }

  Widget renderUnlockMaskIfNeeded() {
    return Container(
      padding: EdgeInsets.only(top: type == ChatCellType.chat ? 56 : 40, bottom: type == ChatCellType.chat ? 20 : 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (type == ChatCellType.chat) Image.asset('packages/modules/assets/images/chat/chat_lock_portrait.png', width: 36, height: 36),
              SizedBox(height: 8),
              if (!MyAccount.isSubscribed || MyAccount.isWkPrem && MyAccount.freeImgLeftTimes == 0)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      imageMessage.currencyType == 1 ? 'packages/modules/assets/images/gem.png' : 'packages/modules/assets/images/coin.png',
                      width: 24,
                      height: 24,
                    ),
                    SizedBox(width: 4),
                    Text('${imageMessage.unlockPrice}', style: TextStyle(color: Colors.white, fontWeight: AppFonts.black, fontSize: 16)),
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
              height: type == ChatCellType.chat ? 36 : 28,
              width: type == ChatCellType.chat ? 132 : 90,
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
                            Text(Security.security_Unlock, style: TextStyle(color: Colors.white, fontWeight: AppFonts.medium, fontSize: 14)),
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
                                  '${MyAccount.freeImgUsedTimes}/${MyAccount.freeImgUsedTimes + MyAccount.freeImgLeftTimes}',
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
