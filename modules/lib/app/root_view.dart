import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/router/router_names.dart';
import 'package:modules/base/webview/web_view.dart';
import 'package:modules/business/account/edit_my_info_view.dart';
import 'package:modules/business/account/settings.dart';
import 'package:modules/business/chat/chat_history/chat_history_view.dart';
import 'package:modules/business/chat/chat_room/chat_room_view.dart';
import 'package:modules/business/chat/voice_call/voice_call_view.dart';
import 'package:modules/business/create_center/advance_page.dart';
import 'package:modules/business/create_center/basic_page.dart';
import 'package:modules/business/create_center/gen_page.dart';
import 'package:modules/business/create_center/voice_page.dart';
import 'package:modules/business/home_page_lists/home_page.dart';
import 'package:modules/business/recharge/recharge_currency_view.dart';
import 'package:modules/business/recharge/recharge_premium_view.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/account/create_account.dart';
import 'package:modules/core/account/login_channel.dart';
import 'package:modules/shared/widget/image_viewer.dart';
import 'package:modules/shared/widget/video_player_view.dart';

import '../business/user_page/person_view.dart';
import './skeleton_view.dart';

class RootView extends StatelessWidget {
  const RootView({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Security.security_Lumina,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      builder: EasyLoading.init(),
      initialRoute: AccountService.instance.loggedIn ? Routers.root : Routers.loginChannel,
      getPages: [
        GetPage(name: Routers.login, page: () => CreateAccountView()),
        GetPage(name: Routers.root, page: () => SkeletonView()),
        GetPage(name: Routers.chat, page: () => ChatRoomView()),
        GetPage(name: Routers.home, page: () => HomePageView()),
        GetPage(name: Routers.call, page: () => VoiceCallView()),
        GetPage(name: Routers.webView, page: () => WebView()),
        GetPage(name: Routers.rechargeCurrency, page: () => RechargeCurrencyView()),
        GetPage(name: Routers.loginChannel, page: () => LoginChannelView()),
        GetPage(name: Routers.imageBrowser, page: () => ImageViewer()),
        GetPage(name: Routers.editMe, page: () => EditMyInfoPage()),
        GetPage(name: Routers.person, page: () => PersonViewPage()),
        GetPage(name: Routers.rechargePremium, page: () => RechargePremiumView()),
        GetPage(name: Routers.videoPlayer, page: () => VideoPlayerView()),
        GetPage(name: Routers.createBasic, page: () => BasicPage()),
        GetPage(name: Routers.createVoice, page: () => OCVoicePage()),
        GetPage(name: Routers.createAdvance, page: () => AdvancePage()),
        GetPage(name: Routers.createGen, page: () => GenPage()),
        GetPage(name: Routers.setting, page: () => AccountSettings()),
        GetPage(name: Routers.chatHistory, page: () => ChatHistoryView()),
      ],
    );
  }
}
