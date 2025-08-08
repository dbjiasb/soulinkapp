import 'package:flutter/material.dart';
import 'package:modules/app/root_view.dart';
import 'package:modules/base/advertisement/ad_manager.dart';
import 'package:modules/base/app_info/app_manager.dart';
import 'package:modules/base/database/data_center.dart';
import 'package:modules/base/environment/environment.dart';
import 'package:modules/base/event_center/event_center.dart';
import 'package:modules/base/file_manager/file_manager.dart';
import 'package:modules/base/preferences/preferences.dart';
import 'package:modules/base/push_service/push_service.dart';
import 'package:modules/business/chat/chat_manager.dart';
import 'package:modules/business/purchase/premium_service.dart';

// import 'package:modules/business/purchase/payment_service.dart';
import 'package:modules/core/account/account_service.dart';

void startApp(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  Environment.init(args);
  await AppManager.instance.init();
  await FileManager.instance.init();
  await Preferences.instance.init();
  await DataCenter.instance.init();
  AdManager.instance.init();
  EventCenter.instance.init();
  PushService.instance.init();
  AccountService.instance.init();
  // PremiumManager.instance.init();
  ChatManager.instance.init();
  runApp(const RootView());
}
