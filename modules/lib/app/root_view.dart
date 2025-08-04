import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
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
      title: 'Lumina',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      builder: EasyLoading.init(),
      initialRoute: AccountService.instance.loggedIn ? Routers.root.name : Routers.loginChannel.name,
      getPages: [
        GetPage(name: Routers.login.name, page: () => CreateAccountView()),
        GetPage(name: Routers.root.name, page: () => SkeletonView()),
        GetPage(name: Routers.chat.name, page: () => ChatRoomView()),
        GetPage(name: Routers.home.name, page: () => HomePageView()),
        GetPage(name: Routers.call.name, page: () => VoiceCallView()),
        GetPage(name: Routers.webView.name, page: () => WebView()),
        GetPage(name: Routers.rechargeCurrency.name, page: () => RechargeCurrencyView()),
        GetPage(name: Routers.loginChannel.name, page: () => LoginChannelView()),
        GetPage(name: Routers.imageBrowser.name, page: () => ImageViewer()),
        GetPage(name: Routers.editMe.name, page: () => EditMyInfoPage()),
        GetPage(name: Routers.person.name, page: () => PersonViewPage()),
        GetPage(name: Routers.rechargePremium.name, page:() => RechargePremiumView()),
        GetPage(name: Routers.editMe.name, page: ()=>EditMyInfoPage()),
        GetPage(name: Routers.person.name, page: ()=>PersonViewPage()),
        GetPage(name: Routers.videoPlayer.name, page: () => VideoPlayerView()),
        GetPage(name: Routers.createBasic.name, page: () => BasicPage()),
        GetPage(name: Routers.createVoice.name, page: () => OCVoicePage()),
        GetPage(name: Routers.createAdvance.name, page: () => AdvancePage()),
        GetPage(name: Routers.createGen.name, page: () => GenPage()),
        GetPage(name: Routers.setting.name, page: () => AccountSettings()),
        GetPage(name: Routers.chatHistory.name, page: () => ChatHistoryView()),
      ],
    );
  }
}
