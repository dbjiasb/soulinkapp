import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/shared/widget/keep_alive_wrapper.dart';

import '../chat_room_cells/chat_message.dart';
import './chat_category_view.dart';

class ChatHistoryModel {
  ChatMessageType type;
  String typeName;
  Widget Function() builder;
  ChatHistoryModel(this.type, this.typeName, this.builder);
}

class ChatHistoryView extends StatelessWidget {
  ChatHistoryView({super.key});
  final ChatHistoryViewController controller = Get.put(ChatHistoryViewController());

  List<ChatHistoryModel> models = [
    ChatHistoryModel(ChatMessageType.image, 'Photos', () => KeepAliveWrapper(child: ChatCategoryView(category: ChatMessageType.image))),
    ChatHistoryModel(ChatMessageType.video, 'Videos', () => KeepAliveWrapper(child: ChatCategoryView(category: ChatMessageType.video))),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: models.length,
      child: Scaffold(
        backgroundColor: Color(0xFF171425),
        appBar: AppBar(
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(alignment: Alignment.center, child: Image.asset('packages/modules/assets/images/icon_back.png', width: 24, height: 24)),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Center(
            child: TabBar(
              isScrollable: true,
              splashFactory: NoSplash.splashFactory, // 禁用水纹效果
              overlayColor: MaterialStateProperty.all(Colors.transparent), // 覆盖点击效果,
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Color(0xFFE962F6),
                  width: 2, // 高度
                ),
                borderRadius: BorderRadius.circular(1),
                insets: EdgeInsets.symmetric(horizontal: 18), // 左右缩进控制实际宽度
              ),
              indicatorSize: TabBarIndicatorSize.label, // 必须设置为label模式
              indicatorPadding: EdgeInsets.only(bottom: 8), // 宽度控制
              dividerColor: Colors.transparent,
              labelPadding: EdgeInsets.symmetric(horizontal: 12),
              labelStyle: TextStyle(color: Color(0xFFFFFFFF), fontSize: 16, fontWeight: FontWeight.bold),
              unselectedLabelStyle: TextStyle(color: Color(0x33FFFFFF), fontSize: 16, fontWeight: FontWeight.bold),
              tabs: models.map((e) => Tab(text: e.typeName)).toList(),
            ),
          ),
        ),
        body: TabBarView(children: models.map((e) => e.builder()).toList()),
      ),
    );
  }
}

class ChatHistoryViewController extends GetxController {
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  @override
  void onClose() {
    // TODO: implement onClose
    super.onClose();
  }
}
