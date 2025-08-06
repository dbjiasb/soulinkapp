import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/business/create_center/create_oc_dialog.dart';
import 'package:modules/business/home_page_lists/role_manager.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/util/calendar_helper.dart';
import 'package:modules/core/util/es_helper.dart';
import 'package:modules/shared/app_theme.dart';
import 'package:modules/shared/widget/avatar_view.dart';

import '../../base/api_service/api_response.dart';
import '../../base/crypt/constants.dart';
import '../../shared/interactions.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../shared/widget/list_status_view.dart';
import '../home_page_lists/role_list_view.dart';

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
      backgroundColor: AppColors.main,
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
                child: Row(children: [Spacer(), GestureDetector(onTap: () {Get.toNamed(Routers.setting.name);}, child: Image.asset(ImagePath.setting, height: 32, width: 32))]),
              ),
            ),
          ),

          // 头像
          Positioned(left: 16, top: 144, child: AvatarView(url: avatarUrl, size: 72)),
          // Column(
          //   spacing: 20,
          //   children: [
          //     Container(
          //       height: 150,
          //       padding: EdgeInsets.symmetric(horizontal: 16),
          //       decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImagePath.account_head_bg), fit: BoxFit.cover)),
          //       child: SafeArea(
          //         bottom: false,
          //         child: Row(
          //           crossAxisAlignment: CrossAxisAlignment.start,
          //           children: [
          //             Container(
          //               child: Row(
          //                 children: [
          //                   Obx(() => avatarUrl.isEmpty ? Image.asset(ImagePath.default_avatar, height: 68, width: 68) : AvatarView(url: avatarUrl, size: 68)),
          //                   SizedBox(width: 12),
          //                   Column(
          //                     spacing: 3,
          //                     mainAxisAlignment: MainAxisAlignment.center,
          //                     crossAxisAlignment: CrossAxisAlignment.start,
          //                     children: [
          //                       Row(
          //                         spacing: 4,
          //                         children: [
          //                           Obx(() => Text(nickname, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
          //                           GestureDetector(
          //                             onTap: () {
          //                               Get.toNamed(Routers.editMe.name);
          //                             },
          //                             child: Image.asset(ImagePath.account_edit, height: 14, width: 14),
          //                           ),
          //                         ],
          //                       ),
          //                       Container(
          //                         padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
          //                         decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
          //                         child: Row(
          //                           spacing: 4,
          //                           children: [
          //                             Obx(() => Text('ID:$ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500))),
          //                             GestureDetector(
          //                               onTap: () {
          //                                 Interactions.copyToClipboard(ID.toString());
          //                               },
          //                               child: Image.asset(ImagePath.string_cpy, height: 12, width: 12),
          //                             ),
          //                           ],
          //                         ),
          //                       ),
          //                     ],
          //                   ),
          //                 ],
          //               ),
          //             ),
          //             Spacer(),
          //             GestureDetector(
          //               onTap: () {
          //                 Get.toNamed(Routers.setting.name);
          //               },
          //               child: Image.asset(ImagePath.account_setting, width: 24, height: 24),
          //             ),
          //           ],
          //         ),
          //       ),
          //     ),
          //     Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: walletArea()),
          //     CompanionArea(),
          //     SizedBox(height: 10),
          //   ],
          // )
        ],
      ),
    );
  }

  Widget body() {
    return Column(spacing:16,children: [InfoArea(), Expanded(child: CompanionsArea())]);
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
      children: [
        Row(
          children:[
            SizedBox(
                height: 20,
                width: 92,
                child:Stack(
                  clipBehavior: Clip.none,
                    children: [
                      Positioned(left:0,child: Text('Companions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                      Positioned(right:0,bottom:-5,child: Image.asset(ImagePath.tab_selected,width: 40,height: 10,))
                    ]
                )
            )
          ]
        ),
        Expanded(child: CompanionsList())
      ],
    );
  }
  
  Widget CompanionsList() {
    return Obx(()=>controller._loadingCompanions.value==true?Center(child: CircularProgressIndicator()):RefreshIndicator(
      onRefresh: controller.onRefresh,
      child: Obx(
            () =>
        controller.status.value == ListStatus.success
            ? MasonryGridView.count(
          controller: controller.scrollController,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          itemBuilder: (context, index) {
            return controller.myCompanions[index].builder(context);
          },
          itemCount: controller.myCompanions.length,
        )
            : ListStatusView(status: controller.status.value,emptyDesc: 'No chat partner has been initiated yet',),
      ),
    ));
  }

  Widget walletArea() {
    return Column(
      spacing: 12,
      children: [
        GestureDetector(
          onTap: () {
            Get.toNamed(Routers.rechargePremium.name);
          },
          child: Container(
            height: 56,
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Color(0xFF191A17),
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: AssetImage(ImagePath.premium_feelie_pro_bg), fit: BoxFit.cover),
            ),
            child: Row(
              spacing: 8,
              children: [
                Image.asset(ImagePath.premium_gem, height: 24, width: 24),
                const Text('Feelie Pro', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                Spacer(),
                // myPremium.isPremium
                true == true
                    ? Obx(
                      () => RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Expires on ',
                              style: TextStyle(color: const Color(0xFFFFFFFF).withOpacity(0.6), fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                            TextSpan(
                              text: CalendarHelper.formatDate(date: MyAccount.premEdTm),
                              style: const TextStyle(color: Color(0xFFFFCB05), fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    )
                    : Container(),
                Image.asset(ImagePath.arrow_right_highlight, height: 16, width: 16),
              ],
            ),
          ),
        ),
        Container(
          height: 104,
          child: Column(
            spacing: 0,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12),
                height: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                  gradient: LinearGradient(colors: [Color(0xFF6558F3), Color(0xFF8252EE)], begin: Alignment.centerLeft, end: Alignment.centerRight),
                ),
                child: Row(
                  spacing: 8,
                  children: [
                    Image.asset(ImagePath.account_wallet, height: 20, width: 20),
                    Text(Security.security_Wallet, style: TextStyle(color: Colors.white, fontWeight: AppFonts.medium, fontSize: 13)),
                    Spacer(),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(12),
                height: 72,
                decoration: BoxDecoration(
                  color: Color(0xFF18191D),
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [Expanded(child: walletItem(0)), SizedBox(width: 8), Expanded(child: walletItem(1))],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget walletItem(int type) {
    return InkWell(
      onTap: () {
        Get.toNamed(Routers.rechargeCurrency.name, arguments: {Security.security_rcgType: type});
      },
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Color(0xFF232328)),
        child: Row(
          children: [
            Image.asset(type == 0 ? ImagePath.coin : ImagePath.gem, width: 24, height: 24),
            SizedBox(width: 8),
            Obx(
              () => Text(
                type == 0 ? MyAccount.coins.toString() : MyAccount.gems.toString(),
                style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: AppFonts.medium),
              ),
            ),
            Spacer(),
            Image.asset(ImagePath.arrow_right, height: 16, width: 16),
          ],
        ),
      ),
    );
  }

  Widget CompanionArea() {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: SafeArea(
          top: false,
          child: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(color: Color(0xFF18191D), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Image.asset(ImagePath.account_my_oc, height: 24, width: 24),
                    Text('My Companion', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: AppFonts.medium)),
                    Spacer(),
                    GestureDetector(child: Image.asset(ImagePath.account_add_oc, height: 28, width: 28), onTap: CreateOcDialog.show),
                  ],
                ),
                Expanded(
                  child: Obx(
                    () =>
                        controller._loadingCompanions.value == true
                            ? Center(child: CircularProgressIndicator())
                            : controller.myCompanions.isEmpty
                            ? _buildEmptyView()
                            : ListView.builder(
                              physics: BouncingScrollPhysics(),
                              itemCount: controller.myCompanions.length,
                              itemBuilder: (context, index) {
                                final companion = controller.myCompanions[index];
                                return Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildCompanionItem(companion));
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompanionItem(dynamic companion) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        onToChatTap(companion[EncHelper.ac_uid].toString(), companion[EncHelper.ac_nn], companion[EncHelper.ac_avt], companion[EncHelper.ac_cvu]);
      },
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: const Color(0xFF232328)),
        child: Row(
          children: [
            AvatarView(url: companion[EncHelper.ac_avt], size: 40),
            const SizedBox(width: 12),
            Text(companion[EncHelper.ac_nn] ?? Security.security_Unnamed, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: AppFonts.medium)),
            const SizedBox(width: 12),
            if (companion[EncHelper.ps_act] == 4)
              Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Colors.white.withOpacity(0.1)),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(Security.security_Mine, style: TextStyle(color: Color(0xFFAFF062), fontSize: 11, fontFamily: Security.security_AiTag)),
              ),
            const Spacer(),
            Image.asset(ImagePath.arrow_right, width: 16, height: 16),
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

  //
  // bool _hasMore = true;
  // int _pageIndex = 0;
  // int _version = 0;
  // int pageSize = 20;
  // bool loadingMore = false;
  // late ScrollController scrollController;
  // var status = ListStatus.idle.obs;
  // var items = [].obs;
  // Future<void> onRefresh() async {
  //   _version = 0;
  //   _pageIndex = 0;
  //   _hasMore = true;
  //   await getRoleList();
  // }
  // addObservers() {
  //   scrollController.addListener(() {
  //     if ((scrollController.position.pixels >= scrollController.position.maxScrollExtent - 64) && _hasMore && loadingMore == false) {
  //       loadMoreData();
  //     }
  //   });
  // }
  // loadMoreData() async {
  //   if (loadingMore) return;
  //   loadingMore = true;
  //   _pageIndex++;
  //   await getRoleList(pageIndex: _pageIndex, version: _version);
  //   loadingMore = false;
  // }
  // getRoleList({int version = 0, int pageIndex = 0, int targetUid = 0}) async {
  //   if (items.isEmpty && status.value == ListStatus.idle) {
  //     status.value = ListStatus.loading;
  //   }
  //
  //   ApiResponse response = await RoleManager.instance.getRoleList(type: type, version: version, pageIndex: pageIndex, targetUid: targetUid);
  //   if (response.isSuccess) {
  //     List infos = response.data[Security.security_param] ?? [];
  //     List<RoleItem> newItems = infos.map((e) => RoleItem.fromMap(e)).toList();
  //
  //     if (pageIndex == 0) {
  //       items.clear();
  //     }
  //     items.addAll(newItems);
  //     status.value = items.isEmpty ? ListStatus.empty : ListStatus.success;
  //     _hasMore = response.data[Security.security_hasMore] ?? true;
  //     _version = response.data[Constants.pVer] ?? 0;
  //   } else {
  //     if (items.isEmpty) {
  //       status.value = ListStatus.error;
  //     }
  //   }
  // }
  
  final myCompanions = [].obs;

  var poolVer = 0;
  var pageIdx = 0;
  var hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchMyCompanions();
    refreshMyInfo();
  }

  final _loadingCompanions = false.obs;

  void fetchMyCompanions() async {
    _loadingCompanions.value = true;
    if (!hasMore) return;
    final rsp = await RoleManager.instance.getRoleList();
    if (rsp.isSuccess) {
      poolVer = rsp.data[Security.security_poolVersion];
      hasMore = rsp.data[Security.security_hasMore];
      pageIdx++;

      myCompanions.addAll(rsp.data[Security.security_param] ?? []);
      myCompanions.refresh();
    }
    _loadingCompanions.value = false;
  }

  void refreshMyInfo() {
    AccountService.instance.getMyPremInfo();
    AccountService.instance.refreshBalance();
  }
}
