import 'dart:core';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_response.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/copywriting.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/core/account/account_service.dart';

import '../../shared/app_theme.dart';

class LoginChannel {
  LoginChannel(
    this.channel,
    this.channelName,
    this.channelIcon,
    this.channelColor,
    this.channelTextColor,
    this.onTap,
  );

  final String channel;
  final String channelName;
  Widget channelIcon;
  final Color channelColor;
  final Color channelTextColor;
  final Function onTap;
}

class LoginChannelView extends StatelessWidget {
  LoginChannelView({super.key});

  LoginChannelViewController viewController = Get.put(
    LoginChannelViewController(),
  );

  _onCheckButtonClicked() async {
    viewController.checked.value = !viewController.checked.value;
  }

  _onPrivacyPolicyClicked() {
    Get.toNamed(
      Routers.webView.name,
      // <<<<<<< HEAD
      //       arguments: {
      //         Security.security_title: 'Privacy policy',
      //         Security.security_url: 'https://cdn.luminaai.buzz/lumina/privacy.html',
      //       },
      // =======
      arguments: {
        Security.security_title: Copywriting.security_privacy_policy,
        Security.security_url: 'https://cdn.luminaai.buzz/lumina/privacy.html',
      },
      // >>>>>>> feature/feature_1.0.0
    );
  }

  _onTermsOfServiceClicked() {
    Get.toNamed(
      Routers.webView.name,
      arguments: {
        // <<<<<<< HEAD
        //         Security.security_title: 'Terms of service',
        //         Security.security_url:
        //             'https://cdn.luminaai.buzz/lumina/termsofservice.html',
        // =======
        Security.security_title: Copywriting.security_terms_of_service,
        Security.security_url:
            'https://cdn.luminaai.buzz/lumina/termsofservice.html',
        // >>>>>>> feature/feature_1.0.0
      },
    );
  }

  Widget _buildCheckButton() {
    return Obx(
      () => SizedBox(
        width: 14,
        height: 14,
        child: IconButton(
          padding: const EdgeInsets.all(0),
          onPressed: null,
          icon: Image.asset(ImagePath.check_bg),
          selectedIcon: Image.asset(ImagePath.check),
          iconSize: 14,
          isSelected: viewController.checked.value,
        ),
      ),
    );
  }

  Widget _buildBottomTips() {
    // <<<<<<< HEAD
    const TextStyle linkStyle = TextStyle(
      color: Colors.white,
      fontSize: 12,
      decoration: TextDecoration.underline,
    );
    const TextStyle normalStyle = TextStyle(
      color: Color(0xFFABABAD),
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );
    // =======
    //     const TextStyle linkStyle = TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline);
    //     const TextStyle normalStyle = TextStyle(color: Color(0xFFABABAD), fontSize: 12, fontWeight: FontWeight.w500);
    // >>>>>>> feature/feature_1.0.0

    return RichText(
      text: TextSpan(
        style: normalStyle,
        children: [
          TextSpan(text: Copywriting.security_if_you_sign_in__you_agree_to),
          TextSpan(
            text: Copywriting.security_privacy_Policy,
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
            text: Copywriting.security_terms_of_Service,
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

  Widget _buildAgreeText() {
    return GestureDetector(
      onTap: () {
        _onCheckButtonClicked();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCheckButton(),
          const SizedBox(width: 8),
          _buildBottomTips(),
        ],
      ),
    );
  }

  Widget _buildLoginChannels() {
    LoginChannel email = LoginChannel(
      Security.security_email,
      Copywriting.security_sign_in_with_E_mail,
      Icon(Icons.email, size: 24, color: Colors.white),
      AppColors.base_background,
      Colors.white,
      () {
        Get.toNamed(Routers.login.name);
      },
    );
    LoginChannel apple = LoginChannel(
      Security.security_apple,
      // <<<<<<< HEAD
      // 'Sign in with Apple',
      Copywriting.security_sign_in_with_Apple,
      Icon(Icons.apple, size: 24, color: Colors.black),
      // =======
      //       Copywriting.security_sign_in_with_Apple,
      //       Image.asset(ImagePath.login_apple, height: 24, width: 24),
      // >>>>>>> feature/feature_1.0.0
      Colors.white,
      AppColors.base_background,
      () async {
        ApiResponse response = await AccountService.instance.loginWithApple();
        if (response.isSuccess) {
          //弹出所有页面并进入主页
          Get.offAllNamed(Routers.root.name);
        } else {
          EasyLoading.showError(response.description);
        }
      },
    );

    List<LoginChannel> channels = [apple, email];

    return Column(
      children: [
        for (var channel in channels)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildLoginChannel(channel),
          ),
      ],
    );
  }

  Widget _buildLoginChannel(LoginChannel channel) {
    return GestureDetector(
      onTap: () {
        channel.onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 48),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            color: channel.channelColor,
            borderRadius: BorderRadius.all(Radius.circular(12)),
            border: Border.all(color: Color(0xFFEEEEEE), width: 1),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(left: 16, top: 15, child: channel.channelIcon),
              Container(
                alignment: Alignment.center,
                child: Text(
                  channel.channelName,
                  style: TextStyle(
                    color: channel.channelTextColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.base_background,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            SafeArea(
              child: Container(
                child: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.fromLTRB(140, 140, 140, 0),
                        child: Column(
                          spacing: 24,
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                color: Color(0xff727272),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(26),
                                ),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 3,
                                ),
                              ),
                            ),

                            Text(
                              'Soulink',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLoginChannels(),
                          SizedBox(height: 65),
                          _buildAgreeText(),
                        ],
                      ),
                    ],
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

class LoginChannelViewController extends GetxController {
  var checked = true.obs;
}
