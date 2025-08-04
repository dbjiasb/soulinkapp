import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

showAppBottomSheet(Widget widget) {
  Get.bottomSheet(
    BackdropFilter(filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4), child: widget),
    ignoreSafeArea: false,
    isDismissible: true,
  );
}
