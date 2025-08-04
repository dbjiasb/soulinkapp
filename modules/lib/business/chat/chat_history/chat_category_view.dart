import 'package:modules/base/crypt/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:modules/business/chat/chat_room/chat_room_view.dart';
import 'package:modules/business/chat/chat_room_cells/chat_cell.dart';
import 'package:modules/business/chat/chat_room_cells/chat_message.dart';
import 'package:modules/shared/widget/list_status_view.dart';

import '../../../base/api_service/api_service_export.dart';
import '../chat_manager.dart';

class ChatCategoryView extends StatelessWidget {
  final ChatMessageType category;
  ChatCategoryView({super.key, required this.category}) {
    Get.put(ChatCategoryViewController(category: category), tag: 'ChatCategoryViewController_$category');
  }

  ChatCategoryViewController get controller => Get.find<ChatCategoryViewController>(tag: 'ChatCategoryViewController_$category');

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Stack(
        fit: StackFit.expand,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: MasonryGridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              itemCount: controller.items.length,
              itemBuilder: (context, index) {
                return ChatCell.create(controller.items[index], type: ChatCellType.category, unlock: controller.unlockMessage);
              },
            ),
          ),
          ListStatusView(status: controller.listStatus.value),
        ],
      ),
    );
  }
}

class ChatCategoryViewController extends GetxController {
  final ChatMessageType category;
  ChatCategoryViewController({required this.category});

  var listStatus = ListStatus.idle.obs;
  var items = [].obs;
  @override
  void onInit() {
    super.onInit();
    getMessages();
  }

  void getMessages() async {
    listStatus.value = ListStatus.loading;
    String sessionId = Get.find<ChatRoomViewController>().session.id;
    List<ChatMessage> messages = await ChatManager.instance.messageHandler.queryMessages(sessionId, types: [category.value]);
    items.value = messages;
    listStatus.value = messages.isEmpty ? ListStatus.empty : ListStatus.success;
  }

  Future<bool> unlockMessage(ChatMessage message) async {
    debugPrint('unlockMessage: $message');
    //TODO:
    EasyLoading.show();
    ApiResponse response = await ChatManager.instance.unlockMessage(message);
    if (response.isSuccess) {
      ChatMessage newMessage = ChatMessage.fromServer(response.data[Security.security_msg]);
      await ChatManager.instance.messageHandler.insertMessage(newMessage);
      EasyLoading.dismiss();
      replaceMessage(newMessage);
    } else {
      EasyLoading.showError(response.description);
    }
    return Future.value(response.isSuccess);
  }

  void replaceMessage(ChatMessage newMessage) {
    int index = items.indexWhere((element) => element.id == newMessage.id);
    if (index != -1) {
      items[index] = newMessage;
    }

    ChatRoomViewController chatRoomViewController = Get.find<ChatRoomViewController>();
    chatRoomViewController.replaceMessage(newMessage);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
