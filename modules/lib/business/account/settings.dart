import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/copywriting.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/shared/app_theme.dart';

import '../../base/api_service/api_response.dart';
import '../../base/router/router_names.dart';
import '../../core/account/account_service.dart';
import '../../shared/alert.dart';

class SettingItem {
  String title;
  String icon;
  Function() onTap;

  SettingItem({required this.title, required this.icon, required this.onTap});
}

class AccountSettings extends StatelessWidget {
  List<SettingItem> get items => <SettingItem>[
    SettingItem(title: Copywriting.security_terms_of_service, icon: ImagePath.terms_service, onTap: checkTermsOfService),
    SettingItem(title: Copywriting.security_privacy_policy, icon: ImagePath.privacy_policy, onTap: checkPrivacyPolicy),
    SettingItem(title: Copywriting.security_log_out, icon: ImagePath.log_out, onTap: logout),
    SettingItem(title: Copywriting.security_account_Deletion, icon: ImagePath.account_deletion, onTap: deleteAccount),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondPage,
      body: SafeArea(
        child: Column(
          children: [
            // 顶部标题栏
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Get.back(), child: Icon(Icons.arrow_back_ios, color: Colors.white)),
                  SizedBox(width: 16),
                  Text(Security.security_Setting, style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: items.length,
                separatorBuilder: (context, index) => Divider(color: AppColors.secondPage, height: 8),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return GestureDetector(
                    onTap: item.onTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      height: 56,
                      decoration: BoxDecoration(color: Color(0xFF1E1A2E), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        spacing: 8,
                        children: [
                          Image.asset(item.icon, width: 24, height: 24, color: Colors.white),
                          Text(item.title, style: TextStyle(color: Colors.white, fontSize: 16)),
                          Spacer(),
                          Image.asset(ImagePath.arrow_right, height: 16, width: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void checkTermsOfService() {
    Get.toNamed(
      Routers.webView,
      arguments: {
        Security.security_title: Copywriting.security_terms_of_service,
        Security.security_url: 'https://cdn.luminaai.buzz/lumina/termsofservice.html',
      },
    );
  }

  void checkPrivacyPolicy() {
    Get.toNamed(
      Routers.webView,
      arguments: {Security.security_title: Copywriting.security_privacy_policy, Security.security_url: 'https://cdn.luminaai.buzz/lumina/privacy.html'},
    );
  }

  void logout() {
    showConfirmAlert(
      Copywriting.security_log_out,
      Copywriting.security_are_you_sure_you_want_to_log_out_,
      onConfirm: () {
        AccountService.instance.logout();
        Get.offAllNamed(Routers.loginChannel);
      },
      onCancel: () {},
    );
  }

  void deleteAccount() async {
    showConfirmAlert(
      Copywriting.security_delete_account_,
      Copywriting.security_are_you_sure_you_want_to_delete_your_account_,
      onConfirm: () async {
        EasyLoading.show(status: Copywriting.security_deleting___);
        ApiResponse response = await AccountService.instance.deleteAccount();
        EasyLoading.dismiss();
        if (response.isSuccess) {
          Get.offAllNamed(Routers.login);
        } else {
          EasyLoading.showError(response.description);
        }
      },
    );
  }
}
