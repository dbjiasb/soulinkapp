import 'package:modules/base/crypt/copywriting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_response.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/business/chat/chat_room/chat_room_view.dart';
import 'package:modules/business/chat/create_image/create_image_manager.dart';
import 'package:modules/shared/widget/balance_view.dart';
import 'package:modules/shared/widget/list_status_view.dart';

import '../../../shared/app_theme.dart';

class CreateImagePanel extends GetView<CreateImagePanelController> {
  CreateImagePanel({super.key});

  CreateImagePanelController get viewController => controller;

  Widget buildTabBar() {
    return ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: viewController.config.value.prompts.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            if (viewController.selectedIndex.value != index) {
              viewController.selectedIndex.value = index;
              viewController.pageController.jumpToPage(index);
            }
          },
          child: Center(
            child: Obx(
              () => Container(
                decoration:
                    (index == viewController.selectedIndex.value)
                        ? BoxDecoration(
                          color: const Color(0xFFF5E5FF),
                          borderRadius: BorderRadius.circular(8),
                        )
                        : null,
                padding:
                    (index == viewController.selectedIndex.value)
                        ? const EdgeInsets.symmetric(horizontal: 8)
                        : EdgeInsets.zero,
                alignment: Alignment.center,
                child: Text(
                  viewController.config.value.prompts[index].name,
                  style: TextStyle(
                    fontSize: 13,
                    color:
                        (index == viewController.selectedIndex.value)
                            ? AppColors.primary
                            : const Color(0xFFC1C1C2),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(width: 24);
      },
    );
  }

  Widget buildTabBarView() {
    return PageView.builder(
      controller: viewController.pageController,
      onPageChanged: (index) {
        viewController.selectedIndex.value = index;
      },
      itemBuilder: (context, index) {
        return Column(
          children: [
            Flexible(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: const Color(0xFFF1F0F4),
                ),
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        viewController.config.value.prompts[index].tags
                            .map(
                              (e) => GestureDetector(
                                onTap: () {
                                  if (viewController
                                          .config
                                          .value
                                          .prompts[index]
                                          .selectedItem
                                          .value ==
                                      e) {
                                    viewController
                                        .config
                                        .value
                                        .prompts[index]
                                        .selectedItem
                                        .value = null;
                                  } else {
                                    viewController
                                        .config
                                        .value
                                        .prompts[index]
                                        .selectedItem
                                        .value = e;
                                  }
                                },
                                child: Obx(
                                  () => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration:
                                        (e ==
                                                viewController
                                                    .config
                                                    .value
                                                    .prompts[index]
                                                    .selectedItem
                                                    .value)
                                            ? BoxDecoration(
                                              color: const Color(0xFF7D2DFF),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            )
                                            : BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Color(0xFFE2DFE5),
                                            ),
                                    child: Text(
                                      e[Security.security_desc] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                        color:
                                            (e ==
                                                    viewController
                                                        .config
                                                        .value
                                                        .prompts[index]
                                                        .selectedItem
                                                        .value)
                                                ? Colors.white
                                                : const Color(0xFF999999),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      itemCount: viewController.config.value.prompts.length,
    );
  }

  Widget buildCreateImageButton() {
    return SafeArea(
      bottom: true,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: GestureDetector(
          onTap: () {
            viewController.createImage();
          },
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  Security.security_Create,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Image.asset(
                    viewController.currencyIcon,
                    width: 16,
                    height: 16,
                  ),
                ),
                Text(
                  viewController.price.toString(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        height: 488,
        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 52,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        Copywriting.security_create_images_that_you_like,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      BalanceView(
                        type: BalanceType.coin,
                        style: BalanceViewStyle(
                          color: AppColors.primary,
                          bgColor: Color(0xFFF1F0F4),
                          borderRadius: 8,
                          height: 24,
                          padding: 8,
                        ),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: Color(0xFFF1F0F4)),

                SizedBox(height: 12),
                SizedBox(height: 28, child: Obx(() => buildTabBar())),
                SizedBox(height: 12),

                Expanded(child: Obx(() => buildTabBarView())),

                Obx(
                  () =>
                      viewController.listStatus.value == ListStatus.success
                          ? buildCreateImageButton()
                          : SizedBox.shrink(),
                ),
              ],
            ),
            Obx(() => ListStatusView(status: viewController.listStatus.value)),
          ],
        ),
      ),
    );
  }
}

class CreateImagePanelController extends GetxController {
  var listStatus = ListStatus.idle.obs;
  var config = CreateImageConfig.none().obs;
  var selectedIndex = 0.obs;
  var pageController = PageController();

  int get price {
    return config.value.price;
  }

  String get currencyIcon {
    if (config.value.type == 1) {
      return ImagePath.gem;
    } else {
      return ImagePath.coin;
    }
  }

  @override
  void onInit() {
    super.onInit();
    getCreateImageConfigs();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void getCreateImageConfigs() async {
    if (config.value.prompts.isEmpty &&
        listStatus.value != ListStatus.loading) {
      listStatus.value = ListStatus.loading;
    }

    int userId = Get.find<ChatRoomViewController>().userId;

    CreateImageConfig result = await CreateImageManager.instance
        .getCreateImageConfigs(userId);

    if (result.success) {
      listStatus.value =
          result.prompts.isEmpty ? ListStatus.empty : ListStatus.success;
      if (result.prompts.isNotEmpty) {
        selectedIndex.value = 0;
      }
    } else {
      listStatus.value = ListStatus.error;
    }
    config.value = result;
  }

  void createImage() async {
    List options = [];
    for (var element in config.value.prompts) {
      if (element.selectedItem.value != null) {
        options.add(element.selectedItem.value);
      }
    }

    if (options.isEmpty) return;

    EasyLoading.show(status: Copywriting.security_generating_in_progress);
    ApiResponse response = await CreateImageManager.instance.createImage(
      Get.find<ChatRoomViewController>().userId,
      options,
    );
    if (response.isSuccess) {
      EasyLoading.dismiss();
      //关闭弹窗
      Get.back();
    } else {
      EasyLoading.showError(response.description);
    }
  }
}
