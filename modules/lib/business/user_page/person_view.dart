import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/business/chat/chat_room/chat_room_view.dart';
import 'package:modules/business/chat/person_manager.dart';
import 'package:modules/core/util/es_helper.dart';
import 'package:modules/shared/app_theme.dart';
import 'package:modules/shared/interactions.dart';

import '../../../core/user_manager/user_manager.dart';

class PersonViewPage extends StatelessWidget {
  PersonViewPage({Key? key}) : super(key: key);
  final PersonViewController controller = Get.put(PersonViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 底色
          Container(
            width: double.infinity,height: double.infinity,
              color: AppColors.main),

          // 背景图
          Positioned.fill(
            child: Obx(
                  () => ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Color(0xFF000000).withValues(alpha: 0.4),
                  BlendMode.srcOver,
                ),
                child: CachedNetworkImage(
                  imageUrl: controller.background,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => Container(color: AppColors.main),
                ),
              ),
            ),
          ),

          // 内容
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderSection(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProfileSection(),
                      SizedBox(
                        height: 20+4,
                        width: 60,
                        child: Stack(
                          children: [
                            Positioned(top:0,left:0,child: Text('Gallery',style: TextStyle(color: Colors.white,fontSize: 16,fontWeight: FontWeight.bold),)),
                            Positioned(bottom:0,right:0,child: Image.asset(ImagePath.tab_selected,height: 10,width: 40,))
                          ]
                        ),
                      ),
                      _buildGallerySection(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 返回按钮
          Positioned(
            left: 16,
            top: 27,
            child: SafeArea(
              child: GestureDetector(
                onTap: Get.back,
                child: Container(width: 32, height: 44, alignment: Alignment.center, child: Image.asset(ImagePath.back, width: 24, height: 24)),
              ),
            ),
          ),

          // 聊天按钮
          Positioned(left: 16, right: 16, bottom: 20, child: GestureDetector(
            onTap: onToChatTap,
            child: Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: AppColors.ocMain),
              height: 52,
              child: Text(Security.security_Chat, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SizedBox(
      height: 303 + 240,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.only(left: 16, top: 44),
              alignment: Alignment.bottomLeft,
              child: Obx(
                () => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: Colors.transparent,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 1, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: controller.avatarUrl,
                                fit: BoxFit.cover,
                                errorWidget: (context, url, error) => Image.asset(ImagePath.default_avatar, fit: BoxFit.cover, width: 72, height: 72),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      spacing: 6,
                      children: [
                        Text(controller.name, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                        controller.type != '' ? Image.asset(controller.type, width: 21, height: 16) : Container(),
                      ],
                    ),
                    Row(
                      spacing: 4,
                      children: [
                        Text('ID: ${controller.id}', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        // GestureDetector(
                        //   onTap: () {
                        //     Interactions.copyToClipboard(controller.id.toString());
                        //   },
                        //   child: Image.asset(ImagePath.string_cpy, height: 16, width: 16),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGallerySection() {
    return GridView.count(
      physics: const NeverScrollableScrollPhysics(), // 1. 禁用GridView自身滚动
      shrinkWrap: true, // 2. 适应内容高度
      crossAxisCount: 2,
      mainAxisSpacing: 7,
      crossAxisSpacing: 8,
      childAspectRatio: 168/256,
      children: controller.gallery.map((url) => ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
        ),
      )).toList(),
    );
  }

  Widget _buildFollowStatsRow() {
    return Row(
      children: [
        Obx(() => _buildStatItem(Security.security_Followers, controller.followers)),
        SizedBox(width: 34),
        Obx(() => _buildStatItem(Security.security_Followings, controller.followings)),
        Spacer(),
        // _buildFollowButton(),
      ],
    );
  }

  Widget _buildStatItem(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4,
      children: [
        Text('$value', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: AppFonts.black)),
        Text(label, style: TextStyle(color: Color(0xFF9EA1A8), fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }

  // Widget _buildFollowButton() {
  //   return Obx(
  //     () => GestureDetector(
  //       onTap: () {
  //         if (controller.star == 0) {
  //           controller.followUser();
  //         } else {
  //           controller.unfollowUser();
  //         }
  //       },
  //       child:
  //           controller.star == 0
  //               ? _buildButtonContent(Security.security_Follow, ImagePath.add, Color(0xFFE962F6))
  //               : _buildButtonContent(Security.security_Followed, null, Colors.transparent, hasBorder: true),
  //     ),
  //   );
  // }

  Widget _buildButtonContent(String text, String? iconPath, Color color, {bool hasBorder = false}) {
    return Container(
      height: 36,
      width: 98,
      alignment: Alignment.center,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: color, border: hasBorder ? Border.all(width: 2, color: Colors.white) : null),
      child: Row(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (iconPath != null) Image.asset(iconPath, height: 18, width: 18),
          Text(text, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: AppFonts.black)),
        ],
      ),
    );
  }

  Widget _buildAboutHerSection() {
    final outlineStyle = TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800);
    final normalStyle = TextStyle(color: Color(0xFF9EA1A8), fontSize: 12, fontWeight: AppFonts.medium);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 7,
      children: [
        _buildSectionTitle('About her'),
        _buildInfoRow([
          Obx(() => _buildInfoTile(Security.security_Gender, _getGenderText(controller.gender), outlineStyle, normalStyle)),
          Obx(
            () => _buildInfoTile(
              'Birth date',
              DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(controller.birthday)),
              outlineStyle,
              normalStyle,
            ),
          ),

          Obx(() => _buildInfoTile(Security.security_Age, controller.age.toString(), outlineStyle, normalStyle)),
        ]),
        _buildInfoRow([
          Obx(() => _buildInfoTile(Security.security_Constellation, controller.constellation, outlineStyle, normalStyle)),
          Obx(() => _buildInfoTile(Security.security_Location, controller.location.isEmpty ? '/' : controller.location, outlineStyle, normalStyle)),
          Obx(
            () => _buildInfoTile(
              Security.security_Education,
              controller.education.isEmpty || controller.education.first == null ? '/' : controller.location,
              outlineStyle,
              normalStyle,
            ),
          ),
        ]),
      ],
    );
  }

  String _getGenderText(int gender) {
    return gender == 0
        ? Security.security_Unknown
        : gender == 1
        ? Security.security_Male
        : gender == 2
        ? Security.security_Female
        : '/';
  }

  Widget _buildInfoRow(List<Widget> children) {
    return Row(spacing: 7, children: children);
  }

  Widget _buildInfoTile(String title, String value, TextStyle valueStyle, TextStyle titleStyle) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 110 / 60,
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF12151D), borderRadius: BorderRadius.circular(12)),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text(value, style: valueStyle), Text(title, style: titleStyle)]),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Text(
            controller.profile.isEmpty ? '......' : controller.profile,
            style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold));
  }

  void onToChatTap() {
    if (Get.isRegistered<ChatRoomViewController>()) {
      Get.back();
      return;
    }
    Get.toNamed(
      Routers.chat.name,
      arguments: {
        Security.security_session: jsonEncode({
          EncHelper.id: controller.id.toString(),
          EncHelper.nm: controller.name,
          EncHelper.avt: controller.avatarUrl,
          EncHelper.bgurl: controller.personalInfo[EncHelper.ps_cvurl],
        }),
        Security.security_call: false,
      },
    );
  }
}

class PersonViewController extends GetxController {
  final personalInfo = <String, dynamic>{}.obs;

  UserManager get userManager => UserManager.instance;

  List get gallery => personalInfo['gallery'] ?? [];

  Map get userInfo => personalInfo[EncHelper.ps_usif] ?? {};

  Map get baseInfo => userInfo[EncHelper.ps_bsif] ?? {};

  String get avatarUrl => userInfo[EncHelper.ps_bsif]?[EncHelper.ps_avturl] ?? ImagePath.default_avatar;

  String get background => personalInfo[EncHelper.ps_bg] ?? '';

  String get name => baseInfo[EncHelper.ps_nn] ?? '';

  int get id => baseInfo[EncHelper.ps_uid] ?? 0;

  int get followers => personalInfo[EncHelper.ps_fsc] ?? 0;

  int get followings => personalInfo[EncHelper.ps_foloc] ?? 0;

  int get gender => baseInfo[EncHelper.ps_gdr] ?? 0;

  int get birthday => userInfo[EncHelper.ps_bfda] ?? 0;

  int get age => userInfo[EncHelper.ps_ag] ?? 0;

  String get constellation => userInfo[EncHelper.ps_cstat] ?? '';

  String get location => userInfo[EncHelper.ps_lct] ?? '';

  List get education => personalInfo[EncHelper.ps_educat] ?? [];

  String get profile => userInfo[EncHelper.ps_bo] ?? '';

  int get star => personalInfo[EncHelper.ps_str] ?? 0;

  String get type {
    if (baseInfo[EncHelper.ps_act] == 1 || baseInfo[EncHelper.ps_act] == 3 || baseInfo[EncHelper.ps_act] == 4) {
      return ImagePath.ai_tag;
    }
    return '';
  }

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;
    final id = arguments[EncHelper.psid];
    if (id != null) {
      getPersonInfo(id);
      return;
    }
    personalInfo.value = arguments[EncHelper.ps_if];
    if (personalInfo.isEmpty) {
      EasyLoading.showToast('No user information, getting back...');
      Get.back();
    }
  }

  void getPersonInfo(int uid) async {
    EasyLoading.show(status: 'Loading...');
    final rtn = await PersonManager.instance.getUserInfo(uid);
    if (rtn.data == {}) {
      EasyLoading.show(status: 'Cannot get information, please retry later');
      EasyLoading.dismiss();
      return;
    }
    personalInfo.value = rtn.data;
    personalInfo.refresh();
    EasyLoading.dismiss();
  }

  Future<void> followUser() async {
    EasyLoading.show(status: 'Loading...');
    final rtn = await PersonManager.instance.followUser(id, 1);
    if (rtn == false) {
      EasyLoading.showError('Failed to follow');
      return;
    }
    getPersonInfo(id);
    EasyLoading.showSuccess(Security.security_Followed);
  }

  Future<void> unfollowUser() async {
    EasyLoading.show(status: 'Loading...');
    final rtn = await PersonManager.instance.followUser(id, 0);
    if (rtn == false) {
      EasyLoading.showError('Failed to unfollow');
      return;
    }
    getPersonInfo(id);
    EasyLoading.showSuccess(Security.security_Unfollowed);
  }
}
