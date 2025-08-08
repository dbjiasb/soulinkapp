import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/copywriting.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/business/home_page_lists/role_manager.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/util/es_helper.dart';
import 'package:modules/shared/app_theme.dart';
import 'package:modules/shared/widget/app_widgets.dart';
import 'package:modules/shared/widget/avatar_view.dart';
import 'package:modules/shared/widget/balance_view.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../../core/util/calendar_helper.dart';
import '../../shared/interactions.dart';
import '../../shared/widget/list_status_view.dart';
import '../purchase/premium_service.dart';

class AccountView extends StatelessWidget {
  AccountView({super.key});

  final AccountViewController controller = Get.put(AccountViewController());

  String get avatarUrl => MyAccount.avatar;

  String get nickname => MyAccount.name;

  String get ID => MyAccount.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 背景图
          Positioned.fill(
            child: Image.asset(ImagePath.person_head_bg, fit: BoxFit.cover),
          ),

          // 主体内容
          Positioned(
            left: 0,
            top: 180,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.base_background,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
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
                        Get.toNamed(Routers.setting);
                      },
                      child: Image.asset(
                        ImagePath.setting,
                        height: 32,
                        width: 32,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 头像
          Positioned(
            left: 16,
            top: 144,
            child: AvatarView(url: avatarUrl, size: 72),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyItem(int type) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(
          Routers.rechargeCurrency,
          arguments: {EncHelper.rcg_rcgTyp: type},
        );
      },
      child: BalanceView(
        type: type == 0 ? BalanceType.coin : BalanceType.gem,
        style: BalanceViewStyle(
          color: Colors.white,
          bgColor: Color(0xff1E1C2A).withValues(alpha: 0.5),
          height: 30,
          borderRadius: 12,
          padding: 8,
        ),
      ),
    );
  }

  Widget body() {
    return Column(
      spacing: 16,
      children: [
        InfoArea(),
        // PremiumArea(),
        Expanded(child: CompanionsArea()),
      ],
    );
  }

  Widget InfoArea() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          spacing: 8,
          children: [
            Obx(
              () => Text(
                nickname.isNotEmpty ? nickname : 'user',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                spacing: 2,
                children: [
                  Text(
                    'ID:$ID',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
            Get.toNamed(Routers.editMe);
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Color(0xFF272533),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Center(
              child: Row(
                spacing: 4,
                children: [
                  Icon(Icons.edit, color: Colors.white, size: 14),
                  Text(
                    'Edit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget PremiumArea() {
  //   return GestureDetector(
  //     onTap: () {
  //       Get.toNamed(Routers.rechargePremium.name);
  //     },
  //     child: Container(
  //       height: 54,
  //       padding: EdgeInsets.symmetric(horizontal: 12),
  //       decoration: BoxDecoration(
  //         gradient: LinearGradient(
  //           colors: [Color(0xffdac6ae), Color(0xffe3b5e5), Color(0xffc4b2ea)],
  //         ),
  //         borderRadius: BorderRadius.circular(12),
  //       ),
  //       child: Row(
  //         spacing: 8,
  //         children: [
  //           Image.asset(ImagePath.premium, height: 24, width: 24),
  //           Text(
  //             Copywriting.security_feelie_Pro,
  //             style: TextStyle(
  //               color: AppColors.base_background,
  //               fontSize: 14,
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           Spacer(),
  //           Obx(
  //             () =>
  //                 MyAccount.isSubscribed
  //                     ? Row(
  //                       spacing: 4,
  //                       children: [
  //                         Text(
  //                           EncHelper.rcg_expOn,
  //                           style: TextStyle(
  //                             color: Color(0xFFababad),
  //                             fontSize: 13,
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         ),
  //                         Text(
  //                           CalendarHelper.formatDate(
  //                                 date: MyAccount.premEdTm,
  //                               ) ??
  //                               EncHelper.rcg_err,
  //                           style: const TextStyle(
  //                             color: Color(0xFFFFCB05),
  //                             fontSize: 13,
  //                             fontWeight: FontWeight.w400,
  //                           ),
  //                         ),
  //                         Image.asset(
  //                           ImagePath.right_arrow,
  //                           height: 16,
  //                           width: 16,
  //                         ),
  //                       ],
  //                     )
  //                     : Container(
  //                       height: 32,
  //                       padding: EdgeInsets.symmetric(horizontal: 12),
  //                       decoration: BoxDecoration(
  //                         gradient: LinearGradient(
  //                           colors: [Color(0xfff4a07f), Color(0xffea5076)],
  //                         ),
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                       alignment: Alignment.center,
  //                       child: Text(
  //                         Security.security_Subscribe,
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 14,
  //                           fontWeight: FontWeight.bold,
  //                         ),
  //                       ),
  //                     ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

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
                  Positioned(
                    left: 0,
                    child: Text(
                      Copywriting.security_my_Companion,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: -5,
                    child: Image.asset(
                      ImagePath.tab_selected,
                      width: 40,
                      height: 10,
                    ),
                  ),
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
                    : RefreshIndicator(
                      onRefresh: controller.initCollections,
                      child: Obx(
                        () =>
                            controller.status.value == ListStatus.success
                                ? GridView.builder(
                                  controller: controller.scrollController,
                                  padding: EdgeInsets.symmetric(vertical: 0),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 8,
                                        mainAxisSpacing: 8,
                                        childAspectRatio: 168 / 274,
                                      ),
                                  itemBuilder: (context, index) {
                                    return _buildCompanionItem(
                                      controller.myCompanions[index],
                                    );
                                  },
                                  itemCount: controller.myCompanions.length,
                                )
                                : ListStatusView(
                                  status: controller.status.value,
                                  emptyDesc:
                                      'No chat partner has been initiated yet',
                                ),
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
        onToChatTap(
          companion[EncHelper.ac_uid].toString(),
          companion[EncHelper.ac_nn],
          companion[EncHelper.ac_avt],
          companion[EncHelper.ac_cvu],
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: CachedNetworkImageProvider(companion['coverUrl']),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            Spacer(),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(ImagePath.person_img_mask),
                  fit: BoxFit.cover,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          companion['nickname'],
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      AppWidgets.userTag(companion['accountType']),
                    ],
                  ),
                  Text(
                    companion['bio'],
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 3,
                  ),
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
      Routers.chat,
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
    return Center(
      child: Text(
        Copywriting.security_no_companions_yet,
        style: TextStyle(color: Color(0xFFA0A0A0), fontSize: 12),
      ),
    );
  }
}

class AccountViewController extends GetxController {
  final myCompanions = [].obs;

  var poolVer = 0;
  var pageIdx = 0;
  final pageSize = 20;
  var hasMore = true;
  var status = ListStatus.idle.obs;
  final _loadingComsLock = Lock();

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
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
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
    await _loadingComsLock.synchronized(() async {
      if (!hasMore) {
        EasyLoading.showToast('No more companions to load.');
        return;
      }
      final rsp = await RoleManager.instance.getRoleList(
        pageIndex: pageIdx,
        pageSize: pageSize,
        version: poolVer,
      );
      if (rsp.isSuccess) {
        poolVer = rsp.data[Security.security_poolVersion];
        hasMore = rsp.data[Security.security_hasMore];
        pageIdx++;

        myCompanions.addAll(rsp.data[Security.security_param] ?? []);
        myCompanions.refresh();
      }
    });
  }

  void refreshMyInfo() {
    AccountService.instance.getMyPremInfo();
    AccountService.instance.refreshBalance();
  }
}
