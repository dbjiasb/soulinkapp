import 'dart:collection';

import 'package:audioplayers/audioplayers.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
                              child: buildVoiceItem(item, item['name'], item['tags']),
                            );
                          }
                          if (_logic.selectedGender.value == 'Female' && item['gender'] == 2) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _logic.selectItem(item);
                              },
                              child: buildVoiceItem(item, item['name'], item['tags']),
                            );
                          } else if (_logic.selectedGender.value == 'Male' && item['gender'] == 1) {
                            return GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () {
                                _logic.selectItem(item);
                              },
                              child: buildVoiceItem(item, item['name'], item['tags']),
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
              icon: Image.asset('$commImgDir/icon_back.png', height: 24, width: 24),
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
                                  RotatedBox(quarterTurns: _logic.expandStatus.value, child: Image.asset('$commImgDir/icon_back.png',height: 16,width: 16,)),
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
  Map playingVoiceItem = {}.obs;

  void playVoice(Map item) {
    playingVoiceItem = item;

    player.stop();
    player.play(UrlSource(item[EncHelper.cr_eurl]));
    player.onPlayerComplete.listen((_) {
      playingVoiceItem = {};
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
              playingVoiceItem['vid'] == item['vid']
                  ? Container(margin: EdgeInsets.only(right: 8), width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.main))
                  : InkWell(
                    onTap: () {
                      playVoice(item);
                    },
                    child: Image.asset('$ocImgDir/oc_audio.png', height: 24, width: 24),
                  ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: Text(itemName, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14)),
                ),
              ),
              Obx(() {
                return _logic.selectedItem['name'] == itemName
                    ? Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(color: AppColors.ocMain, shape: BoxShape.circle),
                      child: const Padding(padding: EdgeInsets.all(2), child: Icon(Icons.check, color: Colors.white, size: 16)),
                    )
                    : Container();
              }),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(spacing: 4, runSpacing: 4, children: labels.map((label) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: Color(0xFF2F3031)),
            child: Text(label, style: TextStyle(fontWeight: FontWeight.w500, color: AppColors.undo, fontSize: 11)),
          )).toList()),
        ],
      ),
    );
  }

  Widget buildAction(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.back(
          result: {
            'name': _logic.selectedItem['name'] ?? "",
            'vid': _logic.selectedItem['vid'] ?? "",
            EncHelper.cr_eurl: _logic.selectedItem[EncHelper.cr_eurl] ?? "",
            'gender': _logic.selectedItem['gender'] ?? "",
            'def': _logic.selectedItem['def'] ?? "",
            'tags': _logic.selectedItem['tags'] != null ? List<String>.from(_logic.selectedItem['tags']) : null,
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
          child: const Text('Save', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
        ),
      ),
    );
  }
}

class OCVoiceLogic extends GetxController {
  var selectedItem = {}.obs;

  late final args;

  // 语音包配置信息
  final config = [].obs;

  var expandStatus = 1.obs;

  var genders = ['All Gender', 'Male', 'Female'];
  var selectedGender = 'All Gender'.obs;

  void resetGender(String? value) {
    selectedGender.value = value!;
  }

  void selectItem(Map input) {
    selectedItem.value = {
      'name': input['name'],
      'vid': input['vid'],
      EncHelper.cr_eurl: input[EncHelper.cr_eurl],
      'gender': input['gender'],
      'def': input['def'],
      'tags': input['tags'],
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

    final voiceLibs = Get.arguments;
    config.value =
        voiceLibs.map((item) {
          return {
            'name': item['name'] ?? "",
            'vid': item['vid'] ?? "",
            EncHelper.cr_eurl: item[EncHelper.cr_eurl] ?? "",
            'gender': item['gender'] ?? "",
            'def': item['def'] ?? "",
            'tags': item['tags'] != null ? List<String>.from(item['tags']) : null,
          };
        }).toList();
  }
}
