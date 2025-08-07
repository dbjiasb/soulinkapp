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
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
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
  ChatBottomBar({super.key, this.showAudioInputMask, this.cancelAudio});

  final Function(bool)?
  showAudioInputMask; // control audio input mask visibility
  final Function(bool)? cancelAudio; // control audio input cancel state

  ChatBottomBarController viewController = Get.put(ChatBottomBarController());

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF252230).withValues(alpha: 0.5),
              Color(0xFF2F253B).withValues(alpha: 0.9),
            ],
          ),
        ),
        child: SafeArea(
          bottom: true,
          child: Column(children: [buildInputBar(), buildFunctionBar()]),
        ),
      ),
    );
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

  // input mode
  final _audioInputMode = false.obs;

  Widget buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Obx(() {
        final isAudioMode = _audioInputMode.value;
        return GestureDetector(
          onTap:
              isAudioMode
                  ? () {
                    EasyLoading.showToast('Audio input is too short to send.');
                    viewController.cleanAudioInput();
                  }
                  : null,
          onLongPressStart:
              isAudioMode
                  ? (_) {
                    beginAudioRecord();
                  }
                  : null,
          onLongPressEnd: (_) {
            endAudioRecord();
          },
          onLongPressMoveUpdate: isAudioMode ? updateAudioRecordState : null,
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color:
                  _audioInputMode.value
                      ? Colors.white.withValues(alpha: 0.7)
                      : Color(0xFFB4ADAB).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _audioInputMode.value = !_audioInputMode.value;
                    if (viewController.barState.value !=
                        ChatRoomBottomBarState.simple) {
                      viewController.updateBarState(
                        ChatRoomBottomBarState.simple,
                      );
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(left: 12, right: 8),
                    child: Obx(
                      () => Image.asset(
                        _audioInputMode.value
                            ? ImagePath.keyboard
                            : ImagePath.audio_mode,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () =>
                        _audioInputMode.value
                            ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Hold to talk',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            )
                            : Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onSubmitted: (value) {
                                      viewController.sendText(value);
                                    },
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    controller: viewController.textController,
                                    focusNode: viewController.focusNode,
                                    decoration: const InputDecoration(
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      fillColor: Colors.transparent,
                                      filled: true,
                                      hintText: 'Send message, reply by AI',
                                      hintStyle: TextStyle(
                                        color: Color(0x80FFFFFF),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                      contentPadding: EdgeInsets.zero,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (viewController.barState.value !=
                                        ChatRoomBottomBarState.muse) {
                                      viewController.updateBarState(
                                        ChatRoomBottomBarState.muse,
                                      );
                                    } else {
                                      viewController.updateBarState(
                                        ChatRoomBottomBarState.simple,
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 6),
                                    child: Obx(
                                      () => Image.asset(
                                        viewController.barState.value ==
                                                ChatRoomBottomBarState.muse
                                            ? ImagePath.tip_on
                                            : ImagePath.tip_off,
                                        width: 28,
                                        height: 28,
                                      ),
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (viewController.barState.value !=
                                        ChatRoomBottomBarState.detailed) {
                                      viewController.updateBarState(
                                        ChatRoomBottomBarState.detailed,
                                      );
                                    } else {
                                      viewController.updateBarState(
                                        ChatRoomBottomBarState.simple,
                                      );
                                    }
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 12),
                                    child: Image.asset(
                                      viewController.barState.value ==
                                              ChatRoomBottomBarState.detailed
                                          ? ImagePath.chat_close
                                          : ImagePath.boarder_add,
                                      width: 28,
                                      height: 28,
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
      }),
    );
  }

  void beginAudioRecord() {
    showAudioInputMask?.call(true);
    viewController._recordAudioBegin();
  }

  final _isCanceled = false.obs;

  void endAudioRecord() {
    showAudioInputMask?.call(false);
    viewController._recordAudioEnd(_isCanceled.value);

    // reset mask
    _isCanceled.value = false;
    cancelAudio?.call(false);
  }

  void updateAudioRecordState(LongPressMoveUpdateDetails details) {
    if (details.localPosition.dy >= 0) {
      if (_isCanceled.value == false) return;
      cancelAudio?.call(false);
      _isCanceled.value = false;
    } else {
      if (_isCanceled.value == true) return;
      cancelAudio?.call(true);
      _isCanceled.value = true;
    }
  }

  Widget buildSimpleBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: [
          GestureDetector(
            onTap: () {
              viewController.askForImage();
            },
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF63616B).withValues(alpha: 0.8),
              ),
              child: Row(
                spacing: 4,
                children: [
                  Image.asset(ImagePath.btm_pic, width: 13, height: 11),
                  Text(
                    'Ask',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              viewController.askForVideo();
            },
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF63616B).withValues(alpha: 0.8),
              ),
              child: Row(
                spacing: 4,
                children: [
                  Image.asset(ImagePath.btm_video, width: 13, height: 11),
                  Text(
                    'Ask',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onCreateImageButtonClicked,
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF63616B).withValues(alpha: 0.8),
              ),
              child: Row(
                spacing: 4,
                children: [
                  Image.asset(ImagePath.btm_custom, width: 13, height: 11),
                  Text(
                    'Custom',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              viewController.toCall();
            },
            child: Container(
              height: 30,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Color(0xFF63616B).withValues(alpha: 0.8),
              ),
              child: Row(
                spacing: 4,
                children: [
                  Image.asset(ImagePath.btm_call, width: 13, height: 11),
                  Text(
                    'Call',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GestureDetector(
          //   onTap: () {
          //     viewController.updateBarState(ChatRoomBottomBarState.detailed);
          //   },
          //   child: Image.asset(ImagePath.chat_input_more, width: 24, height: 24),
          // ),
        ],
      ),
    );
  }

  void onCreateImageButtonClicked() {
    Get.lazyPut(() => CreateImagePanelController());
    Get.bottomSheet(
      CreateImagePanel(),
      persistent: false,
      useRootNavigator: true,
    );
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
    List<Map<String, dynamic>> items = [
      {
        Security.security_title: 'Photo',
        Security.security_icon: ImagePath.func_img,
        Security.security_action: viewController.showImageSelector,
      },
      {
        Security.security_title: 'Video Call',
        Security.security_icon: ImagePath.func_video,
        Security.security_action: toCall,
      },

      {
        Security.security_title: Security.security_History,
        Security.security_icon: ImagePath.func_history,
        Security.security_action: onChatHistoryButtonClicked,
      },
      // {Security.security_title: 'Gift', Security.security_icon: ImagePath.func_gift, Security.security_action: viewController.showGiftPanel},
    ];

    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, top: 16),
      color: Colors.transparent,
      child: MasonryGridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        crossAxisSpacing: 2,
        itemCount: items.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> item = items[index];
          return GestureDetector(
            onTap: () {
              item[Security.security_action]?.call();
            },
            child: Column(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Color(0x26FFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  child: Image.asset(
                    item[Security.security_icon] ?? '',
                    width: 32,
                    height: 32,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  alignment: Alignment.center,
                  height: 16,
                  child: Text(
                    item[Security.security_title] ?? '',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
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
  int get userId => Get.find<ChatRoomViewController>().userId;

  var barState = ChatRoomBottomBarState.simple.obs;

  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void onInit() {
    super.onInit();
    focusNode.addListener(() {
      // isKeyboardVisible.value = focusNode.hasFocus;
    });
  }

  @override
  void onClose() {
    focusNode.dispose();
    textController.dispose();
    super.onClose();
  }

  void cleanAudioInput() {
    AudioManager.instance.cancel();
  }

  void _recordAudioBegin() {
    // recorder active
    AudioManager.instance.begin();
  }

  void _recordAudioEnd(bool isCanceled) async {
    if (isCanceled) {
      await AudioManager.instance.cancel();
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
    ChatAudioMessage message = ChatAudioMessage.fromAudio(
      recordInfo.$1,
      userId,
      DateTime.now().millisecondsSinceEpoch.toString(),
      recordInfo.$2,
    );
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
    if (barState.value == ChatRoomBottomBarState.muse &&
        state != ChatRoomBottomBarState.muse) {
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

    Uint8List? compressed = await FlutterImageCompress.compressWithFile(
      file.path,
    );
    if (compressed == null) return;

    EasyLoading.show();
    String? url = await FilePushService.instance.upload(
      compressed,
      FileType.im,
      ext: Security.security_jpg,
    );
    if (url == null || url.isEmpty) {
      EasyLoading.showError('Upload failed, please try again later');
      return;
    }

    DefaultCacheManager().putFileStream(url, Stream.value(compressed));
    var thumbnail = await FlutterImageCompress.compressWithFile(
      file.path,
      minWidth: 30,
      minHeight: 30,
      quality: 1,
    );

    String? thumbnailBase64;
    if (thumbnail != null) {
      thumbnailBase64 = const Base64Encoder().convert(thumbnail);
    }

    ChatImageMessage message = ChatImageMessage.fromImage(
      url,
      thumbnailBase64,
      Get.find<ChatRoomViewController>().userId,
    );

    SendMessageResponse response = await ChatManager.instance.sendMessage(
      message,
    );
    if (response.isSuccess) {
      EasyLoading.dismiss();
      Get.find<ChatRoomViewController>().insertMessages([response.message]);
    } else {
      EasyLoading.showError('Send failed, please try again later');
    }
  }
}
