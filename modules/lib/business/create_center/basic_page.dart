import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modules/business/create_center/my_oc_config.dart';

import '../../base/router/router_names.dart';
import '../../core/util/es_helper.dart';
import '../../core/util/file_upload.dart';
import '../../shared/app_theme.dart';

class BasicCore extends StatelessWidget {
  final _controller = Get.put(BasicController());
  final imagePicker = ImagePicker();
  final soundPlayer = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _createInfoLabel('Identify'),
                const SizedBox(height: 12),
                _createRoleImageSection(),
                const SizedBox(height: 8),
                _createNameInputSection(),
                const SizedBox(height: 8),
                _createGenderSelectionSection(),
                const SizedBox(height: 20),
                _createInfoLabel('Sound'),
                const SizedBox(height: 12),
                _createSoundSelectionSection(),
                const SizedBox(height: 20),
                _createInfoLabel('Age'),
                const SizedBox(height: 12),
                _createAgeSliderSection(),
                const SizedBox(height: 20),
                _createInfoLabel('Personality'),
                const SizedBox(height: 12),
                _createShynessSliderSection(),
                const SizedBox(height: 8),
                _createOptimismSliderSection(),
                const SizedBox(height: 8),
                _createMysterySliderSection(),
                const SizedBox(height: 20),
                _createInfoLabel('Physique'),
                const SizedBox(height: 12),
                _createBodyTypeSliderSection(),
                const SizedBox(height: 32),
                _createPhysiqueDetailsSection(),
                const SizedBox(height: 20),
                _createPhysiqueToggleButton(),
                Obx(() => _controller.expandPhysiqueRotate.value == 3 ? _createCollapsedPhysiqueDetails() : Container()),
                SafeArea(top: false, child: SizedBox()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _selectProfilePicture() {
    Get.bottomSheet(
      Container(
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  _pickImageFromSource(ImageSource.gallery);
                },
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: AppColors.ocBox),
                  child: GestureDetector(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Select from gallery', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500))],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GestureDetector(
                onTap: () {
                  _pickImageFromSource(ImageSource.camera);
                },
                child: Container(
                  height: 50,
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(15)), color: AppColors.ocBox),
                  child: GestureDetector(
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [Text('Take it with camera', style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500))],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  Widget _createInfoLabel(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 4,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
          const Text('*', style: TextStyle(color: AppColors.ocMain, fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _createRoleImageSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocBox),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(children: [Text('Role image', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))]),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _selectProfilePicture();
                  },
                  child: SizedBox(
                    height: 100,
                    width: 100,
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(color: const Color(0xFF181620), borderRadius: BorderRadius.circular(8)),
                          child: Obx(() {
                            if (_controller.processingImage.value) {
                              return Center(child: CircularProgressIndicator(color: AppColors.ocMain));
                            }

                            if (_controller.characterImageUrl.value.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: _controller.characterImageUrl.value,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }

                            if (_controller.selectedImageFile.value.path.isNotEmpty) {
                              return ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_controller.selectedImageFile.value.path),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }

                            return Center(child: Image.asset('$ocImgDir/oc_add_pic.png', height: 24, width: 24));
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                const Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        style: TextStyle(fontSize: 11, color: AppColors.undo, fontWeight: FontWeight.w500),
                        maxLines: 2,
                        'The uploaded image serves as a reference for facial features and style elements',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _createNameInputSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        height: 90,
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocBox),
        child: Column(
          children: [
            Obx(
              () => Row(
                children: [
                  const Text('Name', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                  Expanded(
                    child: Text(
                      textAlign: TextAlign.center,
                      _controller.nameValidationError.value,
                      style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              alignment: Alignment.center,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8)), color: Color(0xFF181620)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller.nameInputController,
                      onChanged: _controller.updateCharacterName,
                      inputFormatters: _controller.nameInputRestrictions,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: InputBorder.none,
                        hintText: 'Name your character',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 11, height: 1.2, fontWeight: FontWeight.w500),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.2, fontWeight: FontWeight.w500),
                    ),
                  ),
                  Obx(() {
                    if (_controller.characterName.value.length < 20) {
                      return Text(_controller.characterName.value.length.toString(), style: const TextStyle(color: Colors.white, fontSize: 11));
                    } else {
                      return Text(_controller.characterName.value.length.toString(), style: const TextStyle(color: Colors.red, fontSize: 11));
                    }
                  }),
                  const Text('/20', style: TextStyle(color: Color(0xFF9EA0A5), fontSize: 11, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createGenderSelectionSection() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          height: 90,
          decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12)), color: AppColors.ocBox),
          child: Column(
            children: [
              const Row(children: [Text('Gender', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12))]),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _controller.selectGender(2);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: _controller.selectedGender.value == 2 ? Border.all(width: 2, color: const Color(0xFFFF46A4)) : null,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          color: AppColors.secondPage,
                        ),
                        height: 40,
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(width: 24, height: 24, '$commImgDir/female.png'),
                              const SizedBox(width: 4),
                              const Text('Female', style: TextStyle(color: Color(0xFFF832B2), fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _controller.selectGender(1);
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: _controller.selectedGender.value == 1 ? Border.all(width: 2, color: const Color(0xFF4694FF)) : null,
                          borderRadius: const BorderRadius.all(Radius.circular(8)),
                          color: AppColors.secondPage,
                        ),
                        height: 40,
                        child: Container(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(width: 24, height: 24, '$commImgDir/male.png'),
                              const SizedBox(width: 4),
                              const Text('Female', style: TextStyle(color: Color(0xFF339FF0), fontSize: 11, fontWeight: FontWeight.w600)),
                            ],
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
      );
    });
  }

  void playSelectedSound() {
    if (_controller.selectedSound[EncHelper.cr_eurl] != null && _controller.selectedSound[EncHelper.cr_eurl] != '' && _controller.soundPlaying.value == false) {
      _controller.soundPlaying.value = true;
      soundPlayer.play(UrlSource(_controller.selectedSound[EncHelper.cr_eurl]));
      soundPlayer.onPlayerComplete.listen((_) => _controller.soundPlaying.value = false);
    } else {
      _controller.soundSelected.value = false;
    }
  }

  Widget _createSoundSelectionSection() {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Container(
          decoration: BoxDecoration(color: AppColors.ocBox, borderRadius: BorderRadius.all(Radius.circular(12))),
          height: 48,
          child: Row(
            children: [
              GestureDetector(
                onTap: playSelectedSound,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      const SizedBox(width: 12),
                      _controller.soundPlaying.value
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.main))
                          : Image.asset(height: 24, width: 24, '$ocImgDir/oc_audio.png'),
                      const SizedBox(width: 8),
                      const Text('Click to play', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF999999))),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    _controller.navigateToVoiceLibrary();
                  },
                  child: Container(
                    color: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    alignment: Alignment.centerRight,
                    child: Row(
                      spacing: 20,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        _controller.selectedSound['name'] != null
                            ? Text(_controller.selectedSound['name'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.undo))
                            : Container(),
                        Image.asset(height: 16, width: 16, '$commImgDir/arrow_right.png'),
                        const SizedBox(width: 12),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createAgeSliderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: BoxDecoration(color: AppColors.ocBox, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('18', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                  Text('60', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                ],
              ),
              Obx(
                () => Slider(
                  activeColor: AppColors.ocMain,
                  inactiveColor: const Color(0xFF171425),
                  min: 18,
                  max: 60,
                  label: _controller.characterAge.value.toInt().toString(),
                  value: _controller.characterAge.value.toDouble(),
                  onChanged: (value) => _controller.adjustAge(value.toInt()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createShynessSliderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.ocBox, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Shy', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                  Text('Flirty', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                ],
              ),
              Obx(
                () => Slider(
                  activeColor: AppColors.ocMain,
                  inactiveColor: const Color(0xFF171425),
                  min: 0,
                  max: 100,
                  value: _controller.shynessLevel.value,
                  onChanged: _controller.adjustShynessLevel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createOptimismSliderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.ocBox, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(EncHelper.cr_pesi, style: const TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                  const Text('Optimistic', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                ],
              ),
              Obx(
                () => Slider(
                  activeColor: AppColors.ocMain,
                  inactiveColor: const Color(0xFF171425),
                  min: 0,
                  max: 100,
                  value: _controller.optimismLevel.value,
                  onChanged: _controller.adjustOptimismLevel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createMysterySliderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.ocBox, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Row(
                children: [
                  Expanded(
                    child: Text(textAlign: TextAlign.left, 'Ordinary', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                  ),
                  Expanded(
                    child: Text(textAlign: TextAlign.right, 'Mysterious', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                  ),
                ],
              ),
              Obx(
                () => Slider(
                  activeColor: AppColors.ocMain,
                  inactiveColor: const Color(0xFF171425),
                  min: 0,
                  max: 100,
                  value: _controller.mysteryLevel.value,
                  onChanged: _controller.adjustMysteryLevel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createBodyTypeSliderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.ocBox, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Slim', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                  Text('Curvy', style: TextStyle(color: AppColors.undo, fontWeight: FontWeight.w500, fontSize: 11)),
                ],
              ),
              Obx(
                () => Slider(
                  activeColor: AppColors.ocMain,
                  inactiveColor: const Color(0xFF171425),
                  min: 0,
                  max: 100,
                  value: _controller.bodyType.value.toDouble(),
                  onChanged: _controller.adjustBodyType,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createPhysiqueToggleButton() {
    return GestureDetector(
      onTap: _controller.togglePhysiqueExpansion,
      child: Container(
        height: 32,
        width: 108,
        decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20)), color: AppColors.secondPage),
        child: Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Physique', style: TextStyle(color: AppColors.undo, fontSize: 11, fontWeight: FontWeight.w500)),
              SizedBox(width: 4),
              RotatedBox(quarterTurns: _controller.expandPhysiqueRotate.value, child: Image.asset('$commImgDir/arrow_right.png', width: 16, height: 16)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _createPhysiqueDetailsSection() {
    return Obx(() {
      final labels = _controller.selectedGender.value == 1 ? _controller.femalePhysiqueLabels : _controller.malePhysiqueLabels;
      return Column(
        children:
            labels.map((item) {
              final itemKey = item['itemKey'] as String? ?? '';
              final tags = item['tags'] as List<String>? ?? [];

              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemKey, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            tags
                                .map(
                                  (tag) => GestureDetector(
                                    onTap: () => _controller.selectPhysiqueAttribute(itemKey, tag),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _controller.physiqueAttributes[itemKey] == tag ? AppColors.ocMain : AppColors.undo, width: 2),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          color: _controller.physiqueAttributes[itemKey] == tag ? AppColors.ocMain : AppColors.undo,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      );
    });
  }

  Widget _createCollapsedPhysiqueDetails() {
    return Obx(() {
      final labels = _controller.selectedGender.value == 1 ? _controller.femaleCollapsedPhysiqueLabels : _controller.maleCollapsedPhysiqueLabels;

      return Column(
        children:
            labels.map((item) {
              final itemKey = item['itemKey'] as String? ?? '';
              final tags = item['tags'] as List<String>? ?? [];

              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(itemKey, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Wrap(
                        alignment: WrapAlignment.start,
                        spacing: 8,
                        runSpacing: 8,
                        children:
                            tags
                                .map(
                                  (tag) => GestureDetector(
                                    onTap: () => _controller.selectPhysiqueAttribute(itemKey, tag),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: _controller.physiqueAttributes[itemKey] == tag ? AppColors.ocMain : AppColors.undo, width: 2),
                                      ),
                                      child: Text(
                                        tag,
                                        style: TextStyle(
                                          color: _controller.physiqueAttributes[itemKey] == tag ? AppColors.ocMain : AppColors.undo,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
      );
    });
  }

  Future<void> _pickImageFromSource(ImageSource source) async {
    final selectedImage = await imagePicker.pickImage(source: source);
    if (selectedImage != null) {
      _controller.setSelectedImage(selectedImage);
    }
    Get.back();
  }
}

class BasicPage extends StatelessWidget {
  final _controller = Get.put(BasicController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.main,
        leading: IconButton(
          onPressed: () {
            _controller.ocDependency.save();
            Get.back();
          },
          icon: Image.asset('$commImgDir/icon_back.png', height: 24, width: 24),
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
              children: [const Text('1', style: TextStyle(color: AppColors.ocMain, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'SF Pro bold')),
                const Text('/2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 9, fontFamily: 'SF Pro bold')),]
            ),
          )
        ],
      ),
      backgroundColor: AppColors.main,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(child: CustomScrollView(slivers: [SliverFillRemaining(hasScrollBody: true, child: BasicCore())])),
            _buildFooterSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildFooterSection() {
    return Column(
      children: [
        Obx(
          () => GestureDetector(
            onTap:
                _controller.canProceed.value
                    ? () {
                      _controller.ocDependency.save();
                      Get.toNamed(Routers.createAdvance.name);
                    }
                    : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  color: _controller.canProceed.value ? AppColors.ocMain : Color(0xFF42364A),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(color: _controller.canProceed.value ? Colors.white : Color(0xFF86649F), fontSize: 14, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}

class BasicController extends GetxController {
  OcDependency ocDependency = Get.find<OcDependency>();

  bool get isEditMode => ocDependency.isEdit;

  Map get characterConfig => ocDependency.configs;

  get saveCharacter => ocDependency.save();

  // Navigation control
  final canProceed = false.obs;

  // Profile image
  final selectedImageFile = XFile('').obs;
  final characterImageUrl = ''.obs;
  final processingImage = false.obs;

  // Character name
  final characterName = ''.obs;
  final nameInputController = TextEditingController();
  final nameValidationError = ''.obs;
  final nameInputRestrictions = [LengthLimitingTextInputFormatter(20)];

  // Character gender
  final selectedGender = 2.obs;

  // Character age
  final characterAge = 18.obs;

  // Voice settings
  final voiceConfigurations = <Map<dynamic, dynamic>>[].obs;
  final selectedSound = {}.obs;
  final soundPlaying = false.obs;
  final soundSelected = false.obs;

  // Personality traits
  final shynessLevel = 0.0.obs;
  final optimismLevel = 0.0.obs;
  final mysteryLevel = 0.0.obs;
  final bodyType = 0.0.obs;

  // Physique attributes
  final physiqueAttributes = <dynamic, dynamic>{}.obs;
  final malePhysiqueLabels = <Map>[].obs;
  final femalePhysiqueLabels = <Map>[].obs;
  late List<Map> maleCollapsedPhysiqueLabels = [];
  late List<Map> femaleCollapsedPhysiqueLabels = [];
  final expandPhysiqueRotate = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCharacterDraft();
    canProceed.value = _validateForm();
    _fetchCharacterConfiguration();
  }

  void _loadCharacterDraft() {
    // Profile image
    characterImageUrl.value = characterConfig[EncHelper.cr_piurl] ?? '';

    // Name
    characterName.value = characterConfig['nickName'] ?? '';
    nameInputController.text = characterName.value;

    // Age
    if (characterConfig['age'] == null || characterConfig['age'] < 18 || characterConfig['age'] > 60) {
      characterAge.value = 18;
    } else {
      characterAge.value = characterConfig['age'];
    }

    // Gender
    selectedGender.value = characterConfig['gender'] ?? 2;

    physiqueAttributes.value = characterConfig[EncHelper.cr_cfg] ?? {};

    if (physiqueAttributes['shy'] != null) {
      shynessLevel.value = double.parse(physiqueAttributes['shy'].toString());
    }

    if (physiqueAttributes[EncHelper.cr_pesi] != null) {
      optimismLevel.value = double.parse(physiqueAttributes[EncHelper.cr_pesi].toString());
    }

    if (physiqueAttributes['Ordinary'] != null) {
      mysteryLevel.value = double.parse(physiqueAttributes['Ordinary'].toString());
    }

    if (physiqueAttributes['Slim'] != null) {
      bodyType.value = double.parse(physiqueAttributes['Slim'].toString());
    }
  }

  Future<void> _fetchCharacterConfiguration() async {
    OcManager.instance.getPhysiques().then((configMap) {
      if (configMap == null) {
        EasyLoading.showToast('Cannot get physique details, please retry later');
        return;
      }

      malePhysiqueLabels.value =
          RxList.from(configMap['config'][EncHelper.cr_dis_cfg]['2'][EncHelper.cr_apr][EncHelper.cr_exim] as List).map((item) {
            return {
              'itemKey': item['itemKey'] ?? "",
              'showType': item['showType'] ?? 0,
              'desc': item['desc'] ?? "",
              'startDesc': item['startDesc'] ?? "",
              'endDesc': item['endDesc'] ?? "",
              'startValue': item['startValue'] ?? 0,
              'endValue': item['endValue'] ?? 0,
              'defaultValue': item['defaultValue'] ?? 0,
              'tags': item['tags'] != null ? List<String>.from(item['tags']) : null,
              EncHelper.cr_defval2: item[EncHelper.cr_defval2] ?? "",
              EncHelper.cr_tbs: item[EncHelper.cr_tbs] != null ? List<String>.from(item[EncHelper.cr_tbs]) : null,
              'icon': item['icon'] ?? "",
            };
          }).toList();
      malePhysiqueLabels.refresh();
      maleCollapsedPhysiqueLabels.addAll(
        (configMap['config'][EncHelper.cr_dis_cfg]['2'][EncHelper.cr_apr][EncHelper.cr_fields] as List).map((item) {
          return {
            'itemKey': item['itemKey'] ?? "",
            'showType': item['showType'] ?? 0,
            'desc': item['desc'] ?? "",
            'startDesc': item['startDesc'] ?? "",
            'endDesc': item['endDesc'] ?? "",
            'startValue': item['startValue'] ?? 0,
            'endValue': item['endValue'] ?? 0,
            'defaultValue': item['defaultValue'] ?? 0,
            'tags': item['tags'] != null ? List<String>.from(item['tags']) : null,
            EncHelper.cr_defval2: item[EncHelper.cr_defval2] ?? "",
            EncHelper.cr_tbs: item[EncHelper.cr_tbs] != null ? List<String>.from(item[EncHelper.cr_tbs]) : null,
            'icon': item['icon'] ?? "",
          };
        }).toList(),
      );

      femalePhysiqueLabels.value =
          RxList.from(configMap['config'][EncHelper.cr_dis_cfg]['1'][EncHelper.cr_apr][EncHelper.cr_exim] as List).map((item) {
            return {
              'itemKey': item['itemKey'] ?? "",
              'showType': item['showType'] ?? 0,
              'desc': item['desc'] ?? "",
              'startDesc': item['startDesc'] ?? "",
              'endDesc': item['endDesc'] ?? "",
              'startValue': item['startValue'] ?? 0,
              'endValue': item['endValue'] ?? 0,
              'defaultValue': item['defaultValue'] ?? 0,
              'tags': item['tags'] != null ? List<String>.from(item['tags']) : null,
              EncHelper.cr_defval2: item[EncHelper.cr_defval2] ?? "",
              EncHelper.cr_tbs: item[EncHelper.cr_tbs] != null ? List<String>.from(item[EncHelper.cr_tbs]) : null,
              'icon': item['icon'] ?? "",
            };
          }).toList();
      femalePhysiqueLabels.refresh();

      femaleCollapsedPhysiqueLabels.addAll(
        (configMap['config'][EncHelper.cr_dis_cfg]['1'][EncHelper.cr_apr][EncHelper.cr_fields] as List).map((item) {
          return {
            'itemKey': item['itemKey'] ?? "",
            'showType': item['showType'] ?? 0,
            'desc': item['desc'] ?? "",
            'startDesc': item['startDesc'] ?? "",
            'endDesc': item['endDesc'] ?? "",
            'startValue': item['startValue'] ?? 0,
            'endValue': item['endValue'] ?? 0,
            'defaultValue': item['defaultValue'] ?? 0,
            'tags': item['tags'] != null ? List<String>.from(item['tags']) : null,
            EncHelper.cr_defval2: item[EncHelper.cr_defval2] ?? "",
            EncHelper.cr_tbs: item[EncHelper.cr_tbs] != null ? List<String>.from(item[EncHelper.cr_tbs]) : null,
            'icon': item['icon'] ?? "",
          };
        }).toList(),
      );

      // Voice configurations
      voiceConfigurations.addAll(List<Map<dynamic, dynamic>>.from(configMap['config'][EncHelper.cr_tcfg]));

      if (characterConfig[EncHelper.cr_tvid].isNotEmpty) {
        for (var config in voiceConfigurations) {
          if (config['vid'] == characterConfig[EncHelper.cr_tvid]) {
            selectedSound.value = {
              'name': config['name'],
              'vid': config['vid'],
              EncHelper.cr_eurl: config[EncHelper.cr_eurl],
              'gender': config['gender'],
              'def': config['def'],
              'tags': config['tags'],
            };
            break;
          }
        }
      }
    });
  }

  void setSelectedImage(XFile imageFile) async {
    processingImage.value = true;
    selectedImageFile.value = imageFile;
    final imageData = await imageFile.readAsBytes();
    final uploadedImageUrl = await FilePushService.instance.upload(imageData, FileType.profile);

    if (uploadedImageUrl != null) {
      characterImageUrl.value = uploadedImageUrl;
      canProceed.value = _validateForm();
      final validationResult = await OcManager.instance.checkPic(uploadedImageUrl);
      characterConfig[EncHelper.cr_piurl] = uploadedImageUrl;
      ocDependency.traceId = validationResult?['statusInfo']?['traceId'] ?? '';
    } else {
      EasyLoading.showToast('Unknown error, please upload again.');
    }
    processingImage.value = false;
  }

  void updateCharacterName(String input) {
    characterName.value = input;
    characterConfig['nickName'] = characterName.value;
    if (characterName.value.length >= 3) {
      nameValidationError.value = '';
    }
    canProceed.value = _validateForm();
  }

  void selectGender(int genderValue) {
    selectedGender.value = genderValue;
    characterConfig['gender'] = selectedGender.value;
  }

  void navigateToVoiceLibrary() async {
    final selectedVoice = await Get.toNamed(Routers.createVoice.name, arguments: voiceConfigurations);
    if (selectedVoice != null) {
      selectedSound.value = {
        'name': selectedVoice['name'],
        'vid': selectedVoice['vid'],
        EncHelper.cr_eurl: selectedVoice[EncHelper.cr_eurl],
        'gender': selectedVoice['gender'],
        'def': selectedVoice['def'],
        'tags': selectedVoice['tags'],
      };
      characterConfig[EncHelper.cr_tvid] = selectedVoice['vid'];
      characterConfig[EncHelper.cr_cfg]['mp3_url'] = selectedSound[EncHelper.cr_eurl];
      characterConfig[EncHelper.cr_cfg]['mp3_name'] = selectedSound['name'];
      soundSelected.value = true;
    }
  }

  void adjustAge(int newAge) {
    characterAge.value = newAge;
    characterConfig['age'] = characterAge.value;
  }

  void adjustShynessLevel(double level) {
    shynessLevel.value = level;
    characterConfig[EncHelper.cr_cfg]['shy'] = level.toInt();
  }

  void adjustOptimismLevel(double level) {
    optimismLevel.value = level;
    characterConfig[EncHelper.cr_cfg][EncHelper.cr_pesi] = level.toInt();
  }

  void adjustMysteryLevel(double level) {
    mysteryLevel.value = level;
    characterConfig[EncHelper.cr_cfg]['Ordinary'] = level.toInt();
  }

  void adjustBodyType(double type) {
    bodyType.value = type;
    characterConfig[EncHelper.cr_cfg]['Slim'] = type.toInt();
  }

  void selectPhysiqueAttribute(String key, String value) {
    physiqueAttributes[key] = value;
    physiqueAttributes.refresh();
    characterConfig[EncHelper.cr_cfg][key] = value;
  }

  void togglePhysiqueExpansion() {
    expandPhysiqueRotate.value = expandPhysiqueRotate.value == 1 ? 3 : 1;
  }

  bool _validateForm() {
    if (characterImageUrl.value.isNotEmpty && nameInputController.text.length >= 3) return true;
    return false;
  }
}
