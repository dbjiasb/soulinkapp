import 'package:modules/base/crypt/copywriting.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/webview/web_view.dart';
import 'package:modules/business/create_center/my_oc_config.dart';
import 'package:modules/core/account/account_service.dart';

import '../../base/assets/image_path.dart';
import '../../base/router/router_names.dart';
import '../../shared/app_theme.dart';

class CreateOcDialog extends StatelessWidget {
  CreateOcDialog({super.key});

  final CreateAiDialogLogic _logic = Get.put(CreateAiDialogLogic());

  static Future show() async {
    return await Get.dialog(
      useSafeArea: false,
      Container(alignment: Alignment.bottomCenter, child: CreateOcDialog()),
    ).then((_) {
      Get.delete<CreateAiDialogLogic>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 418,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(children: [_buildHeaderSection(), _buildFooterSection()]),
    );
  }

  void _showCopyrightAgreement() {
    Get.to(
      WebView(),
      arguments: {
        Security.security_title: Copywriting.security_copyright_Agreement,
        Security.security_url:
            'https://cdn.luminaai.buzz/h5/protocol/oc_copyright.html',
      },
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.topCenter,
      height: 248,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        image: DecorationImage(
          image: AssetImage(ImagePath.oc_dialog_bg),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: Image.asset(width: 32, height: 32, ImagePath.oc_dialog_close),
          ),
          Spacer(),
          IconButton(
            onPressed: () {},
            icon: Image.asset(width: 32, height: 32, ImagePath.oc_dialog_ask),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSection() {
    const btnTextStyle = TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.w900,
    );
    final hintTextStyle = TextStyle(
      color: const Color(0xFF999999),
      fontSize: 11,
      fontWeight: AppFonts.medium,
    );
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 43),
      height: 170,
      child: Column(
        children: [
          Obx(
            () => GestureDetector(
              onTap: _logic.consent.value ? (() async => toCreatePage()) : null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 20,
                ),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    color: _logic.consent.value ? AppColors.ocMain : null,
                    gradient:
                        _logic.consent.value
                            ? null
                            : LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xffBDC6C6), Color(0xffD5E1DD)],
                            ),
                  ),
                  child:
                      _logic.isLoading.value
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                          : _logic.canContinue
                          ? Wrap(
                            spacing: 2,
                            children: [
                              RichText(
                                text: TextSpan(
                                  text: Security.security_Continue,
                                  style: btnTextStyle,
                                ),
                              ),
                            ],
                          )
                          : _buildCostWidget(btnTextStyle),
                ),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: Obx(
                  () => GestureDetector(
                    onTap: () {
                      _logic.consent.value = !_logic.consent.value;
                    },
                    child: Image.asset(
                      _logic.consent.value == true
                          ? ImagePath.check
                          : ImagePath.check_bg,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: RichText(
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text:
                            Copywriting
                                .security_prior_to_the_creation_process__please_review_our,
                        style: hintTextStyle,
                      ),
                      TextSpan(
                        text: Copywriting.security_copyright_Agreement,
                        style: TextStyle(
                          color: Color(0xFFB86AFF),
                          fontWeight: AppFonts.medium,
                          fontSize: 11,
                          fontFamily: Copywriting.security_sF_Pro,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                _showCopyrightAgreement();
                              },
                      ),
                      TextSpan(
                        text: ' and indicate your consent.',
                        style: hintTextStyle,
                      ),
                    ],
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> toCreatePage() async {
    EasyLoading.show(status: Security.security_Checking);
    final rtn = await _logic.payForCreateOc();
    EasyLoading.dismiss();
    if (rtn) {
      Get.back();
      Get.toNamed(Routers.createBasic.name);
    }
  }

  Widget _buildCostWidget(TextStyle btnTextStyle) {
    var btnContent;
    if (_logic.costValue == 0) {
      // 免费
      btnContent = [
        if (_logic.premiumFree == 1)
          Image.asset(width: 18, height: 18, ImagePath.premium),
        Text(_logic.freeText, style: btnTextStyle),
      ];
    } else {
      // 付费
      btnContent = [
        RichText(
          text: TextSpan(
            text: Copywriting.security_start_create,
            style: btnTextStyle,
          ),
        ),
        Image.asset(
          width: 18,
          height: 18,
          _logic.costType == 0 ? ImagePath.coin : ImagePath.gem,
        ),
        RichText(
          text: TextSpan(text: '${_logic.costValue}', style: btnTextStyle),
        ),
      ];
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 2,
      children: [...btnContent],
    );
  }
}

class CreateAiDialogLogic extends GetxController {
  final consent = true.obs;
  var entryInfo = <dynamic, dynamic>{};

  int get costValue => entryInfo['costValue'] ?? 300;

  int get costType => entryInfo['costType'] ?? 0;

  int get premiumFree => entryInfo['premiumFree'] ?? 0; // 0: 无，1: 有

  String get freeText => costValue == 0 ? entryInfo['freeText'] ?? '' : '';

  bool get canContinue =>
      entryInfo.isNotEmpty && entryInfo[Security.security_status] == 1;

  @override
  void onInit() {
    super.onInit();
    syncCreateOc();
  }

  Future<bool> payForCreateOc() async {
    if (canContinue) return true;
    if (MyAccount.coins < costValue && premiumFree == 0) {
      EasyLoading.showToast(Copywriting.security_insufficient_balance_);
      return false;
    }
    return await createDraft();
  }

  // 预创建角色，触发消费
  Future<bool> createDraft() async {
    final rsp = await OcManager.instance.createDraft();
    if (rsp?[Security.security_statusInfo]?[Security.security_code] == 2000) {
      return false;
    }
    return true;
  }

  final isLoading = false.obs;

  Future<void> syncCreateOc() async {
    isLoading.value = true;
    try {
      final map = await OcManager.instance.getDraft();
      if (map != null) {
        entryInfo = map;
      }
    } finally {
      isLoading.value = false;
    }
  }
}
