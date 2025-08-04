import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'dart:convert';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_service_export.dart';
import 'package:modules/base/crypt/constants.dart';
import 'package:modules/business/create_center/my_oc_config.dart';

import '../../base/router/router_names.dart';
import '../../shared/widget/list_status_view.dart';
import '../create_center/create_oc_dialog.dart';
import 'role_manager.dart';

abstract class RoleItem {
  late final Map info;

  RoleItem(this.info);

  factory RoleItem.fromMap(Map info) {
    int type = info[Constants.acType];
    switch (type) {
      case 1:
        return VirtualRoleItem(info);
      default:
        return VirtualRoleItem(info);
    }
  }

  Widget builder(BuildContext context);
}

class CreateOcEntryItem extends RoleItem {
  CreateOcEntryItem(super.info);

  @override
  Widget builder(BuildContext context) {
    return _buildCreateOcEntry();
  }

  Widget _buildCreateOcEntry() {
    return GestureDetector(
      onTap: () {
        CreateOcDialog.show();
      },
      child: AspectRatio(
        aspectRatio: 166 / 88,
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(image: DecorationImage(image: AssetImage(ImagePath.cr_entry_bg), fit: BoxFit.fitWidth)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(Security.security_Create, style: TextStyle(color: Color(0xFF36214E), fontSize: 14, fontWeight: FontWeight.w900)),
              Text(Security.security_Character, style: TextStyle(color: Color(0xFF36214E), fontSize: 14, fontWeight: FontWeight.w900)),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: Color(0xFFE962F6), borderRadius: BorderRadius.circular(10)),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(Security.security_GO, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                    Image.asset(ImagePath.go, height: 10, width: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class VirtualRoleItem extends RoleItem {
  VirtualRoleItem(super.info);

  String get coverUrl => info[Security.security_coverUrl] ?? '';

  String get nickname => info[Security.security_nickname] ?? '';

  String get bio => info[Security.security_bio] ?? '';

  int get accountType => info[Constants.acType] ?? 0;

  void _onItemClicked({bool call = false}) {
    Map<String, dynamic> params = {};
    params[Security.security_id] = info[Security.security_uid].toString();
    params[Security.security_name] = info[Security.security_nickname] ?? '';
    params[Security.security_avatar] = info[Security.security_avatarUrl] ?? '';
    params[Security.security_backgroundUrl] = info[Security.security_coverUrl] ?? '';
    Get.toNamed(Routers.chat.name, arguments: {Security.security_session: jsonEncode(params), Security.security_call: call});
  }

  @override
  Widget builder(BuildContext context) {
    return GestureDetector(
      onTap: _onItemClicked,
      child: AspectRatio(
        aspectRatio: 168 / 260,
        child: Container(
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Image.asset(
                  ImagePath.per_empty_cover,
                  fit: BoxFit.cover,
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Spacer(),
                  ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        color: Colors.black.withOpacity(0.3),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          spacing: 4,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //限制文本宽度
                            Text(
                              nickname,
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              bio,
                              style: TextStyle(color: Colors.white.withOpacity(0.7), fontWeight: FontWeight.w500, fontSize: 11),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            // SizedBox(width: 12),
                            // GestureDetector(
                            //   onTap: () {
                            //     _onItemClicked(call: true);
                            //   },
                            //   child: Image.asset('packages/modules/assets/images/call/call.png', width: 40, height: 40),
                            // ),
                            // Text(
                            //   bio,
                            //   maxLines: 3,
                            //   overflow: TextOverflow.ellipsis,
                            //   style: TextStyle(color: Color(0xB3FFFFFF), fontWeight: FontWeight.w500, fontSize: 11),
                            // ),
                          ],
                        ),
                      )
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class RoleListView extends StatelessWidget {
  RoleListView({super.key, required this.type}) {
    // 在构造函数中初始化控制器并传入 type
    viewController = Get.put(RoleListViewController(type: type),tag: '${type.name}_controller');
  }

  final RoleListType type;

  late RoleListViewController viewController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: viewController.onRefresh,
            child: Obx(
              () =>
                  viewController.status.value == ListStatus.success
                      ? MasonryGridView.count(
                        controller: viewController.scrollController,
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                        crossAxisCount: 2,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        itemBuilder: (context, index) {
                          return viewController.items[index].builder(context);
                        },
                        itemCount: viewController.items.length,
                      )
                      : ListStatusView(status: viewController.status.value),
            ),
          ),
        ),
      ],
    );
  }
}

class RoleListViewController extends GetxController {
  var status = ListStatus.idle.obs;
  var items = [].obs;

  final RoleListType type; // 新增 type 属性

  late ScrollController scrollController;

  bool _hasMore = true;
  int _pageIndex = 0;
  int _version = 0;
  int pageSize = 20;

  bool loadingMore = false;

  // 构造函数接收 type 参数
  RoleListViewController({required this.type}) {
    scrollController = ScrollController();
  }

  @override
  void onInit() {
    super.onInit();
    getRoleList();
    addObservers();
  }

  addObservers() {
    scrollController.addListener(() {
      if ((scrollController.position.pixels >= scrollController.position.maxScrollExtent - 64) && _hasMore && loadingMore == false) {
        loadMoreData();
      }
    });
  }

  loadMoreData() async {
    if (loadingMore) return;
    loadingMore = true;
    _pageIndex++;
    await getRoleList(pageIndex: _pageIndex, version: _version);
    loadingMore = false;
  }

  Future<void> onRefresh() async {
    _version = 0;
    _pageIndex = 0;
    _hasMore = true;
    await getRoleList();
  }

  getRoleList({int version = 0, int pageIndex = 0, int targetUid = 0}) async {
    if (items.isEmpty && status.value == ListStatus.idle) {
      status.value = ListStatus.loading;
    }

    ApiResponse response = await RoleManager.instance.getRoleList(type: type, version: version, pageIndex: pageIndex, targetUid: targetUid);
    if (response.isSuccess) {
      List infos = response.data[Security.security_param] ?? [];
      List<RoleItem> newItems = infos.map((e) => RoleItem.fromMap(e)).toList();

      if (pageIndex == 0 && (type == RoleListType.ai || type == RoleListType.custom_ai)) {
        items.clear();
        items.add(CreateOcEntryItem({}));
      }
      items.addAll(newItems);
      status.value = items.isEmpty ? ListStatus.empty : ListStatus.success;
      _hasMore = response.data[Security.security_hasMore] ?? true;
      _version = response.data[Constants.pVer] ?? 0;
    } else {
      if (items.isEmpty) {
        status.value = ListStatus.error;
      }
    }
  }
}
