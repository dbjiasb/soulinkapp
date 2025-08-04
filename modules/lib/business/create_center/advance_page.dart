import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/business/create_center/my_oc_config.dart';

import '../../base/router/router_names.dart';
import '../../core/util/es_helper.dart';
import '../../shared/app_theme.dart';

class AdvanceCore extends StatelessWidget {
  final _logic = Get.put(AdvanceController());
  final masterNameFormatter = [LengthLimitingTextInputFormatter(24)];
  final imagePromptsFormatter = [LengthLimitingTextInputFormatter(300)];
  final scenarioFormatter = [LengthLimitingTextInputFormatter(500)];
  final introductionFormatter = [LengthLimitingTextInputFormatter(500)];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildTextFieldTemplate(
                  'How would you like OC to address you?',
                  'The OC will address you by the name you enter.',
                  //'Al will call you by the name you enter',
                  24,
                  masterNameFormatter,
                  _logic.onInputMasterName,
                  2,
                  _logic.masterNameController,
                  _logic.masterName,
                ),
                _buildTextFieldTemplate(
                  EncHelper.cr_img_prp,
                  'Supply detailed information about the image, such as the clothing worn, facial features, and actions. '
                      'For example, "On the moonlit balcony of a neo - Victorian mansion, an ethereal woman with bright blue hime - cut hair '
                      'leans against the railing. Her khaki backless sweater flutters gently in the breeze as she turns to look at the viewer '
                      'with an otherworldly serenity."',
                  300,
                  imagePromptsFormatter,
                  _logic.onInputImagePrompts,
                  6,
                  _logic.picPromptsController,
                  _logic.picPrompts,
                ),
                _buildTextFieldTemplate(
                  EncHelper.cr_synopsis,
                  'Describe the conversation scenario and involved characters.',
                  //'The current circumstances and context of the conversation and the characters.',
                  500,
                  scenarioFormatter,
                  _logic.onInputScenario,
                  5,
                  _logic.sceneController,
                  _logic.scene,
                ),
                _buildTextFieldTemplate(
                  EncHelper.cr_bio,
                  'Appears exclusively in your character\'s public profile.This biographical information will not be utilized in generation prompts or influence behavioral patterns.',
                  500,
                  introductionFormatter,
                  _logic.onInputIntroduction,
                  5,
                  _logic.bioController,
                  _logic.bio,
                ),
                _buildStyleBox('Dialogue Style'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTextFieldTemplate(
    String title,
    String hintText,
    int limited,
    List<LengthLimitingTextInputFormatter> formatters,
    void Function(String input) onInput,
    int maxLines,
    TextEditingController controller,
    RxString curString,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      // color: Colors.red,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w700)),
          Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocBox),
            child: Column(
              children: [
                TextField(
                  controller: controller,
                  inputFormatters: formatters,
                  onChanged: onInput,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hintText,
                    hintStyle: const TextStyle(color: Color(0xFF93A0A5), fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                  maxLines: maxLines,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                ),
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(curString.value.length.toString(), style: const TextStyle(color: Color(0xFF9EA0A5), fontSize: 11, fontWeight: FontWeight.w500)),
                      Text('/$limited', style: const TextStyle(color: Color(0xFF9EA0A5), fontSize: 11, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleBox(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, color: Color(0xFF12151C), fontWeight: FontWeight.w700)),
          Container(
            height: 356,
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocBox),
            child: Obx(
              () => Column(
                spacing: 8,
                children: [
                  const Text(
              'Defines the conversational patterns between you and your character. This crucial setting determines how your character formulates responses and maintains personality consistency.',
                    style: TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w500, fontSize: 11),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        spacing: 8,
                        children: [
                          for (int i = 0; i < _logic.dialogStyle.length; i += 1)
                            Row(
                              // i为偶数时，用户输入，i为奇数时，用户输入
                              mainAxisAlignment: i % 2 == 0 ? MainAxisAlignment.end : MainAxisAlignment.start,
                              children: [
                                ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 200),
                                  child: IntrinsicHeight(
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration:
                                          i % 2 == 0
                                              ? BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                  bottomLeft: Radius.circular(12),
                                                  bottomRight: Radius.circular(4),
                                                ),
                                              )
                                              : const BoxDecoration(
                                                color: AppColors.ocMain,
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
                                                  topRight: Radius.circular(12),
                                                  bottomLeft: Radius.circular(4),
                                                  bottomRight: Radius.circular(12),
                                                ),
                                              ),
                                      child: TextField(
                                        style: TextStyle(color: i % 2 == 0 ? Colors.black : Colors.white, fontSize: 12, fontWeight: FontWeight.w500, height: 2),
                                        controller: _logic.controllers[i],
                                        onChanged: (value) {
                                          i % 2 == 0 ? _logic.onInputDialog(Security.security_user, value, i) : _logic.onInputDialog(Security.security_bot, value, i);
                                        },
                                        maxLines: null,
                                        minLines: 1,
                                        keyboardType: TextInputType.multiline,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          border: InputBorder.none,
                                          hintText: '${EncHelper.cr_caa}user’s message',
                                          hintStyle: TextStyle(
                                            color: i % 2 == 0 ? Colors.black : Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            height: 2,
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _logic.addRound,
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: AppColors.ocMain),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Wrap(
                            runAlignment: WrapAlignment.center,
                            spacing: 4,
                            children: [
                              Image.asset(ImagePath.cr_add_pic, height: 16, width: 16),
                              const Text('Add rounds', style: TextStyle(color: Color(0xFF12151C), fontSize: 12, fontWeight: FontWeight.w500)),
                              Text(
                                '(${_logic.dialogStyle.length ~/ 2}/5）',
                                style: const TextStyle(color: Color(0xFF666666), fontSize: 11, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AdvancePage extends StatelessWidget {
  final masterNameFormatter = [LengthLimitingTextInputFormatter(24)];
  final imagePromptsFormatter = [LengthLimitingTextInputFormatter(300)];
  final scenarioFormatter = [LengthLimitingTextInputFormatter(500)];
  final introductionFormatter = [LengthLimitingTextInputFormatter(500)];
  final _logic = Get.put(AdvanceController());

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.main,
        leading: IconButton(
          onPressed: () {
            _logic.ocDependency.save();
            Get.back();
          },
          icon: Image.asset(ImagePath.back_icon, height: 24, width: 24),
        ),
        title: Text(
          textAlign: TextAlign.center,
          'Create My Character',
          style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'SF Pro bold', fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            padding: EdgeInsets.all(16),
            child: Row(
                children: [const Text('2', style: TextStyle(color: AppColors.ocMain, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'SF Pro bold')),
                  const Text('/2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 9, fontFamily: 'SF Pro bold')),]
            ),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [

            // 可滑动中间部分
            Expanded(child: CustomScrollView(slivers: [SliverFillRemaining(hasScrollBody: true, child: AdvanceCore())])),

            // 固定底部
            _buildGenBtn(),
          ],
        ),
      ),
    );
  }

  Widget _buildGenBtn() {
    return Column(
      children: [
        Obx(
          () => GestureDetector(
            onTap:
                _logic.toGen.value
                    ? _logic.toGeneratePage
                    : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: _logic.toGen.value ? AppColors.ocMain : Color(0xFF42364A),
                ),
                // 禁用状态颜色
                child: Text(
                  Security.security_Generate,
                  style: TextStyle(color: _logic.toGen.value ? Colors.white : Color(0xFF86649F), fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }

  Widget _buildTitleLine() {
    return Container(
      alignment: Alignment.topCenter,
      decoration: const BoxDecoration(),
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, top: 32),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                _logic.ocDependency.save();
                Get.back();
              },
              icon: Image.asset(ImagePath.back_icon, height: 24, width: 24),
            ),
            const Expanded(
              child: Text(
                textAlign: TextAlign.center,
                'Create My Character',
                style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'SF Pro bold', fontWeight: FontWeight.bold),
              ),
            ),
            const Text('2', style: TextStyle(color: AppColors.ocMain, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'SF Pro bold')),
            const Text('/2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 9, fontFamily: 'SF Pro bold')),
          ],
        ),
      ),
    );
  }
}

class AdvanceController extends GetxController {
  OcDependency ocDependency = Get.find<OcDependency>();

  bool get isEditPage => ocDependency.isEdit;

  Map get config => ocDependency.configs;

  final toGen = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
  }

  // 角色对创建者的称呼
  final masterName = ''.obs;
  final masterNameError = ''.obs;
  final masterNameController = TextEditingController();

  // 生图提示词
  final picPrompts = ''.obs;
  final picPromptsController = TextEditingController();

  // 场景信息
  final scene = ''.obs;
  final sceneController = TextEditingController();

  // 简介信息
  final bio = ''.obs;
  final bioController = TextEditingController();

  // 对话框
  final dialogStyle = <Map<dynamic, dynamic>>[].obs;
  final controllers = <TextEditingController>[].obs;

  ///接口方法
  void _loadDraft() {
    bioController.text = config[EncHelper.cr_bio] ?? '';
    sceneController.text = config[EncHelper.cr_synopsis] ?? '';
    picPromptsController.text = config[EncHelper.cr_imgpm] ?? '';
    masterNameController.text = config[EncHelper.cr_ownern] ?? '';

    bio.value = bioController.text;
    scene.value = sceneController.text;
    picPrompts.value = picPromptsController.text;
    masterName.value = masterNameController.text;

    toGen.value = _checkFormGenValid();
    if (config[EncHelper.cr_alts] != null) {
      for (int i = 0; i < config[EncHelper.cr_alts].length; i++) {
        controllers.add(TextEditingController());
        controllers[i].text = config[EncHelper.cr_alts][i][Security.security_content];
        dialogStyle.add(config[EncHelper.cr_alts][i]);
      }
    }
  }

  void onInputMasterName(String input) {
    masterName.value = input;
    masterNameController.text = input;
    config[EncHelper.cr_ownern] = input;
    toGen.value = _checkFormGenValid();
    if (input.length >= 3) {
      masterNameError.value = '';
    }
  }

  void onInputImagePrompts(String input) {
    picPrompts.value = input;
    picPromptsController.text = input;
    config[EncHelper.cr_imgpm] = input;
  }

  void onInputScenario(String input) {
    scene.value = input;
    config[EncHelper.cr_synopsis] = input;
  }

  void onInputIntroduction(String input) {
    bio.value = input;
    config[EncHelper.cr_bio] = input;
  }

  @override
  void dispose() {
    masterNameController.dispose();
    picPromptsController.dispose();
    sceneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void onInputDialog(String msgFrom, String content, int index) {
    dialogStyle[index][Security.security_content] = content;
    config[EncHelper.cr_alts] = dialogStyle;
    dialogStyle.refresh();
  }

  void addRound() {
    if (dialogStyle.length < 10) {
      dialogStyle.add({Security.security_msgFrom: Security.security_user, Security.security_content: '${EncHelper.cr_caa}user\'s message'});
      controllers.add(TextEditingController());
      dialogStyle.add({Security.security_msgFrom: Security.security_bot, Security.security_content: '${EncHelper.cr_caa}OC\'s message'});
      controllers.add(TextEditingController());
      config[EncHelper.cr_alts] = dialogStyle;
    }
  }

  void toGeneratePage() async {
    if (masterName.value.isNotEmpty && (masterName.value.length < 3 || masterName.value.length > 24)) {
      EasyLoading.showToast('Master name must be 2-24 characters in length');
      return;
    }
    ocDependency.save();
    Get.toNamed(Routers.createGen.name);
  }

  bool _checkFormGenValid() {
    if (masterNameController.text.length >= 3) return true;
    return false;
  }
}
