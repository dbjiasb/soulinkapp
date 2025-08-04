import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:modules/base/crypt/constants.dart';

import '../crypt/crypt.dart';

class ApiResponse {
  final Map<String, dynamic> response;
  ApiResponse({required this.response});

  late final String description;
  late final int statusCode;
  late final String trunk;
  Map data = {};

  int get bsnsCode => data[Constants.statusData]?['code'] ?? -1;

  bool get isSuccess => statusCode == 200 && bsnsCode == 0;

  static withResponse(Map<String, dynamic> response) {
    ApiResponse apiResponse =
        ApiResponse(response: response)
          ..statusCode = int.tryParse(response['code']) ?? 0
          ..trunk = response['body'] ?? {};
    try {
      final string = Decryptor.decrypt(apiResponse.trunk);
      JsonDecoder decoder = const JsonDecoder();

      apiResponse.data = decoder.convert(string);
      apiResponse.description = apiResponse.data[Constants.statusData]?['msg'] ?? '';
    } catch (e) {
      apiResponse.description = 'Network error, please try again later';
      debugPrint('ApiResponse withData error: $e');
    }
    return apiResponse;
  }

  static withError(Map<String, dynamic> error) {
    return ApiResponse(response: error)
      ..statusCode = error['code'] ?? 0
      ..description = error['description'] ?? {};
  }

  dynamic valueForKey(String key) {
    return data[key];
  }

  @override
  String toString() {
    return 'ApiResponse{content: $data, describe: $description, statusCode: $statusCode}';
  }
}
