import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/shared/app_theme.dart';
import 'package:modules/shared/sheet.dart';

import '../../core/account/account_service.dart';
import '../../core/util/file_upload.dart';
import '../../shared/widget/avatar_view.dart';


class EditMyInfoPage extends StatelessWidget {
  EditMyInfoPage({super.key});

  final EditMyInfoLogic controller = Get.put(EditMyInfoLogic());
  final picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff070512),
      appBar: AppBar(
        leading: InkWell(onTap: Get.back, child: Container(padding: EdgeInsets.all(16), child: Image.asset(ImagePath.back, fit: BoxFit.fill))),
        centerTitle: true,
        backgroundColor: Color(0xff070512),
        title: Text('Edit information', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          InkWell(
            onTap: controller.saveMyInfo,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Text(Security.security_Save, style: TextStyle(color: AppColors.ocMain, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            spacing: 8,
            children: [
              // 头像
              GestureDetector(
                onTap: onAvatarTap,
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 88,
                    width: 88,
                    child: Stack(
                      children: [
                        Obx(
                          () =>
                              MyAccount.avatar.isEmpty
                                  ? Image.asset(ImagePath.default_avatar, height: 88, width: 88)
                                  : AvatarView(url: MyAccount.avatar, size: 88),
                        ),
                        Positioned(right: 0, bottom: 0, child: Image.asset(ImagePath.camera, height: 24, width: 24)),
                      ],
                    ),
                  ),
                ),
              ),

              Container(
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1),borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    _buildNameItem(),
                    _buildGenderItem(),
                    _buildBirthdayItem(),
                  ],
                ),
              )
              // Container(
              //   padding: EdgeInsets.all(12),
              //   decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), color: Color(0xFF1E1A2E)),
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.start,
              //     children: [
              //       Text(Security.security_Profile, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
              //       Container(
              //         padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              //         height: 80,
              //         decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              //         child: TextField(
              //           controller: controller.profileController,
              //           style: TextStyle(color: Colors.white, fontSize: 11, height: 1.0),
              //           decoration: InputDecoration(
              //             border: InputBorder.none,
              //             isDense: true,
              //             hintText: 'Fill in your introduction...',
              //             hintStyle: TextStyle(color: Color(0xFF9EA1A8), fontSize: 11, fontWeight: AppFonts.medium),
              //           ),
              //           textAlignVertical: TextAlignVertical.center,
              //           textAlign: TextAlign.left,
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameItem() {
    return Container(
      height: 40,
      padding: EdgeInsets.all(12),
      child: Row(
        spacing: 4,
        children: [
          Text(Security.security_Name, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          Spacer(),
          Expanded(
            child: TextField(
              controller: controller.nameController,
              style: TextStyle(color: Colors.white, fontSize: 11, height: 1.0),
              decoration: InputDecoration(border: InputBorder.none, isDense: true),
              textAlignVertical: TextAlignVertical.center,
              textAlign: TextAlign.right,
            ),
          ),
          Image.asset(ImagePath.right_arrow, height: 16, width: 16),
        ],
      ),
    );
  }

  Widget _buildGenderItem() {
    return Container(
      height: 40,
      padding: EdgeInsets.all(12),
      child: Row(
        spacing: 4,
        children: [
          Text(Security.security_Gender, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          Spacer(),
          Obx(() => Text(controller.genderText.value, style: TextStyle(color: Colors.white, fontSize: 11, height: 1.0))),
          GestureDetector(onTap: controller.toggleGender, child: Image.asset(ImagePath.right_arrow, height: 16, width: 16)),
        ],
      ),
    );
  }

  Widget _buildBirthdayItem() {
    return Container(
      height: 40,
      padding: EdgeInsets.all(12),
      child: Row(
        spacing: 4,
        children: [
          Text(Security.security_Birthday, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
          Spacer(),
          Obx(
            () => Text(
              DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(controller.birthdayText.value)),
              style: TextStyle(color: Colors.white, fontSize: 11, height: 1.0),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final context = Get.context;
              if (context == null) {
                EasyLoading.showToast("Cannot open date picker, please retry later");
                return;
              }
              final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1950), lastDate: DateTime(2050));
              if (picked != null) {
                controller.handleBirthday(picked);
              }
            },
            child: Image.asset(ImagePath.right_arrow, height: 16, width: 16),
          ),
        ],
      ),
    );
  }

  void onAvatarTap() {
    showAppBottomSheet(
      Container(
        height: 200,
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 8,
          children: [
            GestureDetector(
              onTap: () {
                onSelectAvatar(ImageSource.gallery);
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Text('Select from gallery', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
            GestureDetector(
              onTap: () {
                onSelectAvatar(ImageSource.camera);
              },
              child: Container(
                alignment: Alignment.center,
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
                child: Text('Take it with camera', style: TextStyle(color: Colors.white, fontSize: 20)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onSelectAvatar(ImageSource source) async {
    Get.back();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      controller.handleAvatar(pickedFile);
    }
  }
}

class EditMyInfoLogic extends GetxController {
  // ProfileManager get myInfo => ProfileManager.instance;
  final nameController = TextEditingController();
  final profileController = TextEditingController();
  final genderText = ''.obs;
  final birthdayText = 0.obs;

  @override
  void onInit() {
    super.onInit();
    nameController.text = MyAccount.name;
    profileController.text = MyAccount.bio;

    birthdayText.value = MyAccount.birthday;
    genderText.value = MyAccount.gender;
  }

  void handleAvatar(XFile pickedFile) async {
    EasyLoading.show(status: 'Uploading new avatar...');
    final bytes = await pickedFile.readAsBytes();
    final imgUrl = await FilePushService.instance.upload(bytes, FileType.profile);

    if (imgUrl != null) {
      await AccountService.instance.updateMyAvatar(imgUrl);
    }
    EasyLoading.dismiss();
    EasyLoading.showToast('Avatar uploaded');
  }

  void toggleGender() {
    if(genderText.value == Security.security_Male){
      genderText.value = Security.security_Female;
    }else if(genderText.value == Security.security_Female){
      genderText.value = Security.security_unknown;
    }else{
      genderText.value = Security.security_Male;
    }
  }

  void saveMyInfo() async {
    var gender = 0;
    if(genderText.value == Security.security_Male){
      gender = 1;
    } else if(genderText.value == Security.security_Female){
      gender = 2;
    } else {
      gender = 0;
    }
    EasyLoading.show(status: 'Updating information...');
    final rtn = await AccountService.instance.updateMyInfo(
      name: nameController.text,
      birthday: birthdayText.value.toString(),
      gender: gender,
      bio: profileController.text,
    );
    if (!rtn) {
      EasyLoading.showToast('Failed to update, please retry later');
      return;
    }
    EasyLoading.showToast('Information updated.');
  }

  @override
  void onClose() {
    nameController.dispose();
    super.onClose();
  }

  void handleBirthday(DateTime picked) {
    if (picked.isAfter(DateTime.now())) {
      EasyLoading.showToast('Selected date is out of range.');
      return;
    }
    birthdayText.value = picked.millisecondsSinceEpoch;
  }
}
