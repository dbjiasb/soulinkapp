import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:modules/base/crypt/security.dart';

showConfirmAlert(String title, String content, {String? confirmText, String? cancelText, VoidCallback? onConfirm, VoidCallback? onCancel}) {
  showAlert(
    Padding(
      padding: EdgeInsets.only(left: 24, top: 24, right: 24, bottom: 20),
      child: Text(title, style: TextStyle(color: Color(0xFF070512), fontSize: 16, fontWeight: FontWeight.bold)),
    ),
    Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 0, bottom: 24),
      child: Text(content, style: TextStyle(fontSize: 13, color: Color(0xFFABABAD), fontWeight: FontWeight.w500)),
    ),
    confirmText: confirmText,
    cancelText: cancelText,
    onConfirm: onConfirm,
    onCancel: onCancel,
  );
}

showAlert(Widget? title, Widget? content, {String? confirmText, String? cancelText, VoidCallback? onConfirm, VoidCallback? onCancel}) {
  var alert = Container(
    width: 308,
    constraints: BoxConstraints(maxHeight: 500),
    child: Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.all(Radius.circular(12))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(mainAxisSize: MainAxisSize.min, children: [if (title != null) title, if (content != null) content]),
            Column(
              children: [
                // Divider(height: 0.5, color: Color(0xFFFAFAFA)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        onCancel?.call();
                      },
                      child: Container(
                        width: 134,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Color(0xFFEEEEEE), borderRadius: BorderRadius.all(Radius.circular(12))),
                        child: Text(
                          cancelText ?? Security.security_Cancel,
                          style: TextStyle(color: Color(0xFF666666), fontWeight: FontWeight.w600, fontSize: 16),
                        ),
                      ),
                    ),
                    // Container(width: 2, height: 20, color: Color(0xFFFAFAFA)),
                    SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Get.back();
                        onConfirm?.call();
                      },
                      child: Container(
                        width: 134,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Color(0xFF8761F1), borderRadius: BorderRadius.all(Radius.circular(12))),
                        child: Text(confirmText ?? Security.security_Confirm, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  showCustomAlert(alert);
}

showCustomAlert(Widget widget) {
  Get.dialog(
    BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: Align(alignment: Alignment.center, child: widget)),
    barrierDismissible: false,
  );
}
