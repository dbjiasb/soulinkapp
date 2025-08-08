import 'package:modules/base/crypt/copywriting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/business/account/account_view.dart';
import 'package:modules/business/chat/chat_sessions_view.dart';
import 'package:modules/business/create_center/create_oc_dialog.dart';
import 'package:modules/business/home_page_lists/home_page.dart';
import 'package:modules/shared/widget/keep_alive_wrapper.dart';

class BottomBarItem {
  final String name;
  final Widget Function() pageBuilder;
  final Widget Function() selectedBuilder;
  final Widget Function() normalBuilder;

  const BottomBarItem({required this.name, required this.pageBuilder, required this.selectedBuilder, required this.normalBuilder});
}

class SkeletonView extends StatelessWidget {
  SkeletonView({super.key});

  SkeletonViewController viewController = Get.put(SkeletonViewController());

  Widget _buildIconButton(String icon, int index) {
    String normalIconPath = '';
    String selectedIconPath = '';
    if (icon == Security.security_chat) {
      normalIconPath = ImagePath.bottom_bar_chat_normal;
      selectedIconPath = ImagePath.bottom_bar_chat_selected;
    } else if (icon == Security.security_list) {
      normalIconPath = ImagePath.bottom_bar_list_normal;
      selectedIconPath = ImagePath.bottom_bar_list_selected;
    } else if (icon == Security.security_personal) {
      normalIconPath = ImagePath.bottom_bar_personal_normal;
      selectedIconPath = ImagePath.bottom_bar_personal_selected;
    } else if (icon == Security.security_createoc) {
      normalIconPath = ImagePath.bottom_bar_create_oc_entry;
      selectedIconPath = ImagePath.bottom_bar_create_oc_entry;
    } else {
      throw Exception('Unknown icon: $icon');
    }

    return Obx(
      () => IconButton(
        onPressed: () {
          _onButtonClicked(index);
        },
        icon: Image.asset(normalIconPath, width: 28, height: 28),
        selectedIcon: Image.asset(selectedIconPath, width: 28, height: 28),
        isSelected: viewController.selectedIndex.value == index,
        highlightColor: Colors.transparent,
      ),
    );
  }

  void _onButtonClicked(int index) {
    if (index == 1) {
      // oc 入口
      CreateOcDialog.show();
      return;
    }
    viewController.pageController.jumpToPage(index);
    viewController.selectedIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: viewController.pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: viewController.items.length,
        itemBuilder: (context, index) {
          return viewController.items[index].pageBuilder();
        },
      ),
      extendBody: true,
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4B485B), width: 0.5),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            color: const Color(0xFF05030D),
          ),
          child: SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 50),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:
                    viewController.items.asMap().entries.map((e) {
                      return _buildIconButton(e.value.name, e.key);
                    }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SkeletonViewController extends GetxController {
  var selectedIndex = 0.obs;
  final PageController pageController = PageController();

  List<BottomBarItem> items = <BottomBarItem>[
    BottomBarItem(
      name: Security.security_list,
      pageBuilder: () {
        return KeepAliveWrapper(child: HomePageView());
      },
      selectedBuilder: () => Image.asset(ImagePath.bottom_bar_list_selected, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.bottom_bar_list_normal, width: 28, height: 28),
    ),
    BottomBarItem(
      name: Security.security_createoc,
      pageBuilder: () {
        return Container();
      },
      selectedBuilder: () => Image.asset(ImagePath.bottom_bar_create_oc_entry, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.bottom_bar_create_oc_entry, width: 28, height: 28),
    ),
    BottomBarItem(
      name: Security.security_chat,
      pageBuilder: () {
        return KeepAliveWrapper(child: ChatSessionsView());
      },
      selectedBuilder: () => Image.asset(ImagePath.bottom_bar_chat_selected, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.bottom_bar_chat_normal, width: 28, height: 28),
    ),
    BottomBarItem(
      name: Security.security_personal,
      pageBuilder: () {
        return KeepAliveWrapper(child: AccountView());
      },
      selectedBuilder: () => Image.asset(ImagePath.bottom_bar_personal_selected, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.bottom_bar_personal_normal, width: 28, height: 28),
    ),
  ];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
