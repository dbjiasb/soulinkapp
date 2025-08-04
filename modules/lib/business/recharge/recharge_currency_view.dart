import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/util/es_helper.dart';
import 'package:modules/shared/app_theme.dart';

import '../purchase/payment_service.dart';

const assetsDir = 'packages/modules/assets/images';

class RechargeCurrencyView extends StatelessWidget {
  RechargeCurrencyView({super.key});

  final RechargeCurrencyViewController controller = Get.put(RechargeCurrencyViewController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondPage,
      appBar: AppBar(
        leading: InkWell(onTap: Get.back, child: Container(padding: EdgeInsets.all(16), child: Image.asset(ImagePath.back_icon, fit: BoxFit.fill))),
        centerTitle: true,
        backgroundColor: AppColors.secondPage,
        title: Text(controller.rcgType == 0 ? EncHelper.rcg_titlCois : EncHelper.rcg_titlGms, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: GetBuilder<RechargeCurrencyViewController>(builder: (controller) {
        return _rechargeCurrencyView();
      }),
    );
  }

  Widget _rechargeCurrencyView() {
    final rcgImage = controller.rcgType == 0 ? EncHelper.rcg_coiImg : EncHelper.rcg_gmImg;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            Container(
              height: 88,
              decoration: BoxDecoration(image: DecorationImage(image: AssetImage(EncHelper.rcg_geRcgBg(controller.rcgType)), fit: BoxFit.fill)),
              padding: EdgeInsets.symmetric(vertical: 17, horizontal: 24),
              child: Row(
                spacing: 12,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(rcgImage, height: 40, width: 40),
                  Obx(()=>Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        EncHelper.rcg_geRcgBalns(controller.rcgType),
                        style: TextStyle(color: Color(0xFF999999), fontSize: 12, fontWeight: AppFonts.medium),
                      ),
                      Text(
                        '${controller.rcgType == 0 ? MyAccount.coins : MyAccount.gems}',
                        style: TextStyle(color: Color(0xFF0A0B12), fontSize: 20, fontWeight: AppFonts.black),
                      ),
                    ],
                  )),
                ],
              ),
            ),

            SizedBox(height: 18),

            _buildProducts(rcgImage),

            GestureDetector(
              onTap: controller.startRecharge,
              child: Container(
                height: 48,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Obx(()=>Text('${controller.selectedPro[EncHelper.rcg_prc] ?? ''} ', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: AppFonts.black))),
                    Text(EncHelper.rcg_rcg, style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProducts(String rcgImage) {
    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 10, childAspectRatio: 108 / 128),
        itemCount: controller.curPros.length,
        itemBuilder: (context, index) {
          final product = controller.curPros[index];
          return GestureDetector(
            onTap: () {
              controller.selectedPro.value = product;
            },
            child: Obx(
              () => Container(
                padding: EdgeInsets.only(top: 24, bottom: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF221E32),
                  borderRadius: BorderRadius.circular(12),
                  border: controller.selectedPro == product ? Border.all(width: 2, color: AppColors.primary) : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset(rcgImage, height: 24, width: 24),
                    Text('${product[EncHelper.rcg_valu]}', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: AppFonts.black)),
                    Spacer(),
                    Text(controller.realPrice(product), style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class RechargeCurrencyViewController extends GetxController {
  Map<dynamic, dynamic> arguments = Get.arguments;
  late final rcgType; // 0 coins / 1 gems

  List get curPros => bizProducts[rcgType] ?? [];
  final selectedPro = {}.obs;

  Map<String, ProductDetails> iapProducts = {};
  String realPrice(Map bizPro) => iapProducts[bizPro[EncHelper.rcg_id] ?? '']?.price ?? bizPro[EncHelper.rcg_prc] ?? '';

  final Map<int, List> bizProducts = {
    0: EncHelper.rcg_coiProds,
    1: EncHelper.rcg_gmProds,
  };

  Future<void> getIapProducts() async {
    Set<String> ids = curPros.map((e) {
      return (e[EncHelper.rcg_id] ?? '').toString();
    }).toSet();
    List<ProductDetails> prds = await PurchaseManager.instance.getIapProducts(ids);
    for (var product in prds) {
      iapProducts[product.id] = product;
    }
    update();
  }

  void startRecharge() {
    if ((selectedPro[EncHelper.rcg_id] ?? '').isEmpty) {
      EasyLoading.showError(EncHelper.rcg_errSeleProd);
      return;
    }

    PurchaseManager.instance.startRecharge(selectedPro[EncHelper.rcg_id]);
  }

  @override
  void onInit() {
    super.onInit();
    rcgType = arguments[EncHelper.rcg_rcgTyp];
    selectedPro.value = curPros.first;

    initIap();
    AccountService.instance.refreshBalance();

    if (!(rcgType == 0 || rcgType == 1)) {
      EasyLoading.showError(EncHelper.rcg_errSrvic);
      Get.back();
    }
  }

  initIap() async {
    await PurchaseManager.instance.setup();
    getIapProducts();
    PurchaseManager.instance.rechargeEventCallback = (ok, err) {
      if (ok) {
        EasyLoading.showToast(EncHelper.rcg_prchasDon);
      }
    };
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class RechargeCurrencyBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RechargeCurrencyViewController>(() => RechargeCurrencyViewController());
  }
}
