import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                ? ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      colors: <Color>[Color(0xFF8556FE), Color(0xFFF656FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds);
                  },
                  child: Text(viewController.items[index].title, style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w900)),
                )
                : Text(viewController.items[index].title, style: const TextStyle(color: Color(0x80FFFFFF), fontSize: 14, fontWeight: FontWeight.bold)),
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
    RoleListItem(Security.security_Discovery, () => KeepAliveWrapper(child: RoleListView(type: RoleListType.ai))),
    RoleListItem(Security.security_Real, () => KeepAliveWrapper(child: RoleListView(type: RoleListType.real))),
    RoleListItem(Security.security_OC, () => KeepAliveWrapper(child: RoleListView(type: RoleListType.custom_ai))),
    RoleListItem('Pro only', () => KeepAliveWrapper(child: RoleListView(type: RoleListType.pro_only))),
  ];
}
