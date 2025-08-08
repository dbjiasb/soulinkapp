import 'package:modules/base/crypt/copywriting.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';

import '../../shared/widget/keep_alive_wrapper.dart';
import './role_list_view.dart';
import 'role_manager.dart';

class RoleListItem {
  String title;
  final Widget Function() builder;

  RoleListItem(this.title, this.builder);
}

class HomePageView extends StatelessWidget {
  HomePageView({super.key});

  HomePageViewController viewController = Get.put(HomePageViewController());

  Widget _getItemAtIndex(int index) {
    return Center(
      child: Obx(
        () =>
            index == viewController.selectedIndex.value
                ? Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Text(
                      viewController.items[index].title,
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
                  viewController.items[index].title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
      ),
    );
  }

  void _onItemClicked(int index) {
    viewController.selectedIndex.value = index;
    viewController.pageController.jumpToPage(index);
  }

  void _onPageChange(int index) {
    viewController.selectedIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0B12),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              height: 36,
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: _getItemAtIndex(index),
                    onTap: () {
                      _onItemClicked(index);
                    },
                  );
                },
                separatorBuilder: (context, index) {
                  return const SizedBox(width: 24);
                },
                itemCount: viewController.items.length,
              ),
            ),

            Expanded(
              child: PageView.builder(
                itemBuilder: (context, index) {
                  return viewController.items[index].builder();
                },
                itemCount: viewController.items.length,
                controller: viewController.pageController,
                onPageChanged: (int index) {
                  _onPageChange(index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePageViewController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  PageController pageController = PageController();
  var selectedIndex = 0.obs;
  List<RoleListItem> items = [
    RoleListItem(
      Security.security_Discovery,
      () => KeepAliveWrapper(child: RoleListView(type: RoleListType.ai)),
    ),
    // RoleListItem(Security.security_Real, () => KeepAliveWrapper(child: RoleListView(type: RoleListType.real))),
    // RoleListItem(Security.security_OC, () => KeepAliveWrapper(child: RoleListView(type: RoleListType.custom_ai))),
    // RoleListItem(Copywriting.security_pro_only, () => KeepAliveWrapper(child: RoleListView(type: RoleListType.pro_only))),
  ];
}
