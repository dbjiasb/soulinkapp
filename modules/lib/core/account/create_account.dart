import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_service_export.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/copywriting.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/core/account/account_service.dart';

import '../../base/app_info/app_manager.dart';
import '../../base/router/router_names.dart';
import '../../shared/app_theme.dart';

class CreateAccountView extends StatelessWidget {
  CreateAccountView({super.key});

  CreateAccountViewController viewController = Get.put(
    CreateAccountViewController(),
  );

  Widget _buildMailInputView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          color: Color(0xFF272533),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                onChanged: viewController.onMailChange,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.none),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(style: BorderStyle.none),
                  ),
                  hintText: Copywriting.security_entry_your_email,
                  hintStyle: TextStyle(
                    color: Color(0x80FFFFFF),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerifyCodeView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 48,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          color: Color(0xFF272533),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                onChanged: viewController.onVerifyCodeChange,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                decoration: InputDecoration(
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide.none,
                  ),
                  hintText: Copywriting.security_enter_verification_code,
                  hintStyle: TextStyle(
                    color: Color(0x80FFFFFF),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap:
                  viewController.canSendCode.value
                      ? viewController.onObtainCodeButtonClicked
                      : null,
              child: Obx(
                () => Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  width: 100,
                  height: 40,
                  child: Center(
                    child: Text(
                      viewController.countdown.value > 0
                          ? '${viewController.countdown.value}s'
                          : Copywriting.security_obtain_code,
                      style:
                          viewController.canSendCode.value
                              ? const TextStyle(
                                color: Color(0xFFFFEF3B),
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              )
                              : TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GestureDetector(
      onTap: viewController.login,
      child: Obx(
        () => Container(
          height: 54,
          margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          decoration: BoxDecoration(
            color:
                viewController.canContinue.value
                    ? AppColors.ocMain
                    : AppColors.ocMain.withValues(alpha: 0.5),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              Security.security_Continue,
              style: TextStyle(
                color:
                    viewController.canContinue.value
                        ? Colors.white
                        : const Color(0xFF999999),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreeText() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 24),
      child: GestureDetector(
        onTap: () {
          _onCheckButtonClicked();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          // children: [_buildCheckButton(), const SizedBox(width: 8), _buildBottomTips()],
        ),
      ),
    );
  }

  _onCheckButtonClicked() async {
    viewController.checked.value = !viewController.checked.value;
  }

  _onTermsOfServiceClicked() {
    Get.toNamed(
      Routers.webView,
      arguments: {
        Security.security_title: Copywriting.security_terms_of_service,
        Security.security_url: AppManager.instance.termsHtml,
      },
    );
  }

  _onBackButtonClicked() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.base_background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.fromLTRB(140, 140, 140, 0),
                      child: Container(
                        width: 88,
                        height: 124,
                        child: Image.asset(
                          ImagePath.app_icon,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            Copywriting.security_create_an_account,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        SizedBox(height: 34),
                        _buildMailInputView(),
                        const SizedBox(height: 12),
                        _buildVerifyCodeView(),
                        _buildContinueButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12),
                height: 44,
                child: GestureDetector(
                  onTap: _onBackButtonClicked,
                  child: Container(
                    width: 32,
                    height: 44,
                    alignment: Alignment.center,
                    child: Image.asset(ImagePath.back, width: 24, height: 24),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CreateAccountViewController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    _stopTimer();
    super.onClose();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  String account = "";
  String verifyCode = '';
  Timer? _timer;

  var countdown = 0.obs;
  var canSendCode = false.obs;
  var canContinue = false.obs;
  var checked = true.obs;

  void onMailChange(String text) {
    account = text;
    canSendCode.value = account.isNotEmpty && countdown.value == 0;
  }

  void onVerifyCodeChange(String text) {
    verifyCode = text;
    canContinue.value = account.isNotEmpty && verifyCode.isNotEmpty;
  }

  void onObtainCodeButtonClicked() {
    _getVerifyCode();
  }

  void login() async {
    if (checked.value == false) {
      EasyLoading.showError(
        Copywriting.security_please_agree_to_the_terms_and_conditions,
      );
      return;
    }

    EasyLoading.show(status: Copywriting.security_logging_in___);
    ApiResponse response = await AccountService.instance.loginWithEmail(
      account,
      verifyCode,
    );
    if (response.isSuccess) {
      EasyLoading.dismiss();
      //弹出所有页面并进入主页
      Get.offAllNamed(Routers.root);
    } else {
      EasyLoading.showError(response.description);
    }
  }

  void _getVerifyCode() async {
    EasyLoading.show(status: Copywriting.security_sending___);
    ApiResponse response = await AccountService.instance.getVerifyCode(
      account,
      AccountType.email,
    );
    if (response.isSuccess) {
      _startTimer();
      EasyLoading.dismiss();
    } else {
      EasyLoading.showError(response.description);
    }
  }

  void _startTimer() {
    countdown.value = 60;
    canSendCode.value = account.isNotEmpty && countdown.value == 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value = countdown.value - 1;
      } else {
        countdown.value = 0;
        _stopTimer();
      }
      canSendCode.value = account.isNotEmpty && countdown.value == 0;
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      _timer = null;
    }
  }
}
