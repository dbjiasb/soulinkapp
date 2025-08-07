import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_response.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/business/chat/chat_room_cells/chat_message.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/report/report_helper.dart';
import 'package:modules/core/user_manager/user_manager.dart';

import '../../../shared/app_theme.dart';
import '../chat_manager.dart';
import '../chat_room_cells/chat_audio_message.dart';
import '../chat_room_cells/chat_cell.dart';
import '../chat_room_cells/chat_generating_message.dart';
import '../chat_room_cells/chat_system_message.dart';
import '../chat_room_cells/chat_text_cell.dart';
import '../chat_room_cells/chat_time_message.dart';
import '../chat_session.dart';
import '../chat_voice_manager.dart';
import '../chat_voice_player.dart';
import './chat_bottom_bar.dart';

const String chatImageDirectory = 'packages/pods/modules/assets/images/chat/';
String chatRoomViewTag = Security.security_chat_room_view;

class ChatRoomView extends StatelessWidget {
  ChatRoomView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  ChatRoomViewController viewController = Get.put(ChatRoomViewController(Get.arguments));

  // used in audio input


  void _onBackgroundClicked() {
    viewController.unfocus();
  }

  void _onBackButtonClicked() {
    Get.back();
  }

  Widget _buildChatRoomView() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child:
            viewController.messages.isEmpty
                ? null
                : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return ChatCell.create(
                      viewController.messages[index],
                      resend: viewController.resendMessage,
                      unlock: viewController.unlockMessage,
                      reload: viewController.reloadMessage,
                      download: viewController.downloadMessage,
                      onTap: viewController.onTapMessage,
                    );
                  },
                  itemCount: viewController.messages.length,
                  padding: EdgeInsets.zero,
                  reverse: true,
                ),
      ),
    );
  }

  Widget _buildChatDrawer() {
    return Drawer(
      backgroundColor: AppColors.base_background,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            _drawerTemplate(
              Security.security_Report,
              onTap: () {
                ReportHelper.showReportDialog(int.parse(viewController.session.id));
              },
            ),
          ],
        ),
      ),
    );
  }

  // used in audio input
  final isAudioMaskShow = false.obs;
  final isAudioCanceled = false.obs;

  void showAudioMask(bool show) {
    isAudioMaskShow.value = show;
  }

  void cancelAudio(bool cancel) {
    isAudioCanceled.value = cancel;
  }

  Widget _buildAudioInputMask(){
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Obx(() {
        if (!isAudioMaskShow.value) {
          return Container();
        }
        return Container(
          height: 210,
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
                padding: EdgeInsets.only(bottom: 12,top: 30),
                child: Center(
                  child: Obx(
                        () =>
                    isAudioCanceled.value
                        ? Text('Release Cancel', style: TextStyle(color: Color(0xFFFF3E3E), fontSize: 13, fontWeight: AppFonts.medium))
                        : Text('Release Send', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: AppFonts.medium)),
                  ),
                ),
              ),
              Container(
                  height: 148,
                  clipBehavior: Clip.hardEdge,
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    image: DecorationImage(image: AssetImage(ImagePath.audio_mask), fit: BoxFit.fitWidth, alignment: Alignment.topCenter),
                  ),
                  child:Column(
                    children: [
                      SizedBox(height: 10),
                      Container(
                        height: 72,
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isAudioCanceled.value?Color(0xFFF84652).withValues(alpha: 0.4):Color(0xFF29D97F).withValues(alpha: 0.4)
                        ),
                        child: Image.asset(isAudioCanceled.value?ImagePath.audio_cancel:ImagePath.audio_on),
                      ),
                      Spacer(),
                    ],
                  )
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _drawerTemplate(String title, {Function()? onTap, Widget? tail}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Color(0xFF2A2132), borderRadius: BorderRadius.circular(8)),
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            Text(title, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
            Spacer(),
            tail ?? Image.asset(ImagePath.right_arrow, height: 16, width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundView() {
    debugPrint('viewController.session.backgroundUrl.value: ${viewController.session.backgroundUrl.value}');
    return Obx(
      () => // 添加 Obx 响应式监听
          viewController.session.backgroundUrl.value.isNotEmpty
              ? CachedNetworkImage(
                imageUrl: viewController.session.backgroundUrl.value,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => SizedBox.shrink(),
              )
              : SizedBox.shrink(),
    );
  }

  Widget _buildNavigationBar() {
    return Container(
      height: 44,
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: _onBackButtonClicked,
            child: Container(width: 32, height: 44, alignment: Alignment.center, child: Image.asset(ImagePath.back, width: 24, height: 24)),
          ),
          // SizedBox(width: 4),
          // GestureDetector(
          //   onTap: () {
          //     Get.toNamed(Routers.person.name, arguments: {Security.security_personId: viewController.userId});
          //   },
          //   child: Container(
          //     width: 32,
          //     height: 32,
          //     padding: const EdgeInsets.all(1),
          //     decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
          //     child: ClipOval(clipBehavior: Clip.antiAlias, child: Image.network(viewController.session.avatar, width: 30, height: 30)),
          //   ),
          // ),
          // const SizedBox(width: 10),
          // Expanded(
          //   child: Row(
          //     children: [
          //       Flexible(child: Text(viewController.session.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
          //       SizedBox(width: 5),
          //       AppWidgets.userTag(viewController.session.accountType),
          //     ],
          //   ),
          // ),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          //   decoration: BoxDecoration(color: Color(0xFF000000).withValues(alpha: 0.30), borderRadius: BorderRadius.circular(14)),
          //   child: Row(
          //     spacing: 6,
          //     children: [
          //       Image.asset(ImagePath.gem, height: 16, width: 16),
          //       Obx(() => Text(MyAccount.gems.toString(), style: TextStyle(color: Colors.white, fontSize: 12))),
          //     ],
          //   ),
          // ),
          // SizedBox(width: 8),
          // Container(
          //   padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          //   decoration: BoxDecoration(color: Color(0xFF000000).withValues(alpha: 0.30), borderRadius: BorderRadius.circular(14)),
          //   child: Row(
          //     spacing: 6,
          //     children: [
          //       Image.asset(ImagePath.coin, height: 16, width: 16),
          //       Obx(() => Text(MyAccount.coins.toString(), style: TextStyle(color: Colors.white, fontSize: 12))),
          //     ],
          //   ),
          // ),
          Spacer(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(Routers.person.name, arguments: {Security.security_personId: viewController.userId});
              },
              child: Row(
                spacing: 4,
                children: [
                  Text(viewController.session.name, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Image.asset(ImagePath.right_arrow, height: 16, width: 16)
                ],),
            )
          ]),
          Spacer(),
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: Image.asset(ImagePath.more, width: 24, height: 24),
          ),
          SizedBox(width: 5),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onBackgroundClicked,
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: _buildChatDrawer(),
        backgroundColor: Color(0xFF0A0B12),
        resizeToAvoidBottomInset: true,
        body: Stack(
          fit: StackFit.expand,
          children: [
            _buildBackgroundView(),
            SafeArea(bottom: false, child: Column(children: [_buildNavigationBar(), Obx(() => _buildChatRoomView()), ChatBottomBar(showAudioInputMask: showAudioMask,cancelAudio: cancelAudio,)])),
            _buildAudioInputMask()
          ],
        ),
      ),
    );
  }
}

class ChatRoomViewController extends GetxController {
  final isShowAudioInputAnim = false.obs;

  Map<String, dynamic> arguments = Get.arguments;

  final ChatSession session;

  int get userId => int.parse(session.id);

  var isKeyboardVisible = false.obs;

  List messages = [].obs;

  ChatMessage? focusedMessage;

  ChatGeneratingMessage? _generatingMessage;

  ChatGeneratingMessage get generatingMessage {
    _generatingMessage ??= ChatGeneratingMessage.placeholder(userId);
    return _generatingMessage!;
  }

  Timer? _generatingTimer;

  List waitingMessages = [];

  ChatRoomViewController(Map<String, dynamic> arguments) : session = createSession(arguments);

  @override
  void onInit() async {
    super.onInit();

    ChatVoicePlayer.instance.init();
    ChatManager.instance.currentSession = session;
    //刷新session
    await refreshSession();
    debugPrint('[ChatRoom] sid:${session.id}, greeted: ${session.greeted}');

    insertAiTipsMessageIfNeeded();

    if (!session.greeted) {
      ChatManager.instance.sayHelloIfNeeded(session);
    }

    //查聊天记录
    List<ChatMessage> results = await ChatManager.instance.messageHandler.queryMessages(session.id);
    messages.addAll(results);

    // 消息按照时间分段，每个5分钟为一段，插入一个ChatTimeMessage
    // insertTimeMessages();

    EventCenter.instance.addListener(kEventCenterDidQueriedNewMessages, handlePullMessages);
    EventCenter.instance.addListener(kEventCenterDidReceivedNewMessages, handlePushMessages);
    EventCenter.instance.addListener(kEventCenterDidPreparedImageMessage, onImagePrepared);

    UserInfo userInfo = await UserManager.instance.getUserInfo(int.parse(session.id));
    debugPrint('userInfo: ${userInfo.toString()}');
    if (userInfo.coverImageUrl.isNotEmpty) {
      session.backgroundUrl.value = userInfo.coverImageUrl;
      session.backgroundUrl.refresh();
    }

    bool call = arguments[Security.security_call] ?? false;
    if (call) {
      toCall();
    }
  }

  onImagePrepared(Event event) {
    ChatMessage message = event.data[Security.security_message];
    //替换messages中的消息
    replaceMessage(message);
  }

  void toCall() {
    Get.toNamed(Routers.call.name, arguments: {Security.security_session: session.toRouter()});
  }

  @override
  void onReady() {
    super.onReady();
  }

  bool get isAiChat => session.accountType == 1 || session.accountType == 3 || session.accountType == 4;

  //如果是ai聊天，则插入一个系统消息
  void insertAiTipsMessageIfNeeded() {
    if (isAiChat) {
      ChatSystemMessage message = ChatSystemMessage();
      insertMessages([message]);
    }
  }

  // 插入时间消息的方法
  void insertTimeMessages() {
    if (messages.isEmpty) return;

    // 按消息时间排序
    messages.sort((a, b) => a.date.compareTo(b.date));

    const fiveMinutes = Duration(minutes: 5);
    DateTime? lastTime;

    // 倒序遍历
    for (int i = messages.length - 1; i >= 0; i--) {
      ChatMessage message = messages[i];
      if (lastTime == null || message.date.difference(lastTime) >= fiveMinutes) {
        // 插入 ChatTimeMessage
        ChatTimeMessage timeMessage = ChatTimeMessage(message.date);
        messages.insert(i + 1, timeMessage);
        lastTime = message.date;
      }
    }
  }

  static createSession(Map<String, dynamic> arguments) {
    String sessionJson = arguments[Security.security_session];
    Map<String, dynamic> sessionMap = jsonDecode(sessionJson);

    ChatSession chatSession = ChatSession.fromRouter(sessionMap);

    return chatSession;
  }

  Future<void> refreshSession() async {
    ChatSession? localSection = await ChatManager.instance.sessionHandler.querySession(session.id);
    if (localSection != null) {
      session.lastMessageTime = localSection.lastMessageTime;
      session.lastMessageText = localSection.lastMessageText;
      if (session.backgroundUrl.value.isEmpty) {
        session.backgroundUrl.value = localSection.backgroundUrl.value;
      }
      session.greeted = true;
    }
    return Future.value();
  }

  handlePullMessages(Event event) async {
    if (event.data[session.id] != null) {
      List newMessages = event.data[session.id];
      insertMessages(newMessages);
    }
  }

  handlePushMessages(Event event) async {
    if (event.data[session.id] != null) {
      List newMessages = event.data[session.id];
      insertMessages(newMessages);
    }
  }

  void insertMessages(List newest) {
    if (newest.isEmpty) return;
    waitingMessages.insertAll(0, newest.reversed);
    if (_generatingTimer != null) return; //如果已经有定时器了，就等定时器下一次插入消息
    removeGeneratingMessage(); //移除生成中的消息
    insetMessageFromWaiting(); //从等待队列中取出一个消息插入到消息列表中
    if (waitingMessages.isNotEmpty) {
      insertGeneratingMessage(); //如果还有消息，就插入生成中的消息
      startGeneratingTimer(); //如果还有消息，就启动定时器
    }
  }

  void insetMessageFromWaiting() {
    if (waitingMessages.isEmpty) {
      return;
    }
    ChatMessage last = waitingMessages.removeLast();
    messages.insert(0, last);
  }

  void insertGeneratingMessage() {
    //先判断第一条是不是generatingMessage
    if (messages.isNotEmpty && messages.first == generatingMessage) return;

    //判断是否包含generatingMessage，如果是，则移动到第一个
    int index = messages.indexOf(generatingMessage);
    if (index >= 0) {
      messages.remove(generatingMessage);
    }
    messages.insert(0, generatingMessage);
  }

  void removeGeneratingMessage() {
    if (messages.isNotEmpty && messages.first == generatingMessage) {
      //大部分情况下最后一个是generatingMessage，所以先判断最后一个
      messages.remove(generatingMessage);
    } else {
      messages.remove(generatingMessage);
    }
  }

  //#_generatingTimer
  void startGeneratingTimer() {
    if (_generatingTimer != null) {
      return;
    }
    _generatingTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      onTimeout(timer);
    });
  }

  void onTimeout(Timer timer) {
    removeGeneratingMessage(); //移除生成中的消息
    insetMessageFromWaiting(); //从等待队列中取出一个消息插入到消息列表中
    if (waitingMessages.isNotEmpty) {
      insertGeneratingMessage(); //如果还有消息，就插入生成中的消息
    } else {
      stopGeneratingTimer(); //如果没有消息了，就停止定时器
    }
  }

  void stopGeneratingTimer() {
    if (_generatingTimer != null) {
      _generatingTimer!.cancel();
      _generatingTimer = null;
    }
  }

  @override
  void onClose() {
    EventCenter.instance.removeListener(kEventCenterDidQueriedNewMessages, handlePullMessages);
    EventCenter.instance.removeListener(kEventCenterDidReceivedNewMessages, handlePushMessages);
    EventCenter.instance.removeListener(kEventCenterDidPreparedImageMessage, onImagePrepared);
    ChatManager.instance.currentSession = null;
    ChatVoicePlayer.instance.dealloc();
    super.onClose();
  }

  @override
  void dispose() {
    debugPrint('dispose');
    super.dispose();
  }

  void unfocus() {
    //找到ChatRoomBar
    ChatBottomBarController barController = Get.find<ChatBottomBarController>();
    barController.unfocus();
  }

  void sendText(String text) async {
    // if (textController.text.isEmpty) {
    //   return;
    // }
    ChatMessage message = ChatTextMessage.fromText(text, userId);
    sendMessage(message);
  }

  void sendMessage(ChatMessage message) async {
    //先插入到数据库
    int result = await ChatManager.instance.messageHandler.insertMessage(message);
    if (result <= 0) return;
    //更新列表
    if (messages.contains(message)) {
      //重发的消息，先移除掉
      messages.remove(message);
    }

    messages.insert(0, message);
    //再发送
    SendMessageResponse response = await ChatManager.instance.sendMessage(message);
    if (response.isSuccess) {
      //用服务器返回的message替换掉自己发出去的message
      int index = messages.indexWhere((element) => element.nativeId == message.nativeId);
      if (index >= 0) {
        messages[index] = response.message;
        insertGeneratingMessage();
      } else {
        debugPrint('sendMessage: 找不到自己发出去的message');
      }
    } else {}
  }

  resendMessage(ChatMessage message) async {
    message.sendState.value = ChatMessageSendStatus.sending;
    sendMessage(message);
  }

  Future<void> downloadMessage(ChatMessage message) async {
    await downloadMessageResource(message);
    await ChatManager.instance.messageHandler.insertMessage(message);
    replaceMessage(message);
  }

  Future<void> downloadMessageResource(ChatMessage message) async {
    if (message is ChatTextMessage) {
      //文本转语音
      ChatTextMessage textMessage = message;

      message.audioStatus.value = ChatTextAudioStatus.loading;

      TTSResult result = await ChatVoiceManager.instance.textToVoice(textMessage);
      if (result.success) {
        Map extra = result.toJson();
        Map newInfo = {...textMessage.decodedInfo, ...extra};
        textMessage.info = JsonEncoder().convert(newInfo);
      }

      message.audioStatus.value = ChatTextAudioStatus.ready;
    } else if (message is ChatAudioMessage) {
      ChatVoiceManager.instance.downloadSrc(message.audioUrl);
    }
  }

  Future<bool> unlockMessage(ChatMessage message) async {
    debugPrint('unlockMessage: $message');
    EasyLoading.show();
    ApiResponse response = await ChatManager.instance.unlockMessage(message);
    if (response.isSuccess) {
      ChatMessage newMessage = ChatMessage.fromServer(response.data[Security.security_msg]);
      await downloadMessageResource(newMessage);
      await ChatManager.instance.messageHandler.insertMessage(newMessage);

      // 更新权益信息
      MyAccount.setPremInfo(response.data[Security.security_ownPremiumInfo]);
      EasyLoading.dismiss();
      replaceMessage(newMessage);
    } else {
      EasyLoading.showError(response.description);
    }
    return Future.value(response.isSuccess);
  }

  void replaceMessage(ChatMessage message) {
    int index = messages.indexWhere((element) => element.id == message.id);
    if (index >= 0) {
      if (focusedMessage != null && focusedMessage!.id == message.id) {
        focusedMessage = message;
        message.focused.value = true;
      }
      messages[index] = message;
    }
  }

  void reloadMessage(ChatMessage message) async {
    EasyLoading.show();
    ApiResponse response = await ChatManager.instance.reloadMessage(message);
    if (response.isSuccess) {
      EasyLoading.dismiss();
      ChatMessage newMessage = ChatMessage.fromServer(response.data[Security.security_msg]);
      await ChatManager.instance.messageHandler.insertMessage(newMessage);
      replaceMessage(newMessage);
    } else {
      EasyLoading.showError(response.description);
    }
  }

  void onTapMessage(ChatMessage message) {
    debugPrint('onTapMessage: $message');
    if (!message.isMine()) {
      focusedMessage?.focused.value = false;
      focusedMessage = message;
      message.focused.value = true;
    }
  }
}
