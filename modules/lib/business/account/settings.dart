import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/business/account/edit_my_info_view.dart';
import 'package:modules/shared/app_theme.dart';

import '../../base/api_service/api_response.dart';
import '../../base/router/router_names.dart';
import '../../core/account/account_service.dart';
import '../../shared/alert.dart';

class SettingItem {
  String title;
  Function() onTap;

  SettingItem({required this.title, required this.onTap});
}

class AccountSettings extends StatelessWidget {
  List<SettingItem> get items => <SettingItem>[
    SettingItem(title: 'Terms of service', onTap: checkTermsOfService),
    SettingItem(title: 'Privacy policy', onTap: checkPrivacyPolicy),
    SettingItem(title: 'Account Deletion', onTap: deleteAccount),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          Security.security_Setting,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.base_background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: AppColors.base_background,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children:
                    items
                        .map(
                          (e) => GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: e.onTap,
                            child: Container(
                              height: 44,
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Text(
                                    e.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Spacer(),
                                  Image.asset(
                                    ImagePath.right_arrow,
                                    height: 16,
                                    width: 16,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
            ),

            // log out
            GestureDetector(
              onTap: logout,
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 16),
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Log out',
                  style: TextStyle(
                    color: Color(0xffF84652),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkTermsOfService() {
    Get.toNamed(
      Routers.webView.name,
      arguments: {
        Security.security_title: 'Terms of service',
        Security.security_url:
            'https://cdn.luminaai.buzz/lumina/termsofservice.html',
      },
    );
  }

  void checkPrivacyPolicy() {
    Get.toNamed(
      Routers.webView.name,
      arguments: {
        Security.security_title: 'Privacy policy',
        Security.security_url: 'https://cdn.luminaai.buzz/lumina/privacy.html',
      },
    );
  }

  void logout() {
    showConfirmAlert(
      'Log out',
      'Are you sure you want to log out?',
      onConfirm: () {
        AccountService.instance.logout();
        Get.offAllNamed(Routers.loginChannel.name);
      },
      onCancel: () {},
    );
  }

  void deleteAccount() async {
    showConfirmAlert(
      'Delete account?',
      'Are you sure you want to delete your account?',
      onConfirm: () async {
        EasyLoading.show(status: 'Deleting...');
        ApiResponse response = await AccountService.instance.deleteAccount();
        EasyLoading.dismiss();
        if (response.isSuccess) {
          Get.offAllNamed(Routers.login.name);
        } else {
          EasyLoading.showError(response.description);
        }
      },
    );
  }
}
