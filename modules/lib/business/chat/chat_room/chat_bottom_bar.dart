import 'dart:convert';
import 'dart:typed_data';

import 'package:external_modules/player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/business/chat/chat_manager.dart';
import 'package:modules/business/chat/chat_room/chat_room_view.dart';
import 'package:modules/business/chat/chat_room_cells/chat_audio_message.dart';
import 'package:modules/business/chat/chat_room_cells/chat_image_message.dart';
import 'package:modules/core/util/audio_manager.dart';
import 'package:modules/core/util/file_upload.dart';
import 'package:modules/shared/app_theme.dart';

import '../create_image/create_image_panel.dart';
import '../gift/gift_panel.dart';
import 'chat_muse_view.dart';

enum ChatRoomBottomBarState { simple, detailed, muse }

class ChatBottomBar extends StatelessWidget {
  ChatBottomBar({super.key});

  ChatBottomBarController viewController = Get.put(ChatBottomBarController());

  @override
  Widget build(BuildContext context) {
    return Obx(()=>SizedBox(
      height: viewController.barState.value ==ChatRoomBottomBarState.detailed?104+166:114,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xFF000000).withOpacity(0.3)],
                ),
              ),
              child: SafeArea(bottom: true, child: Column(children: [buildInputBar(), buildFunctionBar()])),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Obx(() {
              if (!viewController._isShowAudioInputAnim.value) {
                return Container();
              }
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.61), Colors.black.withValues(alpha: 0.75)],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 116,
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Obx(()=>Container(
                            height: 72,
                            padding: EdgeInsets.symmetric(horizontal: 83),
                            decoration: BoxDecoration(
                                image: DecorationImage(image: AssetImage('packages/modules/assets/images/chat/${viewController._isCanceled.value?'cancel_':''}send.png'),fit: BoxFit.contain)
                            ),
                            child: Padding(padding: EdgeInsets.only(left: 35,top: 18,right: 35,bottom: 30),child: SVGASimpleImage(assetsName: 'packages/modules/assets/anim/voice_wave.svga'),),
                          )),
                          Container(
                            height: 44,
                            child:
                            Obx(
                                  () =>
                              viewController._isCanceled.value
                                  ? Text('Release Cancel', style: TextStyle(color: Color(0xFFFF3E3E), fontSize: 13,fontWeight: AppFonts.medium))
                                  : Text('Release Send', style: TextStyle(color: Colors.white, fontSize: 13,fontWeight: AppFonts.medium)),
                            ),

                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 108,
                      clipBehavior: Clip.hardEdge,
                      alignment: Alignment.topCenter,
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        image: DecorationImage(
                          image: AssetImage('packages/modules/assets/images/chat/chat_input_voice_bg.png'),
                          fit: BoxFit.fitWidth,
                          alignment: Alignment.topCenter,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    ));
  }

  Widget buildFunctionBar() {
    ChatRoomBottomBarState state = viewController.barState.value;
    switch (state) {
      case ChatRoomBottomBarState.simple:
        {
          return buildSimpleBar();
        }

      case ChatRoomBottomBarState.detailed:
        {
          return buildDetailedBar();
        }

      case ChatRoomBottomBarState.muse:
        {
          return ChatMuseView();
        }
    }
  }

  Widget buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(color: const Color(0x66D8D8D8), borderRadius: BorderRadius.circular(8)),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {
                viewController._audioInputMode.value = !viewController._audioInputMode.value;
              },
              child: Container(
                margin: EdgeInsets.only(left: 12, right: 8),
                child: Obx(
                  () => Image.asset(
                    'packages/modules/assets/images/chat/chat_input_${viewController._audioInputMode.value ? 'keyboard' : 'voice'}.png',
                    width: 24,
                    height: 24,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Obx(
                () =>
                    viewController._audioInputMode.value
                        ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            EasyLoading.showToast('Audio input is too short to send.');
                            endAudioRecord();
                          },
                          onLongPressStart: (_) {
                            beginAudioRecord();
                          },
                          onLongPressEnd: (_) {
                            endAudioRecord();
                          },
                          onLongPressMoveUpdate: viewController._onGesUpdate,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [Text('Hold to talk', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 11))],
                          ),
                        )
                        : Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onSubmitted: (value) {
                                  viewController.sendText(value);
                                },
                                style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                controller: viewController.textController,
                                focusNode: viewController.focusNode,
                                decoration: const InputDecoration(
                                  enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  hintText: 'Send message, reply by AI',
                                  hintStyle: TextStyle(color: Color(0x80FFFFFF), fontWeight: FontWeight.w600, fontSize: 11),
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                viewController.updateBarState(ChatRoomBottomBarState.muse);
                              },
                              child: Container(
                                margin: EdgeInsets.only(right: 12),
                                child: Obx(
                                  () => Image.asset(
                                    'packages/modules/assets/images/chat/chat_input_tips${viewController.barState.value == ChatRoomBottomBarState.muse ? '_light' : ''}.png',
                                    width: 20,
                                    height: 20,
                                  ),
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
    );
  }

  void beginAudioRecord() {
    viewController._isShowAudioInputAnim.value = true;

    viewController._isInputtingAudio.value = true;
  }

  void endAudioRecord() {
    viewController._isShowAudioInputAnim.value = false;

    viewController._isInputtingAudio.value = false;
  }

  Widget buildSimpleBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              viewController.showImageSelector();
            },
            child: Image.asset('packages/modules/assets/images/chat/req_image.png', width: 24, height: 24),
          ),
          GestureDetector(
            onTap: () {
              viewController.toCall();
            },
            child: Image.asset('packages/modules/assets/images/chat/chat_voice_call.png', width: 24, height: 24),
          ),

          GestureDetector(
            onTap: () {
              viewController.showGiftPanel();
            },
            child: Image.asset('packages/modules/assets/images/chat/chat_send_gift.png', width: 24, height: 24),
          ),

          GestureDetector(
            onTap: () {
              viewController.updateBarState(ChatRoomBottomBarState.detailed);
            },
            child: Image.asset('packages/modules/assets/images/chat/chat_input_more.png', width: 24, height: 24),
          ),
        ],
      ),
    );
  }

  void onCreateImageButtonClicked() {
    Get.lazyPut(() => CreateImagePanelController());
    Get.bottomSheet(CreateImagePanel(), persistent: false, useRootNavigator: true);
  }

  void onChatHistoryButtonClicked() {
    Get.toNamed(Routers.chatHistory.name);
  }

  void askForImage() {
    viewController.askForImage();
  }

  void askForVideo() {
    viewController.askForVideo();
  }

  void toCall() {
    ChatRoomViewController viewController = Get.find<ChatRoomViewController>();
    viewController.toCall();
  }

  Widget buildDetailedBar() {
    String path = 'packages/modules/assets/images/chat/chat_bottom_';
    List<Map<String, dynamic>> items = [
      {'title': 'Custom', 'icon': '${path}custom.png', 'action': onCreateImageButtonClicked},
      {'title': 'Ask for Pic', 'icon': '${path}image.png', 'action': askForImage},
      {'title': 'History', 'icon': '${path}history.png', 'action': onChatHistoryButtonClicked},
      {'title': 'Ask for Video', 'icon': '${path}video.png', 'action': askForVideo},
      {'title': 'Voice Call', 'icon': '${path}audio.png', 'action': toCall},
    ];

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      color: Color(0xFF150C09).withValues(alpha: 0.7),
      child: MasonryGridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        itemCount: items.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = items[index];
          return GestureDetector(
            onTap: () {
              item['action']?.call();
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Color(0x26FFFFFF), borderRadius: BorderRadius.all(Radius.circular(10))),
                  child: Image.asset(item['icon'] ?? '', width: 32, height: 32),
                ),
                SizedBox(height: 4),
                Container(
                  alignment: Alignment.center,
                  height: 16,
                  child: Text(item['title'] ?? '', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 11)),
                ),
                SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }
}

class ChatBottomBarController extends GetxController {
  int get userId =>Get.find<ChatRoomViewController>().userId;

  var barState = ChatRoomBottomBarState.simple.obs;

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      // isKeyboardVisible.value = focusNode.hasFocus;
    });
    ever(_isInputtingAudio, (value) {
      if (value) {
        _recordAudioBegin();
      } else {
        _recordAudioEnd();
      }
    });
  }

  @override
  void onClose() {
    focusNode.dispose();
    textController.dispose();
    super.onClose();
  }

  final _audioInputMode = false.obs;
  final _isInputtingAudio = false.obs;
  final _isShowAudioInputAnim = false.obs;
  final _isCanceled = false.obs;
  final _gesDx = 0.0.obs;
  final _gesDy = 0.0.obs;

  void cleanAudioInput() {
    AudioManager.instance.cancel();
  }


  void _recordAudioBegin() {
    AudioManager.instance.begin();
  }

  void _onGesUpdate(LongPressMoveUpdateDetails details) {
    _gesDx.value = details.localPosition.dx;
    _gesDy.value = details.localPosition.dy;
    if(_gesDy>= 0){
      _isCanceled.value = false;
    }else{
      _isCanceled.value = true;
    }
  }


  void _recordAudioEnd() async {
    if(_isCanceled.value){
      AudioManager.instance.cancel();
      _isCanceled.value = false;
      return;
    }
    final recordInfo = await AudioManager.instance.finish();
    if (recordInfo == null) return;
    sendAudio(recordInfo);
  }

  void sendText(String text) {
    textController.clear();
    ChatRoomViewController viewController = Get.find<ChatRoomViewController>();
    viewController.sendText(text);
  }

  void sendAudio((String, int) recordInfo) async {

    ChatAudioMessage message = ChatAudioMessage.fromAudio(recordInfo.$1, userId, DateTime.now().millisecondsSinceEpoch.toString(), recordInfo.$2);
    ChatRoomViewController viewController = Get.find<ChatRoomViewController>();
    viewController.sendMessage(message);
  }

  void toCall() {
    ChatRoomViewController viewController = Get.find<ChatRoomViewController>();
    viewController.toCall();
  }

  void unfocus() {
    updateBarState(ChatRoomBottomBarState.simple);
    focusNode.unfocus();
  }

  void updateBarState(ChatRoomBottomBarState state) {
    if (barState.value == ChatRoomBottomBarState.muse && state != ChatRoomBottomBarState.muse) {
      Get.delete<ChatMuseViewController>();
    }
    barState.value = state;
  }

  void showGiftPanel() {
    ChatRoomViewController viewController = Get.find<ChatRoomViewController>();
    Get.bottomSheet(GiftPanel(recipient: viewController.userId));
  }

  void askForVideo() {
    sendText('send me a video');
  }

  void askForImage() {
    sendText('send me a picture');
  }

  void showImageSelector() {
    Get.bottomSheet(
      SafeArea(
        bottom: false,
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Select from the album'),
                  onTap: () async {
                    Get.back();
                    pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Turn on the camera'),
                  onTap: () async {
                    Get.back();
                    pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void pickImage(ImageSource source) async {
    XFile? file = await ImagePicker().pickImage(source: source);
    if (file == null) return;

    Uint8List? compressed = await FlutterImageCompress.compressWithFile(file.path);
    if (compressed == null) return;

    EasyLoading.show();
    String? url = await FilePushService.instance.upload(compressed, FileType.im, ext: 'jpg');
    if (url == null || url.isEmpty) {
      EasyLoading.showError('Upload failed, please try again later');
      return;
    }

    DefaultCacheManager().putFileStream(url, Stream.value(compressed));
    var thumbnail = await FlutterImageCompress.compressWithFile(file.path, minWidth: 30, minHeight: 30, quality: 1);

    String? thumbnailBase64;
    if (thumbnail != null) {
      thumbnailBase64 = const Base64Encoder().convert(thumbnail);
    }

    ChatImageMessage message = ChatImageMessage.fromImage(url, thumbnailBase64, Get.find<ChatRoomViewController>().userId);

    SendMessageResponse response = await ChatManager.instance.sendMessage(message);
    if (response.isSuccess) {
      EasyLoading.dismiss();
      Get.find<ChatRoomViewController>().insertMessages([response.message]);
    } else {
      EasyLoading.showError('Send failed, please try again later');
    }
  }
}
