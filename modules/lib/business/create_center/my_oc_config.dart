import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:modules/base/api_service/api_request.dart';
import 'package:modules/base/api_service/api_service.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/util/es_helper.dart';

const commImgDir = 'packages/modules/assets/images';
const ocImgDir = '$commImgDir/oc';
const ocAnimDir = 'packages/modules/assets/anim';

final account = AccountService.instance.account;

class GenerationResult {
  String url = ''; // 返回结果的url
  String localPath = ''; // 本地文件缓存路径
  String cropPath = ''; // 裁剪文件缓存路径
}

class OcManager {
  //生成单利
  OcManager._internal();

  static final OcManager _instance = OcManager._internal();

  factory OcManager() {
    return _instance;
  }

  static OcManager get instance => _instance;

  Future<Map?> getDraft() async {
    final req = ApiRequest(EncHelper.cr_fod, params: {});
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      return rsp.data;
    }
    return null;
  }

  Future<Map?> getPhysiques() async {
    final req = ApiRequest(EncHelper.cr_fpd, params: {});
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      return rsp.data;
    }
    return null;
  }

  Future<Map?> checkPic(String url) async {
    final req = ApiRequest(EncHelper.cr_ckpic, params: {EncHelper.cr_img_url: url});
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      return rsp.data;
    }
    return null;
  }

  Future<Map?> ocOptions(Map<dynamic, dynamic> info, int optType, List<String> generateImages, String changeFaceTraceId, int? roleUid) async {
    final args = {
      EncHelper.cr_ro_in: info,
      EncHelper.cr_cr_code: optType,
      EncHelper.cr_imgs: generateImages,
      EncHelper.cr_rl_id: changeFaceTraceId
    };
    if (roleUid != null) {
      args[EncHelper.cr_cccid] = roleUid;
    }
    final req = ApiRequest(EncHelper.cr_opr, params: args);
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      return rsp.data;
    }
    return null;
  }

  Future<Map?> generateImageBg(Map<dynamic, dynamic> info, int generateOptType) async {
    final req = ApiRequest(EncHelper.cr_askgen, params: {
      EncHelper.cr_ro_in: info,
      EncHelper.cr_cre_code: generateOptType
    });
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp. isSuccess) {
      return rsp.data;
    }
    return null;
  }

  Future<Map?> getGenResult(String traceId) async {
    final req = ApiRequest(EncHelper.cr_ask_gen_rsp, params: {
      EncHelper.cr_cre_id: traceId
    });
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      return rsp.data;
    }
    return null;
  }

  Future<Map?> getEditRoleInfo(int uid) async {
    final req = ApiRequest(EncHelper.cr_fed, params: {
      EncHelper.cr_cccid: uid
    });
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      return rsp.data;
    }
    return null;
  }
}

class OcDependency {
  
  bool isEdit = false;
  var configs = <dynamic, dynamic>{};
  var traceId = '';
  final results = <GenerationResult>[];

  // 需要后端定义的字段
  var generateImgs = <String>[];
  
  // 缓存目录
  Directory? dir;

  // 构造函数
  OcDependency(Map<dynamic, dynamic>? map) {
    if (map != null) {
      _initializeFromMap(map);
    } else {
      _setDefaultValues();
    }
  }

  void _initializeFromMap(Map<dynamic, dynamic> map) {
    final roleInfo = map['info']?['roleInfo'] ?? map[EncHelper.cr_cusri];
    if (roleInfo == null) return;

    // 设置必填字段
    configs['uid'] = roleInfo['uid'];
    configs['nickName'] = roleInfo['nickName'];
    configs['gender'] = (roleInfo['gender'] == 1 || roleInfo['gender'] == 2) ? roleInfo['gender'] : 2;
    configs['chatBackground'] = roleInfo['chatBackground'];
    configs['masterUid'] = roleInfo['masterUid']??0;
    configs['age'] = roleInfo['age'];
    configs['avatarUrl'] = roleInfo['avatarUrl'];

    // 设置 EncHelper 相关字段
    final encFields = [
      EncHelper.cr_tvid,
      EncHelper.cr_piurl,
      EncHelper.cr_cfg,
      EncHelper.cr_ownern,
      EncHelper.cr_imgpm,
      EncHelper.cr_synopsis,
      EncHelper.cr_bio,
      EncHelper.cr_alts,
    ];

    for (final field in encFields) {
      configs[field] = roleInfo[field];
    }
  }

  void _setDefaultValues() {
    configs['nickName'] = '';
    configs['gender'] = 2;
    configs['age'] = 18;
    configs['avatarUrl'] = '';
    configs['chatBackground'] = '';
    configs['masterUid'] = account.id;

    // 设置 EncHelper 默认值
    configs[EncHelper.cr_tvid] = '';
    configs[EncHelper.cr_piurl] = '';
    configs[EncHelper.cr_cfg] = {};
    configs[EncHelper.cr_ownern] = '';
    configs[EncHelper.cr_imgpm] = '';
    configs[EncHelper.cr_synopsis] = '';
    configs[EncHelper.cr_bio] = '';
    configs[EncHelper.cr_alts] = <Map<String, String>>[];
  }

  // 发送到服务器预保留
  Future<void> save() async {
    final rtn = OcManager.instance.ocOptions(configs, 3, generateImgs, traceId, null);
  }

  // 发送到服务器更新
  Future<Map?> update() async {
    return await OcManager.instance.ocOptions(configs, 1, generateImgs, traceId, null);
  }

  static Future<Map?> createDraft() async {
    return await OcManager.instance.ocOptions({}, 2, [], '', null);
  }

  // 发送到服务器创建
  Future<Map?> createRole() async {
    return await OcManager.instance.ocOptions(configs, 0, generateImgs, traceId, null);
  }

  // 生成角色背景图
  Future<bool> createForBgRegeneration() async {
    final rtn = await OcManager.instance.generateImageBg(configs, 0);
    if (rtn != null && rtn['statusInfo']['traceId'] != null) {
      traceId = rtn['statusInfo']['traceId'];
      return true;
    } else {
      return false;
    }
  }

  // 编辑时重新生成背景图
  Future<bool> editForBgRegeneration() async {
    final rtn = await OcManager.instance.generateImageBg(configs, 1);
    if (rtn != null && rtn['traceId'] != null) {
      traceId = rtn['traceId'];
      return true;
    } else {
      return false;
    }
  }

  // 轮询查看图片生成结果
  Future<Map?> queryImageResult() async {
    final rtn = await OcManager.instance.getGenResult(traceId);
    return rtn;
  }

  Future<void> downloadImage(Map rtn) async {
    final imageUrl = rtn['imageUrl'];
    // 缓存到本地
    final response = await http.get(Uri.parse(imageUrl));
    dir ??= await getTemporaryDirectory();
    final path = '${dir!.path}/temp_image_${DateTime.now().millisecondsSinceEpoch}.jpg';

    // url - 本地文件映射
    final tempFile = File(path);
    await tempFile.writeAsBytes(response.bodyBytes);

    // 裁剪
    if (rtn[EncHelper.cr_posinf] == null) {
      // 没有位置信息，不裁剪
      results.add(
        GenerationResult()
          ..url = imageUrl
          ..localPath = path
          ..cropPath = path,
      );
      return;
    }

    final croppedFilePath = await cropped(
      imageUrl,
      path,
      response.bodyBytes,
      Rect.fromLTWH(
        rtn[EncHelper.cr_posinf]['x'].toDouble(),
        rtn[EncHelper.cr_posinf]['y'].toDouble(),
        rtn[EncHelper.cr_posinf]['w'].toDouble(),
        rtn[EncHelper.cr_posinf]['h'].toDouble(),
      ),
    );
    results.add(
      GenerationResult()
        ..url = imageUrl
        ..localPath = path
        ..cropPath = croppedFilePath,
    );
  }

  // 清除缓存
  Future<void> cleanTemps() async {
    try {
      for (final result in results) {
        // 清理本地文件缓存
        if (result.localPath.isNotEmpty) {
          final localFile = File(result.localPath);
          if (await localFile.exists()) {
            await localFile.delete();
            result.localPath = ''; // 清空路径引用
          }
        }

        // 清理裁剪文件缓存
        if (result.cropPath.isNotEmpty) {
          final cropFile = File(result.cropPath);
          if (await cropFile.exists()) {
            await cropFile.delete();
            result.cropPath = ''; // 清空路径引用
          }
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // 裁剪。返回裁剪路径
  Future<String> cropped(String imageUrl, String path, Uint8List? bodyBytes, Rect defaultAvatar) async {
    var originImage;
    if (bodyBytes != null) {
      originImage = img.decodeImage(bodyBytes);
    } else {
      final bytes = await File(path).readAsBytes();
      originImage = img.decodeImage(bytes);
    }
    if (originImage != null) {
      final croppedImage = img.copyCrop(
        originImage,
        x: defaultAvatar.left.toInt(),
        y: defaultAvatar.top.toInt(),
        width: defaultAvatar.width.toInt(),
        height: defaultAvatar.height.toInt(),
      );
      final ext = path.split('.').last;
      final croppedFilePath = path.replaceAll('.$ext', '_cropped.$ext');

      await File(croppedFilePath).writeAsBytes(ext.toLowerCase() == 'png' ? img.encodePng(croppedImage) : img.encodeJpg(croppedImage));
      return croppedFilePath;
    }
    return '';
  }
}
