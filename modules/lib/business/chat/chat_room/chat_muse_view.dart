import 'package:modules/base/crypt/security.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_service_export.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:modules/shared/widget/list_status_view.dart';

import '../chat_manager.dart';
import 'chat_room_view.dart';

class ChatMuseView extends StatelessWidget {
  ChatMuseView({super.key});

  ChatMuseViewController viewController = Get.put(ChatMuseViewController());
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: Color(0xB3150C09),
        child: SafeArea(
          bottom: true,
          child: Container(
            height: 192,
            padding: EdgeInsets.all(12),
            child: Obx(
              () => Stack(
                children: [
                  ListView.separated(
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(color: Color(0x59000000), borderRadius: BorderRadius.circular(12)),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(ImagePath.chat_tips_decoration_left, width: 32, height: 32),
                                Image.asset(ImagePath.chat_tips_decoration_right, width: 32, height: 32),
                              ],
                            ),

                            Container(
                              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                              alignment: Alignment.centerLeft,
                              child: Text(
                                viewController.items[index],
                                style: TextStyle(color: Color(0xFFFACFFF), fontWeight: FontWeight.w600, fontSize: 11, height: 1.8),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) => SizedBox(height: 8),
                    itemCount: viewController.items.length,
                  ),
                  ListStatusView(status: viewController.listStatus.value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChatMuseViewController extends GetxController {
  final items = <String>[].obs;
  var listStatus = ListStatus.idle.obs;
  @override
  void onInit() {
    super.onInit();
    getMuses();
    EventCenter.instance.addListener(kEventCenterDidReceivedNewMessages, onReceivedNewMessages);
  }

  void onReceivedNewMessages(event) {
    getMuses();
  }

  @override
  void onClose() {
    EventCenter.instance.addListener(kEventCenterDidReceivedNewMessages, onReceivedNewMessages);
    super.onClose();
  }

  void getMuses() async {
    if (items.isEmpty && listStatus.value != ListStatus.loading) {
      listStatus.value = ListStatus.loading;
    }

    ApiRequest request = ApiRequest(
      'queryInspirationWords',
      params: {Security.security_targetUid: Get.find<ChatRoomViewController>().userId, Security.security_sessionId: Get.find<ChatRoomViewController>().session.id},
    );

    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      List tips = response.data[Security.security_options] ?? [];
      items.value = tips.map((e) => e[Security.security_text] as String).toList();
      listStatus.value = items.isEmpty ? ListStatus.empty : ListStatus.success;
    } else {
      if (items.isEmpty) {
        listStatus.value = ListStatus.error;
      }
    }
  }
}
