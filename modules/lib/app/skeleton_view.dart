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

  final CREATE_OC_INDEX = 1;

  Widget _buildIconButton(BottomBarItem item, int index) {

    final normalIcon = item.normalBuilder();
    final selectedIcon = item.selectedBuilder();

    return Obx(
      () => IconButton(
        onPressed: () {
          _onButtonClicked(index);
        },
        icon: normalIcon,
        selectedIcon: selectedIcon,
        isSelected: viewController.selectedIndex.value == index,
        highlightColor: Colors.transparent,
      ),
    );
  }

  void _onButtonClicked(int index) {
    if (index == CREATE_OC_INDEX) {
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
                      return _buildIconButton(e.value, e.key);
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
      selectedBuilder: () => Image.asset(ImagePath.home_selected, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.home_normal, width: 28, height: 28),
    ),
    BottomBarItem(
      name: 'create oc',
      pageBuilder: () {
        return Container();
      },
      selectedBuilder: () => Image.asset(ImagePath.create_oc, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.create_oc, width: 28, height: 28),
    ),
    BottomBarItem(
      name: Security.security_chat,
      pageBuilder: () {
        return KeepAliveWrapper(child: ChatSessionsView());
      },
      selectedBuilder: () => Image.asset(ImagePath.message_selected, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.message_normal, width: 28, height: 28),
    ),
    BottomBarItem(
      name: Security.security_personal,
      pageBuilder: () {
        return KeepAliveWrapper(child: AccountView());
      },
      selectedBuilder: () => Image.asset(ImagePath.personal_selected, width: 28, height: 28),
      normalBuilder: () => Image.asset(ImagePath.personal_normal, width: 28, height: 28),
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
