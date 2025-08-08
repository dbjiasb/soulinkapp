import 'package:modules/base/crypt/copywriting.dart';
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
    // <<<<<<< HEAD
    //     SettingItem(title: 'Terms of service', onTap: checkTermsOfService),
    //     SettingItem(title: 'Privacy policy', onTap: checkPrivacyPolicy),
    //     SettingItem(title: 'Account Deletion', onTap: deleteAccount),
    // =======
    SettingItem(
      title: Copywriting.security_terms_of_service,
      // icon: ImagePath.terms_service,
      onTap: checkTermsOfService,
    ),
    SettingItem(
      title: Copywriting.security_privacy_policy,
      // icon: ImagePath.privacy_policy,
      onTap: checkPrivacyPolicy,
    ),
    // SettingItem(title: Copywriting.security_log_out,
    //     // icon: ImagePath.log_out,
    //     onTap: logout),
    SettingItem(
      title: Copywriting.security_account_Deletion,
      // icon: ImagePath.account_deletion,
      onTap: deleteAccount,
    ),
    // >>>>>>> feature/feature_1.0.0
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
    // <<<<<<< HEAD
    //     Get.toNamed(
    //       Routers.webView.name,
    //       arguments: {
    //         Security.security_title: 'Terms of service',
    //         Security.security_url:
    //             'https://cdn.luminaai.buzz/lumina/termsofservice.html',
    //       },
    //     );
    //   }
    //
    //   void checkPrivacyPolicy() {
    //     Get.toNamed(
    //       Routers.webView.name,
    //       arguments: {
    //         Security.security_title: 'Privacy policy',
    //         Security.security_url: 'https://cdn.luminaai.buzz/lumina/privacy.html',
    //       },
    //     );
    // =======
    Get.toNamed(
      Routers.webView.name,
      arguments: {
        Security.security_title: Copywriting.security_terms_of_service,
        Security.security_url:
            'https://cdn.luminaai.buzz/lumina/termsofservice.html',
      },
    );
  }

  void checkPrivacyPolicy() {
    Get.toNamed(
      Routers.webView.name,
      arguments: {
        Security.security_title: Copywriting.security_privacy_policy,
        Security.security_url: 'https://cdn.luminaai.buzz/lumina/privacy.html',
      },
    );
    // >>>>>>> feature/feature_1.0.0
  }

  void logout() {
    showConfirmAlert(
      Copywriting.security_log_out,
      Copywriting.security_are_you_sure_you_want_to_log_out_,
      onConfirm: () {
        AccountService.instance.logout();
        Get.offAllNamed(Routers.loginChannel.name);
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
          Get.offAllNamed(Routers.login.name);
        } else {
          EasyLoading.showError(response.description);
        }
      },
    );
  }
}
