import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:external_modules/svgaplayer_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/business/create_center/my_oc_config.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/shared/alert.dart';

import '../../../base/router/router_names.dart';
import '../../../core/util/file_upload.dart';
import '../../shared/app_theme.dart';

class GenPage extends StatelessWidget {
  GenPage({super.key});

  final _logic = Get.put(GenOcController());

  @override
  Widget build(BuildContext context) {
    _logic.initCreatePage();
    return Scaffold(body: Obx(() => AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: _logic.isGenPage.value ? genBody() : resultBody())));
  }

  // 生成中页面的 Widget
  Widget genBody() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 44),
      decoration: BoxDecoration(image: DecorationImage(image: AssetImage('$ocImgDir/oc_gen_bg.png'), fit: BoxFit.fill)),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  showStopDialog();
                },
                icon: Image.asset('$commImgDir/icon_back.png', height: 24, width: 24),
              ),
            ],
          ),
          const Center(
            child: Wrap(
              children: [
                Column(
                  children: [
                    SizedBox(height: 200, width: 200, child: SVGASimpleImage(assetsName: '$ocAnimDir/gen_ing.svga')),
                    Text('Generating...', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w400, color: Color(0xFFFFFFFF))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 结果页面的 Widget
  Widget resultBody() {
    return Stack(
      key: ValueKey(Security.security_result), // 必须设置不同的 Key
      children: [
        Stack(
          children: [
            bgView(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 16),
              child: Column(
                spacing: 16,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    spacing: 10,
                    children: [
                      resultImage(),
                      IconButton(
                        onPressed: () {
                          startRegeneration();
                        },
                        icon: Image.asset('$ocImgDir/oc_regen.png', height: 32, width: 32),
                      ),
                    ],
                  ),
                  const Expanded(child: SizedBox()),
                  Obx(() => Row(mainAxisAlignment: MainAxisAlignment.center, spacing: 4, children: indicatorView())),
                  GestureDetector(
                    onTap: _logic.goToChat,
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocMain),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _logic.isEditPage ? 'Modify Now' : 'Create Now',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  void showStopDialog() {
    showConfirmAlert(
      Security.security_Tips,
      'The character creation is still ongoing. Leaving at this moment will forfeit the progress made so far. Are you sure you want to go back?',
      confirmText: Security.security_Confirm,
      cancelText: Security.security_Cancel,
      onConfirm: () {
        _logic.forceReturn();
      },
      onCancel: Get.back,
    );
  }

  void startRegeneration() {
    showConfirmAlert(
      'Regeneration Tips',
      'Following the regeneration process, you’ll receive a brand-new image. You are also welcome to revisit the images you created earlier. Are you ready to move forward?',
      confirmText: Security.security_Yes,
      cancelText: Security.security_Cancel,
      onConfirm: () {
        _logic.isEditPage ? _logic.regenerateInEdition() : _logic.regenerateInCreation();
      },
      onCancel: Get.back,
    );
  }

  Widget resultImage() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        _logic.cropImage();
      },
      child: Stack(
        alignment: Alignment.topCenter,
        clipBehavior: Clip.none,
        children: [
          Obx(
            () => Container(
              width: 68,
              height: 68,
              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(35))),
              child:
                  _logic.currentAvatar.value.isEmpty
                      ? const CircularProgressIndicator()
                      : _logic.currentAvatar.value.startsWith(Security.security_https)
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: CachedNetworkImage(imageUrl: _logic.currentAvatar.value, width: 68, height: 68, fit: BoxFit.cover),
                      )
                      : ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: Image.file(File(_logic.currentAvatar.value), width: 68, height: 68, fit: BoxFit.cover),
                      ),
            ),
          ),
          Positioned(
            top: 56,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocMain),
              child: Text(Security.security_focus, style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget bgView() {
    return Positioned.fill(
      child: PageView(
        controller: _logic.pageController,
        onPageChanged: (index) {
          _logic.switchToPage(index);
        },
        children:
            _logic.results
                .map((results) => Container(decoration: BoxDecoration(image: DecorationImage(image: FileImage(File(results.localPath)), fit: BoxFit.cover))))
                .toList(),
      ),
    );
  }

  List<Widget> indicatorView() {
    final indicators = <Container>[];
    final index = _logic.currentPage.value;
    for (int i = 0; i < _logic.results.length; i++) {
      indicators.add(
        Container(
          decoration: BoxDecoration(color: i == index ? AppColors.ocMain : Colors.white, borderRadius: const BorderRadius.all(Radius.circular(3))),
          height: 6,
          width: 6,
        ),
      );
    }
    return indicators;
  }
}

class GenOcController extends GetxController {
  OcDependency ocDependency = Get.find<OcDependency>();

  bool get isEditPage => ocDependency.isEdit;

  Map get config => ocDependency.configs;

  final isGenPage = false.obs;
  Timer? _resultTimer;
  final interrupt = false.obs;
  final pageController = PageController();
  final currentPage = 0.obs;
  final currentAvatar = ''.obs;

  late final List<GenerationResult> results = ocDependency.results;

  void initEditPage() {
    regenerateInEdition();
  }

  Future<void> regenerateInEdition() async {
    isGenPage.value = true;
    final rtn = await ocDependency.editForBgRegeneration();
    if (rtn) {
      startTimer();
    } else {
      // 失败
    }
  }

  void initCreatePage() {
    regenerateInCreation();
  }

  // 获取图片traceId
  Future<void> regenerateInCreation() async {
    isGenPage.value = true;
    final rtn = await ocDependency.createForBgRegeneration();
    if (rtn) {
      startTimer();
    } else {
      // 失败
    }
  }

  // 开始定时器，定时任务为轮询结果
  void startTimer() {
    _resultTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      queryResult();
    });
  }

  // 轮询结果，如果有结果则结束轮询，进行处理
  Future<void> queryResult() async {
    if (_resultTimer == null || interrupt.value == true) return;
    final rtn = await ocDependency.queryImageResult();
    if (_resultTimer == null || interrupt.value == true) return;

    if (rtn != null && (rtn[Security.security_imageUrl] as String).isNotEmpty) {
      await handleResult(rtn);
    }
  }

  Future<void> handleResult(Map rtn) async {
    cancelTimer();
    await ocDependency.downloadImage(rtn);

    isGenPage.value = false;

    switchToPage(results.length - 1);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.page != currentPage.value) {
        pageController.jumpToPage(currentPage.value);
      }
    });
  }

  void cancelTimer() {
    _resultTimer?.cancel();
    _resultTimer = null;
  }

  void forceReturn() {
    cancelTimer();
    interrupt.value = true;
    Get.back();
  }

  void switchToPage(int index) {
    if (index < 0) return;
    currentPage.value = index;
    currentAvatar.value = results[index].cropPath;
  }

  // 图片裁剪
  Future<void> cropImage() async {
    final curPage = currentPage.value;
    final localPath = results[curPage].localPath;
    final croppedFile = await ImageCropper().cropImage(sourcePath: localPath);
    if (croppedFile != null) {
      if (await File(results[curPage].cropPath).exists()) {
        await File(results[curPage].cropPath).delete();
      }
      currentAvatar.value = croppedFile.path;
      results[curPage].cropPath = croppedFile.path;
    }
  }

  void goToChat() async {
    EasyLoading.show();
    final xFile = XFile(currentAvatar.value);
    final bytes = await xFile.readAsBytes();
    final avatarUrl = await FilePushService.instance.upload(bytes, FileType.profile);
    if (avatarUrl != null) {
      ocDependency.configs[Security.security_chatBackground] = results[currentPage.value].url;
      ocDependency.configs[Security.security_avatarUrl] = avatarUrl;

      late final rtn;
      if (isEditPage) {
        rtn = await ocDependency.update();
      } else {
        rtn = await ocDependency.createRole();
      }
      if (rtn != null) {
        EasyLoading.dismiss();

        ocDependency.cleanTemps();
        Get.until((route) => route.settings.name == Routers.root.name);
        Get.delete<OcDependency>();

        AccountService.instance.getMyPremInfo();
        Get.toNamed(
          Routers.chat.name,
          arguments: {
            Security.security_session: jsonEncode({
              Security.security_id: rtn[Security.security_roleUid].toString(),
              Security.security_name: config[Security.security_nickname] ?? '',
              Security.security_avatar: config[Security.security_avatarUrl] ?? '',
              Security.security_backgroundUrl: config[Security.security_coverUrl] ?? '',
            }),
            Security.security_call: false,
          },
        );
      }
    } else {
      EasyLoading.showToast('Avatar upload failed, please try again later.');
    }
    EasyLoading.dismiss();
  }
}
