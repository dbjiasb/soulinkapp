import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/business/account/edit_my_info_view.dart';
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
    SettingItem(title: 'Terms of service', icon: 'packages/modules/assets/images/terms_service.png', onTap: checkTermsOfService),
    SettingItem(title: 'Privacy policy', icon: 'packages/modules/assets/images/privacy_policy.png', onTap: checkPrivacyPolicy),
    SettingItem(title: 'Log out', icon: 'packages/modules/assets/images/log_out.png', onTap: logout),
    SettingItem(title: 'Account Deletion', icon: 'packages/modules/assets/images/account_deletion.png', onTap: deleteAccount),
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
                  Text('Setting', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
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
                          Image.asset('$assetsDir/arrow_right.png', height: 16, width: 16),
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
    Get.toNamed(Routers.webView.name, arguments: {'title': 'Terms of service', 'url': 'https://cdn.luminaai.buzz/lumina/termsofservice.html'});
  }

  void checkPrivacyPolicy() {
    Get.toNamed(Routers.webView.name, arguments: {'title': 'Privacy policy', 'url': 'https://cdn.luminaai.buzz/lumina/privacy.html'});
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
