import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/shared/widget/keep_alive_wrapper.dart';

import '../../../shared/app_theme.dart';
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

  final ChatHistoryViewController controller = Get.put(
    ChatHistoryViewController(),
  );

  List<ChatHistoryModel> models = [
    ChatHistoryModel(
      ChatMessageType.image,
      Security.security_Photos,
      () => KeepAliveWrapper(
        child: ChatCategoryView(category: ChatMessageType.image),
      ),
    ),
    ChatHistoryModel(
      ChatMessageType.video,
      Security.security_Videos,
      () => KeepAliveWrapper(
        child: ChatCategoryView(category: ChatMessageType.video),
      ),
    ),
  ];

  final index = 0.obs;
  PageController pageController = PageController();

  Widget _buildNavigator(int index) {
    return Center(
      child: Obx(
        () =>
            index == this.index.value
                ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      models[index].typeName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                      softWrap: true,
                    ),
                    Positioned(
                      bottom: -3,
                      right: 0,
                      child: Image.asset(
                        ImagePath.tab_selected,
                        height: 10,
                        width: 40,
                      ),
                    ),
                  ],
                )
                : Text(
                  models[index].typeName,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  void onPageChange(int index) {
    this.index.value = index;
    pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.linearToEaseOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base_background,
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: Container(
            alignment: Alignment.center,
            child: Image.asset(ImagePath.back, width: 24, height: 24),
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        title: Container(
          height: 36,
          margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              return GestureDetector(
                child: _buildNavigator(index),
                onTap: () {
                  onPageChange(index);
                },
              );
            },
            separatorBuilder: (context, index) {
              return const SizedBox(width: 24);
            },
            itemCount: models.length,
          ),
        ),
      ),
      body: Expanded(
        child: PageView.builder(
          itemBuilder: (context, index) {
            return models[index].builder();
          },
          itemCount: models.length,
          controller: pageController,
          onPageChanged: (int index) {
            onPageChange(index);
          },
        ),
      ),
    );
  }
}

class ChatHistoryViewController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }
}
