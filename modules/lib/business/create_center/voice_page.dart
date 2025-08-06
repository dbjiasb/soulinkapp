import 'package:audioplayers/audioplayers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/business/create_center/my_oc_config.dart';

import '../../core/util/es_helper.dart';
import '../../shared/app_theme.dart';

class OCVoicePage extends StatelessWidget {
  final _logic = Get.put(OCVoiceLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondPage,
      body: Container(
        child: Column(
          children: [
            buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Obx(() {
                  return Column(
                    children:
                        _logic.config.map((item) {
                          if (_logic.selectedGender.value == 'All Gender') {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _logic.selectItem(item);
                              },
                              child: buildVoiceItem(item, item[Security.security_name], item[Security.security_tags]),
                            );
                          }
                          if (_logic.selectedGender.value == Security.security_Female && item[Security.security_gender] == 2) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _logic.selectItem(item);
                              },
                              child: buildVoiceItem(item, item[Security.security_name], item[Security.security_tags]),
                            );
                          } else if (_logic.selectedGender.value == Security.security_Male && item[Security.security_gender] == 1) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _logic.selectItem(item);
                              },
                              child: buildVoiceItem(item, item[Security.security_name], item[Security.security_tags]),
                            );
                          }
                          return Container();
                        }).toList(),
                  );
                }),
              ),
            ),
            buildAction(context),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  Widget buildHeader() {
    return Container(
      height: 120,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: Image.asset(ImagePath.back, height: 24, width: 24),
            ),
            const Expanded(
              child: Text(
                textAlign: TextAlign.center,
                'Audio Library',
                style: TextStyle(color: Colors.white, fontSize: 20, fontFamily: 'SF Pro bold', fontWeight: FontWeight.w700),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _logic.onGenderMenuExpand,
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Obx(
                    () => DropdownButton2<String>(
                      dropdownStyleData: DropdownStyleData(elevation: 0, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8))),
                      iconStyleData: const IconStyleData(icon: const SizedBox()),
                      value: _logic.selectedGender.value,
                      onChanged: _logic.resetGender,
                      onMenuStateChange: (isOpen) {
                        _logic.onGenderMenuExpand();
                      },
                      selectedItemBuilder: (BuildContext context) {
                        return _logic.genders.map((String value) {
                          return Obx(
                            () => Container(
                              alignment: Alignment.center,
                              child: Wrap(
                                children: [
                                  RotatedBox(quarterTurns: _logic.expandStatus.value, child: Image.asset(ImagePath.back, height: 16, width: 16)),
                                  Text(value, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          );
                        }).toList();
                      },
                      items:
                          _logic.genders.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Container(
                                alignment: Alignment.center,
                                child: Text(value, style: const TextStyle(color: Color(0xFF12151C), fontSize: 11, fontWeight: FontWeight.w600)),
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  final player = AudioPlayer();

  void playVoice(Map item) async {
    _logic.playingVoiceItem.value = item;

    await player.stop();
    player.play(UrlSource(item[EncHelper.cr_eurl]));
    player.onPlayerComplete.listen((_) {
      _logic.playingVoiceItem.value = {};
    });
  }

  Widget buildVoiceItem(Map item, String itemName, List<String> labels) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Obx(()=>_logic.playingVoiceItem[Security.security_vid] == item[Security.security_vid]
                  ? Container(margin: EdgeInsets.only(right: 8), width: 16, height: 16, child: CircularProgressIndicator(color: Color(0xff8761F1) ))
                  : InkWell(
                onTap: () {
                  playVoice(item);
                },
                child: Image.asset(ImagePath.oc_tone, height: 24, width: 24),
              )),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14)),
                ),
              ),
              Obx(() {
                return _logic.selectedItem[Security.security_name] == itemName
                    ? Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: Color(0xff8761F1), shape: BoxShape.circle),
                      child: const Padding(padding: EdgeInsets.all(2), child: Icon(Icons.check, color: Colors.black, size: 16)),
                    )
                    : Container();
              }),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children:
                labels
                    .map(
                      (label) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: Color(0xFF2F3031)),
                        child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.undo, fontSize: 11)),
                      ),
                    )
                    .toList(),
          ),
        ],
      ),
    );
  }

  Widget buildAction(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back(
          result: {
            Security.security_name: _logic.selectedItem[Security.security_name] ?? "",
            Security.security_vid: _logic.selectedItem[Security.security_vid] ?? "",
            EncHelper.cr_eurl: _logic.selectedItem[EncHelper.cr_eurl] ?? "",
            Security.security_gender: _logic.selectedItem[Security.security_gender] ?? "",
            Security.security_def: _logic.selectedItem[Security.security_def] ?? "",
            Security.security_tags: _logic.selectedItem[Security.security_tags] != null ? List<String>.from(_logic.selectedItem[Security.security_tags]) : null,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 48,
          width: 343,
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocMain),
          child: Text(Security.security_Save, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class OCVoiceLogic extends GetxController {
  var selectedItem = {}.obs;

  late final RxMap playingVoiceItem;


  late final args;

  // 语音包配置信息
  final config = [].obs;

  var expandStatus = 1.obs;

  var genders = ['All Gender', Security.security_Male, Security.security_Female];
  var selectedGender = 'All Gender'.obs;

  void resetGender(String? value) {
    selectedGender.value = value!;
  }

  void selectItem(Map input) {
    selectedItem.value = {
      Security.security_name: input[Security.security_name],
      Security.security_vid: input[Security.security_vid],
      EncHelper.cr_eurl: input[EncHelper.cr_eurl],
      Security.security_gender: input[Security.security_gender],
      Security.security_def: input[Security.security_def],
      Security.security_tags: input[Security.security_tags],
    };
  }

  void onGenderMenuExpand() {
    if (expandStatus.value == 3) {
      expandStatus.value = 1;
    } else {
      expandStatus.value = 3;
    }
  }

  @override
  void onInit() {
    super.onInit();

    playingVoiceItem = {}.obs;
    final voiceLibs = Get.arguments;
    config.value =
        voiceLibs.map((item) {
          return {
            Security.security_name: item[Security.security_name] ?? "",
            Security.security_vid: item[Security.security_vid] ?? "",
            EncHelper.cr_eurl: item[EncHelper.cr_eurl] ?? "",
            Security.security_gender: item[Security.security_gender] ?? "",
            Security.security_def: item[Security.security_def] ?? "",
            Security.security_tags: item[Security.security_tags] != null ? List<String>.from(item[Security.security_tags]) : null,
          };
        }).toList();
  }
}
