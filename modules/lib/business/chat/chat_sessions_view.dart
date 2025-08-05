import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/shared/formatters/date_formatter.dart';
import 'package:modules/shared/widget/app_widgets.dart';
import 'package:modules/shared/widget/list_status_view.dart';

import '../../base/assets/image_path.dart';
import './chat_manager.dart';
import 'chat_session.dart';

class ChatSessionCell extends StatelessWidget {
  final ChatSession session;
  const ChatSessionCell(this.session, {super.key});

  Widget buildUnreadNumber() {
    if (session.unreadNumber.value > 0) {
      return Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
        alignment: Alignment.center,
        constraints: BoxConstraints(minWidth: 12, minHeight: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(4)), color: Color(0xFFFF425E)),
        child: Text(
          session.unreadNumber.value > 99 ? '99+' : session.unreadNumber.value.toString(),
          style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
        ),
      );
    } else {
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routers.chat.name, arguments: {Security.security_session: session.toRouter()});
      },
      child: Container(
        color: Colors.transparent, //不设置背景颜色，否则会影响点击事件，暂不清楚原因
        height: 68,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(shape: BoxShape.circle, image: DecorationImage(image: NetworkImage(session.avatar), fit: BoxFit.cover)),
            ),

            SizedBox(width: 10),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(child: Text(
                        session.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w500),
                      )),
                      SizedBox(width: 5),
                      AppWidgets.userTag(session.accountType)
                    ],
                  ),
                  Text(
                    session.lastMessageText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Color(0xFF9EA1A8), fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            SizedBox(width: 10),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(DateFormatter.diff(session.lastMessageTime), style: TextStyle(fontSize: 11, color: Color(0xFF9EA1A8), fontWeight: FontWeight.w500)),
                Obx(() => buildUnreadNumber()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatSessionsView extends StatelessWidget {
  ChatSessionsView({super.key});

  ChatSessionsViewController viewController = Get.put(ChatSessionsViewController());

  Widget appBarTitle() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text(Security.security_Message, style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900), softWrap: true),
        Positioned(bottom: -3, right: 0, child: Image.asset(ImagePath.home_list_selected, height: 10, width: 40)),
      ],
    );
  }

  Widget buildSessionCell(BuildContext context, int index) {
    return Container(height: 68, color: Colors.red);
  }

  @override
  build(context) {
    return Scaffold(backgroundColor: Color(0xFF0A0B12), appBar: AppBar(leading: Center(child: appBarTitle(),), leadingWidth: 108, toolbarHeight: 44, elevation: 0, backgroundColor: Colors.transparent), body: body());
  }

  Widget buildContentPage() {
    return Obx(
      () =>
          viewController.status.value == ListStatus.success
              ? ListView.builder(
                itemCount: viewController.sessions.length,
                itemBuilder: (context, index) {
                  return ChatSessionCell(viewController.sessions[index]);
                },
              )
              : ListStatusView(status: viewController.status.value),
    );
  }

  Widget body() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Column(children: [Expanded(child: buildContentPage())]),
      ],
    );
  }
}

class ChatSessionsViewController extends GetxController {
  var status = ListStatus.idle.obs;
  var sessions = [].obs;

  @override
  void onInit() {
    super.onInit();
    getSessions();
    listenEvents();
  }

  @override
  dispose() {
    removeEvents();
    super.dispose();
  }

  listenEvents() {
    EventCenter.instance.addListener(kEventCenterDidQueriedNewMessages, onQueriedNewMessage);
    EventCenter.instance.addListener(kEventCenterDidReceivedNewMessages, onReceivedNewMessages);
    EventCenter.instance.addListener(kEventCenterDidEnterChatRoom, onEnterRoom);
  }

  removeEvents() {
    EventCenter.instance.removeListener(kEventCenterDidQueriedNewMessages, onQueriedNewMessage);
    EventCenter.instance.removeListener(kEventCenterDidReceivedNewMessages, onReceivedNewMessages);
    EventCenter.instance.removeListener(kEventCenterDidEnterChatRoom, onEnterRoom);
  }

  void onEnterRoom(Event event) {
    ChatSession? currentSession = ChatManager.instance.currentSession;
    if (currentSession == null) return;
    for (var session in sessions) {
      if (session.id == currentSession.id) {
        session.unreadNumber.value = 0;
        ChatManager.instance.sessionHandler.upsertSession(session);
        break;
      }
    }
  }

  void onQueriedNewMessage(Event event) {
    getSessions();
  }

  void onReceivedNewMessages(Event event) async {
    ChatSession? currentSession = ChatManager.instance.currentSession;
    Map data = event.data;
    for (var item in data.entries) {
      var key = item.key;
      var value = item.value;
      if (key is! String || value is! List) continue;
      ChatSession? session = await ChatManager.instance.sessionHandler.querySession(key);
      if (session == null) continue;
      if (currentSession == null || currentSession.id != session.id) {
        session.unreadNumber.value = session.unreadNumber.value + value.length;
        await ChatManager.instance.sessionHandler.upsertSession(session);
      }
    }
    //这里先简单粗暴重查一遍
    getSessions();
  }

  void getSessions() async {
    if (status.value == ListStatus.loading) return;
    if (sessions.isEmpty) {
      status.value = ListStatus.loading;
    }

    List<ChatSession> results = await ChatManager.instance.sessionHandler.querySessions();
    sessions.clear();
    sessions.addAll(results);

    if (sessions.isEmpty) {
      status.value = ListStatus.empty;
    } else {
      status.value = ListStatus.success;
    }
  }
}
