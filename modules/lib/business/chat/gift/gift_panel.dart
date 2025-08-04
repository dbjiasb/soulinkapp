import 'package:modules/base/crypt/security.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_response.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/shared/widget/balance_view.dart';
import 'package:modules/shared/widget/list_status_view.dart';

import 'gift_manager.dart';

class GiftItem {
  final Map<String, dynamic> info;
  GiftItem(this.info);

  String get giftUrl => info[Security.security_giftIcon] ?? '';
  String get giftName => info[Security.security_giftName] ?? '';
  int get currency => info[Security.security_currencyType] ?? 0;
  String get currencyIcon => 'packages/modules/assets/images/${currency == 1 ? 'gem' : 'coin'}.png';
  int get price => info[Security.security_price] ?? 0;
  int get giftId => info[Security.security_giftId] ?? 0;
}

class GiftPanel extends StatelessWidget {
  final int recipient;
  GiftPanel({super.key, required this.recipient});

  GiftPanelViewController get viewController => Get.put(GiftPanelViewController(recipient));

  Widget buildItem(GiftItem item) {
    bool isSelected = viewController.selectedItem.value?.giftId == item.giftId;
    return GestureDetector(
      onTap: () {
        viewController.selectedItem.value = item;
      },
      child: Container(
        width: 84,
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0x29F16CFE) : Color(0x26000000),
                border: isSelected ? Border.all(color: const Color(0xFFE962F6), width: 2) : null,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SizedBox.fromSize(size: const Size(40, 40), child: CachedNetworkImage(fit: BoxFit.cover, imageUrl: item.giftUrl)),
            ),
            Container(
              height: 16,
              alignment: Alignment.center,
              child: Text(
                item.giftName,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              height: 16,
              alignment: Alignment.center,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(item.currencyIcon, width: 12, height: 12),
                  const SizedBox(width: 2),
                  Text(item.price.toString(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        color: Color(0xB3150C09),
        child: SafeArea(
          bottom: true,
          child: Container(
            height: 232,
            padding: EdgeInsets.only(left: 16, right: 16, top: 4),
            child: Obx(
              () => Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: MasonryGridView.count(
                          crossAxisCount: 4,
                          itemCount: viewController.items.length,
                          itemBuilder: (context, index) {
                            return Obx(() => buildItem(viewController.items[index]));
                          },
                        ),
                      ),

                      SizedBox(
                        height: 44,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [BalanceView(type: BalanceType.coin), SizedBox(width: 16), BalanceView(type: BalanceType.gem)],
                            ),
                            GestureDetector(
                              onTap: () {
                                viewController.sendGift();
                              },

                              child: Container(
                                height: 28,
                                padding: EdgeInsets.symmetric(horizontal: 18),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(color: Color(0xFFE962F6), borderRadius: BorderRadius.all(Radius.circular(14))),
                                child: Text(Security.security_Send, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  ListStatusView(status: viewController.listStatus.value),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GiftPanelViewController extends GetxController {
  int recipient;
  var listStatus = ListStatus.idle.obs;
  var items = [].obs;
  Rx<GiftItem?> selectedItem = Rx<GiftItem?>(null);

  GiftPanelViewController(this.recipient);

  int get balance => selectedItem.value?.currency == 1 ? MyAccount.gems : MyAccount.coins;

  @override
  void onInit() {
    super.onInit();
    queryGifts();
  }

  Future<void> queryGifts() async {
    if (items.isEmpty && listStatus.value != ListStatus.loading) {
      listStatus.value = ListStatus.loading;
    }
    ApiResponse response = await GiftManager.instance.queryGifts(recipient);
    if (response.isSuccess) {
      items.value = response.data[Security.security_panels][0][Security.security_gifts].map<GiftItem>((item) => GiftItem(item)).toList();
      listStatus.value = items.isEmpty ? ListStatus.empty : ListStatus.success;
      if (items.isNotEmpty) {
        selectedItem.value = items[0];
      }
    } else {
      listStatus.value = ListStatus.error;
    }
  }

  void sendGift() async {
    if (selectedItem.value == null) return;
    SendGiftData sendParam = SendGiftData();
    sendParam.giftId = selectedItem.value!.giftId;
    sendParam.recipient = recipient;
    sendParam.giftCount = 1;
    sendParam.currencyType = selectedItem.value!.currency;
    sendParam.balance = balance;

    EasyLoading.show(status: 'Sending...');
    SendGiftResponse response = await GiftManager.instance.sendGift(sendParam);
    if (response.isSuccess) {
      EasyLoading.dismiss();
      AccountService.instance.refreshBalance();
    } else {
      EasyLoading.showError(response.errorMsg);
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
