import 'package:modules/base/crypt/apis.dart';
import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:modules/base/crypt/constants.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:modules/base/preferences/preferences.dart';
import 'package:modules/base/push_service/push_service.dart';
import 'package:modules/business/chat/chat_session.dart';
import 'package:modules/core/account/account_service.dart';

import '../../base/api_service/api_service_export.dart';
import './chat_message_handler.dart';
import './chat_session_handler.dart';
import 'chat_room_cells/chat_message.dart';

String kEventCenterDidPreparedImageMessage =
    Security.security_kEventCenterDidPreparedImageMessage;

String kEventCenterDidQueriedNewMessages =
    Security.security_kEventCenterDidQueriedNewMessages;
String kEventCenterDidReceivedNewMessages =
    Security.security_kEventCenterDidReceivedNewMessages;

String kEventCenterDidEnterChatRoom =
    Security.security_kEventCenterDidEnterChatRoom;
String kEventCenterWillExitChatRoom =
    Security.security_kEventCenterWillExitChatRoom;

//扩展ChatSession类，新增已发送消息id数组
final _sentMessages = Expando<Set<int>>();

extension ChatSessionExt on ChatSession {
  // 修改返回类型为 Set<int>
  Set<int> get sentMessages {
    if (_sentMessages[this] == null) {
      _sentMessages[this] = {};
    }
    return _sentMessages[this]!;
  }

  // 修改参数类型为 Set<int>
  set sentMessages(Set<int> sentMessages) {
    _sentMessages[this] = sentMessages;
  }
}

class SendMessageResponse {
  ApiResponse response;
  ChatMessage message;

  SendMessageResponse(this.response, this.message);

  bool get isSuccess => response.isSuccess;
}

class ChatManager {
  //单利模式
  static final ChatManager _instance = ChatManager._internal();

  ChatManager._internal();

  factory ChatManager() => _instance;

  static ChatManager get instance => _instance;

  ChatSessionHandler sessionHandler = ChatSessionHandler();
  ChatMessageHandler messageHandler = ChatMessageHandler();

  int get accountId => AccountService.instance.account.userId;

  String get messagePullTag => 'message_pull_tag_$accountId';
  String lastPullTag = '';
  bool isQueryingMessages = false;

  bool get loggedIn => AccountService.instance.loggedIn;

  //当前会话
  ChatSession? _currentSession;

  set currentSession(ChatSession? session) {
    if (_currentSession == session) return;
    if (_currentSession != null) {
      //退房通知
      EventCenter.instance.sendEvent(kEventCenterWillExitChatRoom, {});
    }
    _currentSession = session;
    if (_currentSession != null) {
      // 进房通知
      EventCenter.instance.sendEvent(kEventCenterDidEnterChatRoom, {});
    }
  }

  ChatSession? get currentSession => _currentSession;

  void init() {
    if (loggedIn) {
      getMessages();
    }

    listenEvents();
  }

  void getMessages() {
    lastPullTag = Preferences.instance.getString(messagePullTag) ?? '';
    getHistoryMessages();
    startTimer();
  }

  //监听登录、注销事件
  void listenEvents() {
    EventCenter.instance.addListener(kEventCenterUserDidLogin, (data) {
      getMessages();
    });
    EventCenter.instance.addListener(kEventCenterUserDidLogout, (data) {
      stopTimer();
    });

    EventCenter.instance.addListener(
      kEventCenterDidPushNewMessages,
      onReceivedNewMessages,
    );
  }

  void onLogin(Event event) {
    getMessages();
  }

  void onLogout(Event event) {
    stopTimer();
  }

  void dispose() {
    //释放资源
    stopTimer();
    EventCenter.instance.removeListener(kEventCenterUserDidLogin, onLogin);
    EventCenter.instance.removeListener(kEventCenterUserDidLogout, onLogout);
    EventCenter.instance.removeListener(
      kEventCenterDidPushNewMessages,
      onReceivedNewMessages,
    );
  }

  Future<void> onImagePrepared(Map data) async {
    ChatMessage message = ChatMessage.fromServer(data);
    await messageHandler.insertMessage(message);
    //刷新图片
    EventCenter.instance.sendEvent(kEventCenterDidPreparedImageMessage, {
      Security.security_message: message,
    });
  }

  void onReceivedNewMessages(Event event) async {
    PushObject object = event.data[Security.security_userInfo] as PushObject;

    //TODO: 待重构
    if (object.type == 100000 + 4) {
      //刷新图片
      onImagePrepared(object.data);
      return;
    } else if (object.type == 100000 + 100001) {
      getHistoryMessages();
      return;
    }

    if (object.type != PushId.kBatchMessageKey) return;
    Map data = object.data;
    if (data.isEmpty) return;

    int lastMessageId = data[Constants.newestTag] ?? 0;

    ChatMessage? lastMessage = await messageHandler.selectMessage(
      lastMessageId,
    );
    if (lastMessage == null) {
      getHistoryMessages();
      return;
    }

    List rawList = data[Constants.messages] ?? [];
    if (rawList.isEmpty) return;

    ChatMessage firstMessage = ChatMessage.fromServer(rawList.first);
    ChatSession? session = await sessionHandler.querySession(
      firstMessage.sessionId,
    );
    if (session == null) {
      getHistoryMessages();
      return;
    }

    //遍历rawList，构造ChatMessage，并过滤shouldIgnoreMessage
    List<ChatMessage> messages = [];
    ChatMessage? newestMessage;
    for (var rawMessage in rawList) {
      ChatMessage message = ChatMessage.fromServer(rawMessage);
      if (newestMessage == null || message.date.isAfter(newestMessage.date)) {
        newestMessage = message;
      }
      //屏蔽礼物消息
      if (message.type == ChatMessageType.gift ||
          shouldIgnoreMessage(message)) {
        // debugPrint('[ChatManager] [shouldIgnoreMessage] ${message.id.toString()} type:${message.type.value}');
        continue;
      }
      //插入消息
      int result = await messageHandler.insertMessage(message);
      messages.add(message);
    }

    if (newestMessage != null) {
      debugPrint(
        '[${DateTime.now()}] [ChatManager] [PullTag] [onReceivedNewMessages] ${newestMessage.id.toString()}',
      );
      storePullTag(newestMessage.id.toString());
    }

    if (messages.isEmpty) {
      return;
    }

    ChatMessage newest = messages.last;
    session.lastMessageText = newest.externalText;
    session.lastMessageTime = newest.date;

    await sessionHandler.upsertSession(session);

    EventCenter.instance.sendEvent(kEventCenterDidReceivedNewMessages, {
      session.id: messages,
    });
  }

  //发送消息
  Future<SendMessageResponse> sendMessage(ChatMessage message) async {
    ApiRequest request = ApiRequest(
      Apis.security_sendChatMsg,
      params: {Security.security_msg: message.toServer()},
    );
    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      ChatMessage newMessage = ChatMessage.fromServer(
        response.data[Security.security_msg],
      );
      int result = await messageHandler.updateLocalMessage(newMessage);
      debugPrint('插入消息结果: $result');
      addSentMessages(newMessage);
      return SendMessageResponse(response, newMessage);
    } else {
      message.sendState.value = ChatMessageSendStatus.failed;
      int result = await messageHandler.updateLocalMessage(message);
      debugPrint('发送消息失败: ${response.description}');
    }
    return SendMessageResponse(response, message);
  }

  void addSentMessages(ChatMessage message) {
    if (currentSession == null) return;
    if (currentSession!.id != message.sessionId) return;
    if (currentSession!.sentMessages.contains(message.id)) return;

    currentSession!.sentMessages.add(message.id);
    printSentMessages();
  }

  void printSentMessages() {
    if (currentSession == null) return;
    debugPrint('已发送消息: ${currentSession!.sentMessages}');
  }

  bool isSentMessage(ChatMessage message) {
    if (currentSession == null) return false;
    if (currentSession!.id != message.sessionId) return false;
    return currentSession!.sentMessages.contains(message.id);
  }

  Future<void> getHistoryMessages() async {
    if (isQueryingMessages) return;

    isQueryingMessages = true;
    debugPrint(
      '[${DateTime.now()}] [ChatManager] [PullTag] getHistoryMessages: $lastPullTag ',
    );
    ApiRequest request = ApiRequest(
      Apis.security_syncChatHistory,
      params: {Security.security_position: lastPullTag},
    );
    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      await handleApiResponse(response);
    } else {
      debugPrint('获取历史消息失败: ${response.description}');
    }

    isQueryingMessages = false;

    bool hasMore = response.data[Security.security_hasMore] == 1;
    if (hasMore) {
      getHistoryMessages();
    } else {}
  }

  //处理ApiResponse
  Future<void> handleApiResponse(ApiResponse response) async {
    //取出会话
    List rawSessions = response.data[Constants.rawSessions] ?? [];
    if (rawSessions.isEmpty) return;

    List<ChatMessage> messages = [];
    //取出消息
    for (var rawSession in rawSessions) {
      List rawMessages = rawSession[Constants.rawItems] ?? [];
      if (rawMessages.isEmpty) continue;

      for (var rawMessage in rawMessages) {
        ChatMessage message = ChatMessage.fromServer(rawMessage);
        if (shouldIgnoreMessage(message)) {
          // debugPrint('[ChatManager] [shouldIgnoreMessage] ${message.id.toString()} type:${message.type.value}');
          continue;
        }

        //插入消息
        int result = await messageHandler.insertMessage(message);
        messages.add(message);
      }

      if (messages.isEmpty) continue;

      late ChatSession session;
      ChatMessage lastMessage = messages.last;
      ChatSession? localSession = await sessionHandler.querySession(
        lastMessage.sessionId,
      );
      if (localSession != null) {
        localSession.lastMessageText = lastMessage.externalText;
        localSession.lastMessageTime = lastMessage.date;
        session = localSession;
      } else {
        session = ChatSession(
          id: rawSession[Security.security_id].toString(),
          name: rawSession[Security.security_title],
          avatar: rawSession[Security.security_icon],
          lastMessageTime: lastMessage.date,
          lastMessageText: lastMessage.externalText,
          accountType: rawSession[Security.security_acctType] ?? 1,
        );
      }

      await sessionHandler.upsertSession(session);

      EventCenter.instance.sendEvent(kEventCenterDidQueriedNewMessages, {
        session.id: messages,
      });

      storePullTag(response.data[Constants.pullTag] ?? '');
    }
  }

  bool shouldIgnoreMessage(ChatMessage message) {
    return !supportedMessageTypes.contains(message.type) ||
        isSentMessage(message);
  }

  Set<ChatMessageType> supportedMessageTypes = {
    ChatMessageType.text,
    ChatMessageType.call,
    ChatMessageType.image,
    ChatMessageType.video,
    ChatMessageType.gift,
  };

  void storePullTag(String pullTag) {
    debugPrint('[ChatManager] storePullTag: $pullTag');
    if (pullTag.isEmpty) return;

    int newKey = int.tryParse(pullTag) ?? 0;
    int oldKey = int.tryParse(lastPullTag) ?? 0;

    if (newKey <= oldKey) return;

    lastPullTag = pullTag;
    Preferences.instance.setString(messagePullTag, pullTag);
    debugPrint(
      '[${DateTime.now()}] [ChatManager] [PullTag] storePullTag: $pullTag [$lastPullTag]',
    );
  }

  //定时器
  Timer? timer;

  void startTimer() {
    stopTimer();
    timer = Timer.periodic(const Duration(seconds: 20), (timer) {
      onTimeout();
    });
  }

  void onTimeout() {
    //超时处理
    getHistoryMessages();
  }

  void stopTimer() {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
      timer = null;
    }
  }

  void sayHelloIfNeeded(ChatSession session) async {
    //发送消息
    ApiRequest request = ApiRequest(
      Apis.security_sayHello,
      params: {
        Security.security_userId: int.tryParse(session.id),
        Security.security_toGroup: [0],
        Security.security_status: 2,
      },
    );
    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      //处理响应
      session.greeted = true;

      int result = await sessionHandler.upsertSession(session);
      debugPrint('insert session:${session.id} result:$result');
    } else {
      debugPrint('sayHelloIfNeeded failed: ${response.description}');
    }
  }

  Future<ApiResponse> unlockMessage(ChatMessage message) async {
    var usePrem = 0;
    // if (MyAccount.isWkPrem && MyAccount.freeAdoLeftTimes > 0 || MyAccount.isMthPrem || MyAccount.isYrPrem) {
    //   usePrem = 1;
    // }
    ApiRequest request = ApiRequest(
      Apis.security_deblockingMessage,
      params: {
        Security.security_mid: message.uuid,
        Security.security_usePrem: usePrem,
      },
    );
    return await ApiService.instance.sendRequest(request);
  }

  Future<ApiResponse> reloadMessage(ChatMessage message) async {
    ApiRequest request = ApiRequest(
      Apis.security_replaceMsg,
      params: {
        Security.security_uuid: message.uuid,
        Security.security_action: 1,
      },
    );
    return await ApiService.instance.sendRequest(request);
  }
}
