import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/business/account/account_view.dart';
import 'package:modules/business/chat/chat_sessions_view.dart';
import 'package:modules/business/home_page_lists/home_page.dart';
import 'package:modules/shared/widget/keep_alive_wrapper.dart';

class BottomBarItem {
  final String name;
  final Widget Function() builder;

  const BottomBarItem({required this.name, required this.builder});
}

class SkeletonView extends StatelessWidget {
  SkeletonView({super.key});

  SkeletonViewController viewController = Get.put(SkeletonViewController());

  Widget _buildIconButton(String icon, int index) {
    String normalIconPath = 'packages/modules/assets/images/bottom_bar_${icon}_normal.png';
    String selectedIconPath = 'packages/modules/assets/images/bottom_bar_${icon}_selected.png';

    return Obx(
      () => IconButton(
        onPressed: () {
          _onButtonClicked(index);
        },
        icon: Image.asset(normalIconPath),
        selectedIcon: Image.asset(selectedIconPath),
        iconSize: 32,
        isSelected: viewController.selectedIndex.value == index,
        highlightColor: Colors.transparent,
      ),
    );
  }

  void _onButtonClicked(int index) {
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
          return viewController.items[index].builder();
        },
      ),
      extendBody: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 42),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF4A4A5B), width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(30)),
            color: const Color(0xFF171425),
          ),
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
    );
  }
}

class SkeletonViewController extends GetxController {
  var selectedIndex = 0.obs;
  final PageController pageController = PageController();

  List<BottomBarItem> items = <BottomBarItem>[
    BottomBarItem(
      name: Security.security_list,
      builder: () {
        return KeepAliveWrapper(child: HomePageView());
      },
    ),
    BottomBarItem(
      name: Security.security_chat,
      builder: () {
        return KeepAliveWrapper(child: ChatSessionsView());
      },
    ),
    BottomBarItem(
      name: Security.security_personal,
      builder: () {
        return KeepAliveWrapper(child: AccountView());
      },
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
