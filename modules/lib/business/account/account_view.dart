import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/business/home_page_lists/role_manager.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/util/es_helper.dart';
import 'package:modules/shared/app_theme.dart';
import 'package:modules/shared/widget/app_widgets.dart';
import 'package:modules/shared/widget/avatar_view.dart';

import '../../shared/interactions.dart';
import '../../shared/widget/list_status_view.dart';

class AccountView extends StatelessWidget {
  AccountView({super.key});

  final AccountViewController controller = Get.put(AccountViewController());

  String get avatarUrl => MyAccount.avatar;

  String get nickname => MyAccount.name;

  String get ID => MyAccount.id;

  // final myPremium = PremiumService.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图
          Positioned.fill(child: Image.asset(ImagePath.person_head_bg, fit: BoxFit.cover)),

          // 主体内容
          Positioned(
            left: 0,
            top: 180,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(color: Color(0xFF070512), borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
              padding: EdgeInsets.only(left: 16, right: 16, top: 50),
              child: body(),
            ),
          ),

          // 顶栏
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    _buildCurrencyItem(0),
                    Spacer(),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(Routers.setting.name);
                      },
                      child: Image.asset(ImagePath.setting, height: 32, width: 32),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 头像
          Positioned(left: 16, top: 144, child: AvatarView(url: avatarUrl, size: 72)),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(int type){
    return GestureDetector(
      onTap: (){
        Get.toNamed(Routers.rechargeCurrency.name, arguments: {EncHelper.rcg_rcgTyp: type});
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: Color(0xff1E1C2A).withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Image.asset(type == 1?ImagePath.gem:ImagePath.coin, height: 20, width: 20),
            SizedBox(width: 4),
            Obx(() => Text(
              '${type == 1?MyAccount.gems:MyAccount.coins}',
              style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            )),
            SizedBox(
              width: 2,
            ),
            Image.asset(ImagePath.boarder_add, height: 16, width: 16),
          ],
        ),
      ),
    );
  }

  Widget body() {
    return Column(spacing: 16, children: [InfoArea(), Expanded(child: CompanionsArea())]);
  }

  Widget InfoArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: 8,
          children: [
            Obx(() => Text(nickname, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
              child: Row(
                spacing: 2,
                children: [
                  Text('ID:$ID', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w500)),
                  GestureDetector(
                    onTap: () {
                      Interactions.copyToClipboard(ID.toString());
                    },
                    child: Image.asset(ImagePath.copy, height: 14, width: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Get.toNamed(Routers.editMe.name);
          },
          child: Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Color(0xFF272533)),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Center(
              child: Row(
                spacing: 4,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 14),
                  Text('Edit', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget CompanionsArea() {
    return Column(
      spacing: 16,
      children: [
        Row(
          children: [
            SizedBox(
              height: 20,
              width: 92,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(left: 0, child: Text('Companions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                  Positioned(right: 0, bottom: -5, child: Image.asset(ImagePath.tab_selected, width: 40, height: 10)),
                ],
              ),
            ),
          ],
        ),

        Expanded(
          child: Obx(
            () =>
                controller._loadingCompanions.value == true
                    ? Center(child: CircularProgressIndicator())
                    : controller.myCompanions.isEmpty
                    ? _buildEmptyView()
                    : RefreshIndicator(
                      onRefresh: controller.initCollections,
                      child: Obx(
                        () =>
                            controller.status.value == ListStatus.success
                                ? GridView.builder(
                              controller: controller.scrollController,
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 8,
                                    mainAxisSpacing: 8,
                                    childAspectRatio: 168 / 274,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _buildCompanionItem(controller.myCompanions[index]);
                                  },
                                  itemCount: controller.myCompanions.length,
                                )
                                : ListStatusView(status: controller.status.value, emptyDesc: 'No chat partner has been initiated yet'),
                      ),
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanionItem(dynamic companion) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onToChatTap(companion[EncHelper.ac_uid].toString(), companion[EncHelper.ac_nn], companion[EncHelper.ac_avt], companion[EncHelper.ac_cvu]);
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(image: CachedNetworkImageProvider(companion['coverUrl']), fit: BoxFit.cover),
        ),
        child: Column(
          children: [
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(image: AssetImage(ImagePath.person_img_mask), fit: BoxFit.cover),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    alignment: WrapAlignment.start,
                    children: [
                      Text(companion['nickname'], style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                      AppWidgets.userTag(companion['accountType']),
                    ],
                  ),
                  Text(companion['bio'], style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500), maxLines: 3),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onToChatTap(String id, String name, String avatarUrl, String coverUrl) {
    Get.toNamed(
      Routers.chat.name,
      arguments: {
        Security.security_session: jsonEncode({
          Security.security_id: id,
          Security.security_name: name,
          Security.security_avatar: avatarUrl,
          Security.security_backgroundUrl: coverUrl,
        }),
        Security.security_call: false,
      },
    );
  }

  Widget _buildEmptyView() {
    return Center(child: Text('No companions yet', style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 12)));
  }
}

class AccountViewController extends GetxController {
  static const ONLY_CUSTOM_AI = 4;
  static const PAGE_SIZE = 100;


  final myCompanions = [].obs;

  var poolVer = 0;
  var pageIdx = 0;
  var hasMore = true;
  var status = ListStatus.idle.obs;

  ScrollController scrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    initCollections();
    refreshMyInfo();
    scrollController.addListener(onScrollToBottom);
  }

  @override
  void dispose() {
    scrollController.removeListener(onScrollToBottom);
    super.dispose();
  }

  void onScrollToBottom() {
    if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
      fetchMyCompanions();
    }
  }

  final _loadingCompanions = false.obs;

  Future<void> onRefresh() async {
    pageIdx = 0;
    hasMore = true;
    myCompanions.clear();
    fetchMyCompanions();
  }

  Future initCollections() async {
    myCompanions.clear();
    poolVer = 0;
    pageIdx = 0;
    hasMore = true;
    status.value = ListStatus.idle;

    _loadingCompanions.value = true;
    await fetchMyCompanions();
    _loadingCompanions.value = false;
    status.value = myCompanions.isEmpty ? ListStatus.empty : ListStatus.success;

  }

  Future fetchMyCompanions() async {
    if (!hasMore) return;
    final rsp = await RoleManager.instance.getRoleList();
    if (rsp.isSuccess) {
      poolVer = rsp.data[Security.security_poolVersion];
      hasMore = rsp.data[Security.security_hasMore];
      pageIdx++;

      myCompanions.addAll(rsp.data[Security.security_param] ?? []);
      myCompanions.refresh();
    }
  }

  void refreshMyInfo() {
    AccountService.instance.getMyPremInfo();
    AccountService.instance.refreshBalance();
  }
}
