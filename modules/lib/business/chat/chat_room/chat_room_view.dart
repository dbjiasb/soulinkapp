import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_response.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/business/chat/chat_room_cells/chat_message.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/report/report_helper.dart';
import 'package:modules/core/user_manager/user_manager.dart';
import 'package:modules/shared/widget/app_widgets.dart';

import '../../../shared/app_theme.dart';
import '../chat_manager.dart';
import '../chat_room_cells/chat_audio_message.dart';
import '../chat_room_cells/chat_cell.dart';
import '../chat_room_cells/chat_generating_message.dart';
import '../chat_room_cells/chat_text_cell.dart';
import '../chat_room_cells/chat_time_message.dart';
import '../chat_session.dart';
import '../chat_voice_manager.dart';
import '../chat_voice_player.dart';
import './chat_bottom_bar.dart';

const String chatImageDirectory = 'packages/pods/modules/assets/images/chat/';
const String chatRoomViewTag = 'chat_room_view';

class ChatRoomView extends StatelessWidget {
  ChatRoomView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();

  ChatRoomViewController viewController = Get.put(ChatRoomViewController(Get.arguments));

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
      backgroundColor: AppColors.main,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            _drawerTemplate(
              'Report',
              onTap: () {
                ReportHelper.showReportDialog(int.parse(viewController.session.id));
              },
            ),
          ],
        ),
      ),
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
            tail ?? Image.asset('packages/modules/assets/images/arrow_right.png', height: 16, width: 16),
          ],
        ),
      ),
    );
  }

  // Widget _buildBottomBar() {
  //   return Container(
  //     //30%的黑色到透明的渐变色
  //     width: double.infinity,
  //     decoration: BoxDecoration(
  //       gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xFF000000)]),
  //     ),
  //     child: SafeArea(
  //       bottom: true,
  //       child: Column(
  //         children: [
  //           Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  //             child: Row(
  //               children: [
  //                 Expanded(
  //                   child: Container(
  //                     height: 44,
  //                     decoration: BoxDecoration(color: const Color(0x66D8D8D8), borderRadius: BorderRadius.circular(8)),
  //                     child: TextField(
  //                       onSubmitted: (value) {
  //                         viewController.sendText(value);
  //                       },
  //                       style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
  //                       controller: viewController.textController,
  //                       focusNode: viewController.focusNode,
  //                       decoration: const InputDecoration(
  //                         enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
  //                         focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
  //                         fillColor: Colors.transparent,
  //                         filled: true,
  //                         hintText: 'Send message, reply by AI',
  //                         hintStyle: TextStyle(color: Color(0x80FFFFFF), fontWeight: FontWeight.w600, fontSize: 11),
  //                         contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 12),
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           Container(
  //             margin: const EdgeInsets.symmetric(horizontal: 48, vertical: 10),
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 GestureDetector(
  //                   onTap: () {
  //                     viewController.sendText('send me a picture');
  //                   },
  //                   child: Image.asset('packages/modules/assets/images/chat/req_image.png', width: 24, height: 24),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     viewController.sendText('Send a video to me');
  //                   },
  //                   child: Image.asset('packages/modules/assets/images/chat/req_video.png', width: 24, height: 24),
  //                 ),
  //                 GestureDetector(
  //                   onTap: () {
  //                     viewController.toCall();
  //                   },
  //                   child: Image.asset('packages/modules/assets/images/chat/chat_voice_call.png', width: 24, height: 24),
  //                 ),
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
            child: Container(
              width: 32,
              height: 44,
              alignment: Alignment.center,
              child: Image.asset('packages/modules/assets/images/icon_back.png', width: 24, height: 24),
            ),
          ),
          SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              Get.toNamed(Routers.person.name, arguments: {'personId': viewController.userId});
            },
            child: Container(
              width: 32,
              height: 32,
              padding: const EdgeInsets.all(1),
              decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
              child: ClipOval(clipBehavior: Clip.antiAlias, child: Image.network(viewController.session.avatar, width: 30, height: 30)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Flexible(child: Text(viewController.session.name, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))),
                SizedBox(width: 5),
                AppWidgets.userTag(viewController.session.accountType),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(color: Color(0xFF000000).withValues(alpha: 0.30), borderRadius: BorderRadius.circular(14)),
            child: Row(
              spacing: 6,
              children: [
                Image.asset('packages/modules/assets/images/gem.png', height: 16, width: 16),
                Obx(() => Text(MyAccount.gems.toString(), style: TextStyle(color: Colors.white, fontSize: 12))),
              ],
            ),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 7, vertical: 4),
            decoration: BoxDecoration(color: Color(0xFF000000).withValues(alpha: 0.30), borderRadius: BorderRadius.circular(14)),
            child: Row(
              spacing: 6,
              children: [
                Image.asset('packages/modules/assets/images/coin.png', height: 16, width: 16),
                Obx(() => Text(MyAccount.coins.toString(), style: TextStyle(color: Colors.white, fontSize: 12))),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
            icon: Image.asset('packages/modules/assets/images/more.png', width: 24, height: 24),
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
            SafeArea(
              bottom: false,
              child: Column(children: [_buildNavigationBar(), Obx(() => _buildChatRoomView()), ChatBottomBar()]),
            ),
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

    bool call = arguments['call'] ?? false;
    if (call) {
      toCall();
    }
  }

  onImagePrepared(Event event) {
    ChatMessage message = event.data['message'];
    //替换messages中的消息
    replaceMessage(message);
  }

  void toCall() {
    Get.toNamed(Routers.call.name, arguments: {'session': session.toRouter()});
  }

  @override
  void onReady() {
    super.onReady();
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
    String sessionJson = arguments['session'];
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
    }else if(message is ChatAudioMessage){
      ChatVoiceManager.instance.downloadSrc(message.audioUrl);
    }
  }

  Future<bool> unlockMessage(ChatMessage message) async {
    debugPrint('unlockMessage: $message');
    EasyLoading.show();
    ApiResponse response = await ChatManager.instance.unlockMessage(message);
    if (response.isSuccess) {
      ChatMessage newMessage = ChatMessage.fromServer(response.data['msg']);
      await downloadMessageResource(newMessage);
      await ChatManager.instance.messageHandler.insertMessage(newMessage);

      // 更新权益信息
      MyAccount.setPremInfo(response.data['ownPremiumInfo']);
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
      ChatMessage newMessage = ChatMessage.fromServer(response.data['msg']);
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
