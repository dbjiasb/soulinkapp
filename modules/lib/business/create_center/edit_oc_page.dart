import 'package:modules/base/crypt/copywriting.dart';
import 'package:modules/base/crypt/security.dart';
// import 'package:app_biz/common/app_theme.dart';
// import 'package:app_biz/services/route_service.dart';
// import 'package:audioplayers/audioplayers.dart';
// import 'package:creator_center/advance_info/view.dart';
// import 'package:creator_center/basic_info/view.dart';
// import 'package:creator_center/dependency/create_or_modify_logic.dart';
// import 'package:creator_center/dependency/custom_role_config.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image_picker/image_picker.dart';
//
// class EditAiPage extends StatefulWidget {
//   final Map editInfo;
//
//   const EditAiPage({
//     super.key,
//     required this.editInfo,
//   });
//
//   @override
//   State<EditAiPage> createState() => _EditAiPageState();
// }
//
// class _EditAiPageState extends State<EditAiPage> with SingleTickerProviderStateMixin {
//   final picker = ImagePicker();
//   final audioPlayer = AudioPlayer();
//   late TabController _tabController;
//   late final CreateOrModifyLogic _logic;
//   CustomRoleConfig? config;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//     config = Get.put<CustomRoleConfig>(CustomRoleConfig(widget.editInfo));
//     _logic = Get.put<CreateOrModifyLogic>(CreateOrModifyLogic());
//     _logic.isEditPage = true;
//     _logic.preloadBg();
//   }
//
//   @override
//   void dispose() {
//     config?.cleanTempImageFiles();
//     Get.delete<CreateOrModifyLogic>();
//     Get.delete<CustomRoleConfig>();
//     _tabController.dispose();
//     audioPlayer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     Get.put<CustomRoleConfig>(CustomRoleConfig(widget.editInfo));
//     return DefaultTabController(
//         length: 2,
//         child: Scaffold(
//             body: SafeArea(
//                 top: false,
//                 child: Container(
//                   color: const Color(0xFFF3F3F3),
//                   child: Column(
//                     spacing: 16,
//                     children: [
//                       _buildTitleLine(context),
//                       TabBar(tabAlignment: TabAlignment.center, dividerHeight: 0, indicatorColor: AppColors.main, controller: _tabController, tabs: [
//                         Container(
//                           child: const Text(
//                             'Basic',
//                             style: TextStyle(color: Color(0xFF191A17), fontSize: 15, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                         Container(
//                           child: const Text(
//                             'Advance',
//                             style: TextStyle(color: Color(0xFF191A17), fontSize: 15, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                       ]),
//                       Expanded(
//                           child: TabBarView(
//                               controller: _tabController,
//                               children: const [BasicInfoPage(needTitleRow: false, needNextBtn: false), AdvanceInfoPage(needTitleRow: false,needGenBtn: false,)])),
//                       _buildUpdateButton()
//                     ],
//                   ),
//                 ))));
//   }
//
//   Widget _buildTitleLine(BuildContext context) {
//     return Container(
//       height: 140,
//       decoration: const BoxDecoration(
//           gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFC2F36F), Color(0xFFf3f3f3)])),
//       child: Padding(
//         padding: const EdgeInsets.only(left: 16, right: 16, top: 64),
//         child: Row(
//           children: [
//             IconButton(
//                 onPressed: () {
//                   RouteService.pop();
//                 },
//                 icon: Image.asset('assets/images/basic_info_back.webp', package: 'creator_center', height: 24, width: 24)),
//             const Expanded(
//                 child: Text(
//               textAlign: TextAlign.center,
//               'Edit My Character',
//               style: TextStyle(fontSize: 20, fontFamily: Copywriting.security_sF_Pro_bold, fontWeight: FontWeight.w700),
//             )),
//             AnimatedBuilder(
//               animation: _tabController,
//               builder: (context, child) {
//                 return Text(
//                   '${_tabController.index + 1}',
//                   style: const TextStyle(
//                     color: Color(0xFFFF590F),
//                     fontWeight: FontWeight.w700,
//                     fontSize: 14,
//                     fontFamily: Copywriting.security_sF_Pro_bold,
//                   ),
//                 );
//               },
//             ),
//             const Text('/2',
//                 style: TextStyle(
//                   color: Color(0xFF12151C),
//                   fontWeight: FontWeight.w700,
//                   fontSize: 9,
//                   fontFamily: Copywriting.security_sF_Pro_bold,
//                 ))
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildUpdateButton() {
//     return GestureDetector(
//       onTap: () {
//         _logic.toGeneratePage(context);
//       },
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         child: Container(
//           height: 48,
//           width: 343,
//           alignment: Alignment.center,
//           decoration: const BoxDecoration(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(12),
//               ),
//               color: Colors.black),
//           child: const Text(
//             Security.security_Next,
//             style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
//           ),
//         ),
//       ),
//     );
//   }
// }
