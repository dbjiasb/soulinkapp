import 'package:modules/base/crypt/security.dart';
import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_service_export.dart';
import 'package:modules/core/account/account_service.dart';

import '../../base/router/router_names.dart';

class CreateAccountView extends StatelessWidget {
  CreateAccountView({super.key});

  CreateAccountViewController viewController = Get.put(CreateAccountViewController());

  Widget _buildMailInputView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        height: 56,
        decoration: const BoxDecoration(color: Color(0xFF333333), borderRadius: BorderRadius.all(Radius.circular(16))),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Image.asset('packages/modules/assets/images/login/login_mail.png', width: 24, height: 24),
            ),
            Expanded(
              child: TextFormField(
                onChanged: viewController.onMailChange,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                textAlignVertical: TextAlignVertical.center,
                decoration: const InputDecoration(
                  labelStyle: TextStyle(color: Colors.white),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide(style: BorderStyle.none)),
                  hintText: 'Email Address',
                  hintStyle: TextStyle(color: Color(0x80FFFFFF), fontWeight: FontWeight.w600, fontSize: 13),
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
        height: 56,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(16)), color: Color(0xFF333333)),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Image.asset('packages/modules/assets/images/login/login_verify_code.png', width: 24, height: 24),
            ),
            Expanded(
              child: TextFormField(
                onChanged: viewController.onVerifyCodeChange,
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  focusedBorder: OutlineInputBorder(borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderSide: BorderSide.none),
                  hintText: 'Enter verification code',
                  hintStyle: TextStyle(color: Color(0x80FFFFFF), fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            GestureDetector(
              onTap: viewController.canSendCode.value ? viewController.onObtainCodeButtonClicked : null,
              child: Obx(
                () => Container(
                  margin: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  decoration: BoxDecoration(
                    color: viewController.canSendCode.value ? const Color(0xFFE962F6) : const Color(0xFF999999),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  width: 100,
                  height: 40,
                  child: Center(
                    child: Text(
                      viewController.countdown.value > 0 ? '${viewController.countdown.value}s' : 'Obtain code',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
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
          height: 56,
          margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF383642),
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            gradient: viewController.canContinue.value ? const LinearGradient(colors: <Color>[Color(0xFF8556FE), Color(0xFFF656FF)]) : null,
          ),
          child: Center(
            child: Text(
              Security.security_Continue,
              style: TextStyle(color: viewController.canContinue.value ? Colors.white : const Color(0xFF999999), fontSize: 16, fontWeight: FontWeight.bold),
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
          children: [_buildCheckButton(), const SizedBox(width: 8), _buildBottomTips()],
        ),
      ),
    );
  }

  _onCheckButtonClicked() async {
    viewController.checked.value = !viewController.checked.value;
  }

  _onPrivacyPolicyClicked() {
    Get.toNamed(Routers.webView.name, arguments: {Security.security_title: 'Privacy policy', Security.security_url: 'https://cdn.luminaai.buzz/lumina/privacy.html'});
  }

  _onTermsOfServiceClicked() {
    Get.toNamed(Routers.webView.name, arguments: {Security.security_title: 'Terms of service', Security.security_url: 'https://cdn.luminaai.buzz/lumina/termsofservice.html'});
  }

  Widget _buildCheckButton() {
    return Obx(
      () => SizedBox(
        width: 14,
        height: 14,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: null,
          icon: Image.asset('packages/modules/assets/images/login/login_unselect.png'),
          selectedIcon: Image.asset('packages/modules/assets/images/login/login_selected.png'),
          iconSize: 14,
          isSelected: viewController.checked.value,
        ),
      ),
    );
  }

  Widget _buildBottomTips() {
    const TextStyle linkStyle = TextStyle(color: Color(0xFFE962F6), decoration: TextDecoration.underline);
    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Color(0xFF90929D), fontSize: 12, fontWeight: FontWeight.w500),
        children: [
          const TextSpan(text: 'if you sign in, you agree to '),
          TextSpan(
            text: 'Privacy Policy',
            style: linkStyle,
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    _onPrivacyPolicyClicked();
                  },
          ),
          const TextSpan(text: ' \n'),
          const TextSpan(text: 'and '),
          TextSpan(
            text: 'Terms of Service',
            style: linkStyle,
            recognizer:
                TapGestureRecognizer()
                  ..onTap = () {
                    _onTermsOfServiceClicked();
                  },
          ),
        ],
      ),
    );
  }

  _onBackButtonClicked() {
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Image.asset('packages/modules/assets/images/login/login_bg.png', width: double.infinity, height: double.infinity, fit: BoxFit.cover),
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: 124),
                        Image.asset('packages/modules/assets/images/login/login_app.png', width: 120, height: 120),
                        SizedBox(height: 62),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          alignment: Alignment.centerLeft,
                          child: Text('Create an account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                        ),
                        SizedBox(height: 34),
                        _buildMailInputView(),
                        const SizedBox(height: 12),
                        _buildVerifyCodeView(),
                        _buildContinueButton(),
                      ],
                    ),
                    // _buildAgreeText(),
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
                    child: Image.asset('packages/modules/assets/images/icon_back.png', width: 24, height: 24),
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
      EasyLoading.showError('Please agree to the terms and conditions');
      return;
    }

    EasyLoading.show(status: 'Logging in...');
    ApiResponse response = await AccountService.instance.loginWithEmail(account, verifyCode);
    if (response.isSuccess) {
      EasyLoading.dismiss();
      //弹出所有页面并进入主页
      Get.offAllNamed(Routers.root.name);
    } else {
      EasyLoading.showError(response.description);
    }
  }

  void _getVerifyCode() async {
    EasyLoading.show(status: 'Sending...');
    ApiResponse response = await AccountService.instance.getVerifyCode(account, AccountType.email);
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
