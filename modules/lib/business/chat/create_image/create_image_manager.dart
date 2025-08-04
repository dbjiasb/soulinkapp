import 'package:modules/base/crypt/security.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_request.dart';
import 'package:modules/base/api_service/api_response.dart';
import 'package:modules/base/api_service/api_service.dart';
import 'package:modules/base/buffer_queue/buffer_queue.dart';

class PromptModel {
  final Map data;
  PromptModel(this.data);
  String get name => data[Security.security_typeDesc] ?? '';
  List get groups => data[Security.security_subGroups] ?? [];

  // 使用 late 修饰符实现懒加载
  late final List tags = _mergeTags();

  /// 计算标签列表的私有方法
  List _mergeTags() {
    return groups.fold<List>([], (previousValue, element) {
      // 获取 element 中的 Security.security_tags 字段
      final tags = element[Security.security_tags];
      // 检查 tags 是否为 Iterable<String> 类型
      if (tags is Iterable) {
        previousValue.addAll(tags);
      }
      return previousValue;
    });
  }

  Rx<Map<String, dynamic>?> selectedItem = Rx<Map<String, dynamic>?>(null);
}

class CreateImageConfig {
  final List<PromptModel> prompts;
  final int price;
  final int type;
  bool success = true;
  CreateImageConfig(this.prompts, this.price, this.type);

  CreateImageConfig.none() : prompts = [], price = 0, type = 0;
}

class CreateImageManager {
  static final CreateImageManager _instance = CreateImageManager._internal();
  CreateImageManager._internal();
  factory CreateImageManager() => _instance;
  static CreateImageManager get instance => _instance;

  BufferQueue cache = BufferQueue(10);

  Future<CreateImageConfig> getCreateImageConfigs(int userId) async {
    CreateImageConfig? config = cache.getObject(userId);
    if (config != null) {
      return config;
    }

    ApiRequest request = ApiRequest('queryPhotoPrompts', params: {Security.security_targetUid: userId.toString()});
    ApiResponse response = await ApiService.instance.sendRequest(request);
    if (response.isSuccess) {
      List<PromptModel> prompts = (response.data[Security.security_groups] as List).map((e) => PromptModel(e)).toList();
      CreateImageConfig config = CreateImageConfig(prompts, response.data[Security.security_cost] ?? 0, response.data[Security.security_costType] ?? 0);
      cache.setObject(userId, config);
      return config;
    } else {
      return CreateImageConfig([], 0, 0)..success = false;
    }
  }

  Future<ApiResponse> createImage(int userId, List options) async {
    ApiRequest request = ApiRequest('generateImage', params: {Security.security_tags: options, Security.security_targetUid: userId});
    ApiResponse response = await ApiService.instance.sendRequest(request);
    return response;
  }
}
