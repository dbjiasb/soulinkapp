import 'dart:core';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_response.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
class LoginChannel {
  LoginChannel(this.channel, this.channelName, this.channelIcon, this.channelColor, this.channelTextColor, this.onTap);

  final String channel;
  final String channelName;
  final String channelIcon;
  final Color channelColor;
  final Color channelTextColor;
  final Function onTap;
}

class LoginChannelView extends StatelessWidget {
  LoginChannelView({super.key});

  LoginChannelViewController viewController = Get.put(LoginChannelViewController());

  _onCheckButtonClicked() async {
    viewController.checked.value = !viewController.checked.value;
  }

  _onPrivacyPolicyClicked() {
    Get.toNamed(Routers.webView.name, arguments: {'title': 'Privacy policy', 'url': 'https://cdn.luminaai.buzz/lumina/privacy.html'});
  }

  _onTermsOfServiceClicked() {
    Get.toNamed(Routers.webView.name, arguments: {'title': 'Terms of service', 'url': 'https://cdn.luminaai.buzz/lumina/termsofservice.html'});
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

  Widget _buildAgreeText() {
    return GestureDetector(
      onTap: () {
        _onCheckButtonClicked();
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildCheckButton(), const SizedBox(width: 8), _buildBottomTips()],
      ),
    );
  }

  Widget _buildLoginChannels() {
    LoginChannel email = LoginChannel(
      'email',
      'Sign in with E-mail',
      'packages/modules/assets/images/login/login_mail.png',
      Color(0xFF333333),
      Colors.white,
      () {
        Get.toNamed(Routers.login.name);
      },
    );
    LoginChannel apple = LoginChannel('apple', 'Sign in with Apple', 'packages/modules/assets/images/login/login_apple.png', Colors.white, Colors.black, () async {
      ApiResponse response = await AccountService.instance.loginWithApple();
      if (response.isSuccess) {
        //弹出所有页面并进入主页
        Get.offAllNamed(Routers.root.name);
      } else {
        EasyLoading.showError(response.description);
      }
    });

    List<LoginChannel> channels = [apple, email];

    return Column(children: [for (var channel in channels) Padding(padding: const EdgeInsets.only(bottom: 12), child: _buildLoginChannel(channel))]);
  }

  Widget _buildLoginChannel(LoginChannel channel) {
    return GestureDetector(
      onTap: () {
        channel.onTap();
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 44),
        child: Container(
          height: 56,
          decoration: BoxDecoration(color: channel.channelColor, borderRadius: BorderRadius.all(Radius.circular(16))),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(left: 16, top: 16, child: Image.asset(channel.channelIcon, width: 24, height: 24)),
              Container(
                alignment: Alignment.center,
                child: Text(
                  channel.channelName,
                  style: TextStyle(color: channel.channelTextColor, fontSize: 16, fontWeight: FontWeight.bold),
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
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            Image.asset('packages/modules/assets/images/login/login_bg.png', width: double.infinity, height: double.infinity, fit: BoxFit.cover),
            SafeArea(
              child: Container(
                margin: EdgeInsets.only(top: 124, bottom: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('packages/modules/assets/images/login/login_app.png', width: 120, height: 120),
                    Column(mainAxisAlignment: MainAxisAlignment.center, children: [_buildLoginChannels(), SizedBox(height: 65), _buildAgreeText()]),
                  ],
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
