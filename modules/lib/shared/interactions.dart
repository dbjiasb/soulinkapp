import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Interactions{
  // 复制文本到剪贴板
  static Future<void> copyToClipboard(String cpyText) async {
    await Clipboard.setData(ClipboardData(text: cpyText));
    EasyLoading.showToast('Copied to clipboard: $cpyText');
  }
}