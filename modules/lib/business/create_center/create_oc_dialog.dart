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
    return await Get.dialog(useSafeArea: false, Container(alignment: Alignment.bottomCenter, child: CreateOcDialog()));
  }

  @override
  Widget build(BuildContext context) {
    _logic.getEntryDraft();
    return Container(
      height: 418,
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [_buildHeaderSection(), _buildFooterSection()]),
    );
  }

  void _showCopyrightAgreement() {
    Get.to(WebView(),arguments: {Security.security_title:'Copyright Agreement',Security.security_url:'https://cdn.luminaai.buzz/h5/protocol/oc_copyright.html'});
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(10),
      alignment: Alignment.topCenter,
      height: 248,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        image: DecorationImage(image: AssetImage(ImagePath.cr_dialog_bg), fit: BoxFit.cover),
      ),
      child: Row(children: [IconButton(onPressed: Get.back, icon: Image.asset(width: 32, height: 32, '$ocImgDir/oc_dialog_back.png'))]),
    );
  }

  Widget _buildFooterSection() {
    const btnTextStyle = TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900);
    final hintTextStyle = TextStyle(color: const Color(0xFF999999), fontSize: 11, fontWeight: AppFonts.medium);
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
                child: Container(
                  height: 56,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                    color: _logic.consent.value ? const Color(0xFFB86AFF) : const Color(0xFFEED7FF),
                  ),
                  child:
                      _logic.isLoading.value
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                          : _logic.shouldPay.value
                          ? _buildShouldPayWidget(btnTextStyle)
                          : Wrap(spacing: 2, children: [RichText(text: TextSpan(text: Security.security_Continue, style: btnTextStyle))]),
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
                    child: Image.asset(_logic.consent.value == true ? ImagePath.report_se:ImagePath.report_un),
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
                      TextSpan(text: 'Prior to the creation process, please review our ', style: hintTextStyle),
                      TextSpan(
                        text: 'Copyright Agreement',
                        style: TextStyle(
                          color: Color(0xFFB86AFF),
                          fontWeight: AppFonts.medium,
                          fontSize: 11,
                          fontFamily: 'SF Pro',
                          decoration: TextDecoration.underline,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                _showCopyrightAgreement();
                              },
                      ),
                      TextSpan(text: ' and indicate your consent.', style: hintTextStyle),
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
    final rtn = await _logic.injectDepen();
    EasyLoading.dismiss();
    if (rtn) {
      Get.toNamed(Routers.createBasic.name);
    } else {
      EasyLoading.showToast(_logic.preLoadError.value);
    }
  }

  Widget _buildShouldPayWidget(TextStyle btnTextStyle) {
    var btnContent;
    if(MyAccount.isMthPrem || MyAccount.isYrPrem){
      // 权益支付 - 无限
      btnContent = [
        Image.asset(width: 18, height: 18, ImagePath.premium_gem),
      ];
    }else if (MyAccount.isWkPrem && MyAccount.freeOcLeftTimes>0){
      // 权益支付 - 花费一次机会
      btnContent = [
        Image.asset(width: 18, height: 18, ImagePath.premium_gem),
        RichText(text: TextSpan(text: '(${MyAccount.freeOcUsedTimes}/${MyAccount.freeOcUsedTimes + MyAccount.freeOcLeftTimes})', style: btnTextStyle)),
      ];
    }else {
      // 金币支付
      btnContent = [
        Image.asset(width: 18, height: 18, '$commImgDir/coin.png'),
        RichText(text: TextSpan(text: '300', style: btnTextStyle)),
      ];
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 2,
      children: [
        RichText(text: TextSpan(text: 'Start create', style: btnTextStyle)),
        ...btnContent
      ],
    );

    // if (!myPremium.isPremium || myPremium.isWeakMember && myPremium.createOCUsedCount >= 5) {
    //   // no-premium
    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     spacing: 2,
    //     children: [
    //       RichText(
    //         text: const TextSpan(
    //           text: 'Start create',
    //           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, fontFamily: 'SF Pro Bold', color: Color(0xFFD1F254)),
    //         ),
    //       ),
    //       Image.asset(width: 18, height: 18, 'assets/images/create_own_ai_coin.webp', package: 'creator_center'),
    //       RichText(
    //         text: const TextSpan(text: '300', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, fontFamily: 'SF Pro Bold', color: Color(0xFFD1F254))),
    //       ),
    //     ],
    //   );
    // } else if (myPremium.isWeakMember && myPremium.createOCUsedCount < 5) {
    //   // premium-(0-5)
    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     spacing: 2,
    //     children: [
    //       RichText(
    //         text: const TextSpan(
    //           text: 'Start create',
    //           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, fontFamily: 'SF Pro Bold', color: Color(0xFFD1F254)),
    //         ),
    //       ),
    //       Image.asset(width: 18, height: 18, 'assets/images/ic_premium.webp', package: 'app_biz'),
    //       RichText(
    //         text: TextSpan(
    //           text: ' (${myPremium.createOCUsedCount}/5) Free',
    //           style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17, fontFamily: 'SF Pro Bold', color: Color(0xFFD1F254)),
    //         ),
    //       ),
    //     ],
    //   );
    // } else {
    //   // premium-(unlimited)
    //   return Row(
    //     mainAxisAlignment: MainAxisAlignment.center,
    //     spacing: 2,
    //     children: [
    //       RichText(
    //         text: const TextSpan(
    //           text: 'Start create',
    //           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, fontFamily: 'SF Pro Bold', color: Color(0xFFD1F254)),
    //         ),
    //       ),
    //       Image.asset(width: 18, height: 18, 'assets/images/ic_premium.webp', package: 'app_biz'),
    //       Image.asset(width: 18, height: 18, 'assets/images/ic_unlimited.webp', package: 'app_biz'),
    //       RichText(
    //         text: const TextSpan(
    //           text: Security.security_Free,
    //           style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, fontFamily: 'SF Pro Bold', color: Color(0xFFD1F254)),
    //         ),
    //       ),
    //     ],
    //   );
    // }
  }
}

class CreateAiDialogLogic extends GetxController {
  final consent = true.obs;
  var entryInfo = <dynamic, dynamic>{};
  final preLoadError = ''.obs;
  final shouldPay = true.obs;

  Future<bool> injectDepen() async {
    if (shouldPay.value) {
      // 如果需要支付，则为创建角色
      // todo 处理会员权利
      if (!await createDraft()) {
        preLoadError.value = 'Insufficient balance.';
        return false;
      }
      Get.put(OcDependency(null));
    } else {
      Get.put(OcDependency(entryInfo));
    }
    return true;
  }

  // 预创建角色，触发消费
  Future<bool> createDraft() async {
    final rsp = await OcDependency.createDraft();
    if (rsp?[Security.security_statusInfo]?[Security.security_code] == 2000) {
      // 资产不足，无法创建
      return false;
    }
    return true;
  }

  final isLoading = false.obs;

  Future<void> getEntryDraft() async {
    isLoading.value = true;
    final rsp = OcManager.instance.getDraft();
    rsp.then((map) {
      if (map != null) {
        entryInfo = map;
        if (entryInfo[Security.security_status] == 1) {
          // 有草稿
          shouldPay.value = false;
        } else {
          // 无草稿
          shouldPay.value = true;
        }
      } else {
        // map为null，发生异常:null == ret || !ret.isSuccess
      }
      isLoading.value = false;
    });
  }
}
