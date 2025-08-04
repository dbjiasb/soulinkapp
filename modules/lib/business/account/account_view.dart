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

import '../../shared/interactions.dart';

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
      backgroundColor: Color(0xFF0A0B12),
      body: Column(
        spacing: 20,
        children: [
          Container(
            height: 150,
            padding: EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImagePath.account_head_bg), fit: BoxFit.cover)),
            child: SafeArea(
              bottom: false,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Row(
                      children: [
                        Obx(() => avatarUrl.isEmpty ? Image.asset(ImagePath.account_default_avatar, height: 68, width: 68) : AvatarView(url: avatarUrl, size: 68)),
                        SizedBox(width: 12),
                        Column(
                          spacing: 3,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              spacing: 4,
                              children: [
                                Obx(() => Text(nickname, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900))),
                                GestureDetector(
                                  onTap: () {
                                    Get.toNamed(Routers.editMe.name);
                                  },
                                  child: Image.asset(ImagePath.account_edit, height: 14, width: 14),
                                ),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                spacing: 4,
                                children: [
                                  Obx(() => Text('ID:$ID', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500))),
                                  GestureDetector(
                                    onTap: () {
                                      Interactions.copyToClipboard(ID.toString());
                                    },
                                    child: Image.asset(ImagePath.string_cpy, height: 12, width: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(Routers.setting.name);
                    },
                    child: Image.asset(ImagePath.account_setting, width: 24, height: 24),
                  ),
                ],
              ),
            ),
          ),
          Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: walletArea()),
          CompanionArea(),
          SizedBox(height: 10),
        ],
      ),
    );
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
