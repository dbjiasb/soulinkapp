import 'dart:io';

import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:modules/base/api_service/api_request.dart';
import 'package:modules/base/api_service/api_service.dart';
import 'package:modules/base/assets/image_path.dart';
import 'package:modules/business/purchase/payment_service.dart';
import 'package:modules/core/account/account_service.dart';
import 'package:modules/core/util/calendar_helper.dart';
import 'package:modules/core/util/es_helper.dart';

import '../../base/router/router_names.dart';

class RechargePremiumView extends StatelessWidget {
  const RechargePremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RechargePremiumViewController>(
      init: RechargePremiumViewController(),
      builder: (controller) {
        return Scaffold(
          body: Stack(
            children: [
              _buildBackground(),
              _buildBackButton(controller),
              _buildContent(controller),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBackground() {
    return Image.asset(
      ImagePath.rcg_premium_bg,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildBackButton(RechargePremiumViewController controller) {
    return SafeArea(
      child: GestureDetector(
        onTap: controller.navigateBack,
        child: Padding(
          padding: EdgeInsets.only(left: 18, top: 10),
          child: Image.asset(ImagePath.back, height: 24, width: 24),
        ),
      ),
    );
  }

  Widget _buildContent(RechargePremiumViewController controller) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingIndicator();
          } else if (controller.isError.value) {
            return _buildErrorView();
          } else {
            return controller.isSubscribed
                ? _buildSubscribedView(controller)
                : _buildSubscriptionPlans(controller);
          }
        }),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: SizedBox(
        width: 100,
        height: 100,
        child: CircularProgressIndicator(
          strokeWidth: 6,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Text(
        EncHelper.rcg_errLoData,
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildSubscribedView(RechargePremiumViewController controller) {
    return Column(
      children: [
        const Spacer(),
        _buildSuccessHeader(),
        const SizedBox(height: 32),
        _buildUserSubscriptionCard(controller),
        const SizedBox(height: 82),
      ],
    );
  }

  Widget _buildSuccessHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return LinearGradient(
              colors: [Color(0xFFF4BEDA), Color(0xFFBA7BF7), Color(0xFF6F71F6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ).createShader(bounds);
          },
          child: Text(
            EncHelper.rcg_fuAces,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserSubscriptionCard(RechargePremiumViewController controller) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFFF95D9).withValues(alpha: 0.15),
            Color(0xFFA17BFF).withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          width: 1,
          color: Color(0xFFFCC0FF).withValues(alpha: 0.30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildUserProfileSection(controller),
            const SizedBox(height: 12),
            ..._buildActiveFeatures(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfileSection(RechargePremiumViewController controller) {
    return Row(
      children: [
        SizedBox(
          height: 76,
          width: 76,
          child: Stack(
            children: [
              Image.asset(ImagePath.premium_avatar_bg, fit: BoxFit.cover),
              Padding(
                padding: const EdgeInsets.all(6),
                child:
                    controller.userAvatar.isEmpty
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: CachedNetworkImage(
                            imageUrl: controller.userAvatar,
                            height: 64,
                            width: 64,
                            fit: BoxFit.cover,
                          ),
                        ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  controller.username,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              spacing: 4,
              children: [
                Text(
                  EncHelper.rcg_expOn,
                  style: TextStyle(
                    color: Color(0xFFAD9BAF),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  CalendarHelper.formatDate(date: controller.myPEdTm) ??
                      EncHelper.rcg_err,
                  style: const TextStyle(
                    color: Color(0xFFE962F6),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildActiveFeatures(RechargePremiumViewController controller) {
    for (var plans in controller.allPlans) {
      if (plans[EncHelper.rcg_rcgItm][EncHelper.rcg_ppt] ==
          controller.myPCard) {
        return (plans[EncHelper.rcg_bdesc] as List<dynamic>)
            .map<Widget>((benefit) => _buildFeatureItem(benefit.toString()))
            .toList();
      }
    }
    return [];
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(ImagePath.premium_benefit_head, height: 16, width: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              feature,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionPlans(RechargePremiumViewController controller) {
    return Column(
      spacing: 12,
      children: [
        const Spacer(),
        _buildFeatureList(controller),
        ..._buildPlanOptions(controller),
        ..._buildFooter(controller),
      ],
    );
  }

  Widget _buildFeatureList(RechargePremiumViewController controller) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Obx(
        () => Column(
          children:
              controller.selectedPlanFeatures
                  .map((e) => _buildFeatureItem(e))
                  .toList(),
        ),
      ),
    );
  }

  List<Widget> _buildPlanOptions(RechargePremiumViewController controller) {
    return [
      ...controller.allPlans.map((plan) => _buildPlanOption(plan, controller)),
    ];
  }

  double calculateDailyPay(dynamic cardType, dynamic price) {
    try {
      var days = 1.0;
      switch (cardType) {
        case 1:
          days = 7.0;
          break;
        case 2:
          days = 31.0;
          break;
        case 4:
          days = 365.0;
          break;
        default:
          break;
      }
      double result = price / days;
      return double.parse(result.toStringAsFixed(2));
    } catch (e) {
      return 0.00;
    }
  }

  double calculateSave(dynamic originValue, dynamic price) {
    try {
      double original =
          originValue is String
              ? double.parse(originValue)
              : originValue.toDouble();
      double current = price is String ? double.parse(price) : price.toDouble();

      double savings = (original - current) / original;

      return double.parse(savings.toStringAsFixed(2));
    } catch (e) {
      return 0.00;
    }
  }

  // 没用
  double parseToDouble(dynamic value) {
    if (value == null) {
      return 0.00;
    }
    if (value is int) {
      return value.toDouble();
    } else if (value is double) {
      return value;
    } else if (value is String) {
      return double.parse(value);
    }
    return 0.00;
  }

  Widget _buildPlanOption(
    Map<dynamic, dynamic> plan,
    RechargePremiumViewController controller,
  ) {
    final isSelected = controller.selectedPlan == plan;
    // rcgItem
    final prodInfo = plan[EncHelper.rcg_rcgItm];

    // 名字
    final prodName = prodInfo[EncHelper.rcg_nm];

    // 优惠卡
    final cdType = prodInfo?[EncHelper.rcg_ppt] ?? 1;

    // 价格换算
    var chnlInfo = null;
    if (Platform.isIOS) {
      chnlInfo = prodInfo[EncHelper.rcg_chnlInfo]?[EncHelper.rcg_iosChnnl];
    } else if (Platform.isAndroid) {
      chnlInfo = prodInfo[EncHelper.rcg_chnlInfo]?[EncHelper.rcg_adrCnnl];
    }
    // // 不支持安卓和ios以外的平台
    // if(chnlInfo == null)return Container();

    // iap id => iap product
    final prodId = chnlInfo?[EncHelper.rcg_inapId] ?? '';
    final iapProdDetail = controller.realPrems[prodId];

    // 换算结果，包括单位
    final prodPrc =
        iapProdDetail?.rawPrice ?? prodInfo[EncHelper.rcg_prc] / 100.0;
    String prodCurncyType = iapProdDetail?.currencySymbol ?? '\$';
    final originValue = parseToDouble(prodInfo[EncHelper.rcg_ov]); // 没用
    final currentValue = parseToDouble(prodInfo[EncHelper.rcg_prc]); // 没用

    final dailyPay = calculateDailyPay(cdType, prodPrc);
    final savings = calculateSave(originValue, currentValue); // 没用
    final dscnt = prodInfo[EncHelper.rcg_dsct];

    return GestureDetector(
      onTap: () => controller.selectPlan(plan),
      child: SizedBox(
        height: 68,
        child: Stack(
          children: [
            if (isSelected)
              ShaderMask(
                shaderCallback: (Rect bounds) {
                  return LinearGradient(
                    colors: [
                      Color(0xFFF4BEDA),
                      Color(0xFFBA7BF7),
                      Color(0xFF6F71F6),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ).createShader(bounds);
                },
                child: Container(
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            Center(
              child: Container(
                margin: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1A2E),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  prodName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  EncHelper.rcg_dailyPrc(dailyPay),
                                  style: TextStyle(
                                    color: const Color(0x99FFFFFF),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                isSelected
                                    ? ShaderMask(
                                      shaderCallback: (Rect bounds) {
                                        return LinearGradient(
                                          colors: [
                                            Color(0xFFF4BEDA),
                                            Color(0xFFBA7BF7),
                                            Color(0xFF6F71F6),
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ).createShader(bounds);
                                      },
                                      child: Text(
                                        '$prodCurncyType ${currentValue / 100}',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              isSelected
                                                  ? Colors.white
                                                  : const Color(0xFF999999),
                                        ),
                                      ),
                                    )
                                    : Text(
                                      '\$${currentValue / 100}',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : const Color(0xFF999999),
                                      ),
                                    ),
                                // if (currentValue < originValue)
                                //   Text(
                                //     '\$${originValue / 100}',
                                //     style: const TextStyle(
                                //       color: Color(0x99FFFFFF),
                                //       fontSize: 8,
                                //       fontWeight: FontWeight.w500,
                                //       decoration: TextDecoration.lineThrough,
                                //       decorationColor: Color(0xFFAD9BAF),
                                //       decorationThickness: 2.0,
                                //     ),
                                //   ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isSelected && dscnt != null && dscnt > 0)
                      Positioned(
                        right: 16,
                        top: -8,
                        child: Container(
                          height: 20,
                          width: 87,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFF6C2D8),
                                Color(0xFFDB80F9),
                                Color(0xFFC07CF7),
                                Color(0xFF6F71F6),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              EncHelper.rcg_savPct((dscnt * 100).toInt()),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFooter(RechargePremiumViewController controller) {
    return [
      Text(
        EncHelper.rcg_trmNotic,
        style: TextStyle(
          color: Color(0x66FFFFFF),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.left,
      ),
      _buildSubscribeButton(controller),
      _buildLegalLinks(),
    ];
  }

  Widget _buildSubscribeButton(RechargePremiumViewController controller) {
    return GestureDetector(
      onTap: () {
        controller.processSubscription();
      },
      child: Container(
        width: double.infinity,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF6C2D8),
              Color(0xFFDB80F9),
              Color(0xFFC07CF7),
              Color(0xFF6F71F6),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          EncHelper.rcg_btnSubs,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildLegalLinks() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () => launchUrl(EncHelper.rcg_urlTrms),
          child: Text(
            EncHelper.rcg_trms,
            style: TextStyle(
              color: Color(0xFFD5D4D3),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 12),
        TextButton(
          onPressed: () => launchUrl(EncHelper.rcg_urlPrivacy),
          child: Text(
            EncHelper.rcg_privacy,
            style: TextStyle(
              color: Color(0xFFD5D4D3),
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  void launchUrl(String url) {
    if (url == EncHelper.rcg_urlPrivacy) {
      Get.toNamed(
        Routers.webView.name,
        arguments: {
          EncHelper.rcg_titl: EncHelper.rcg_privacy,
          EncHelper.rcg_url: url,
        },
      );
    } else if (url == EncHelper.rcg_urlTrms) {
      Get.toNamed(
        Routers.webView.name,
        arguments: {
          EncHelper.rcg_titl: EncHelper.rcg_trms,
          EncHelper.rcg_url: url,
        },
      );
    }
  }
}

class RechargePremiumViewController extends GetxController {
  // 已开通会员权益
  int get myPCard => MyAccount.premCdType; // 会员类别
  int get myPEdTm => MyAccount.premEdTm; // 到期时间
  int get myPState => MyAccount.premStatus; // 会员状态
  List get myPBnfs => MyAccount.premBenfs; // 会员权益

  bool get isSubscribed => myPState == 1;

  String get username => MyAccount.name;

  String get userAvatar => MyAccount.avatar;

  final isLoading = true.obs;
  final isError = false.obs;

  // 未开通时的数据
  final selectedPlan = <dynamic, dynamic>{}.obs;
  final allPlans = [].obs;
  final premsCfg = [
    {EncHelper.rcg_id: EncHelper.rcg_iapWekly, EncHelper.rcg_prc: 799},
    {EncHelper.rcg_id: EncHelper.rcg_iapMthly, EncHelper.rcg_prc: 2799},
    {EncHelper.rcg_id: EncHelper.rcg_iapYrly, EncHelper.rcg_prc: 22999},
  ];
  final realPrems = <String, ProductDetails>{};

  List get selectedPlanFeatures {
    for (var plan in allPlans) {
      if (plan == selectedPlan.value) {
        return plan[EncHelper.rcg_bdesc];
      }
    }
    return [];
  }

  @override
  void onInit() {
    super.onInit();
    // 获取后端返回的会员数据
    loadSubscriptionData();
    // 通过iap获取换算后的数据
    initIap();
  }

  void initIap() async {
    await PurchaseManager.instance.setup();

    Set<String> ids =
        premsCfg.map((e) {
          return (e[EncHelper.rcg_id] ?? '').toString();
        }).toSet();

    List<ProductDetails> prds = await PurchaseManager.instance.getIapProducts(
      ids,
    );
    for (var product in prds) {
      realPrems[product.id] = product;
    }

    PurchaseManager.instance.rechargeEventCallback = (bool ok, String? msg) {
      if (ok) {
        AccountService.instance.getMyPremInfo();
      } else {
        EasyLoading.showToast(msg ?? EncHelper.rcg_errRcg);
      }
    };
  }

  Future<void> loadSubscriptionData() async {
    try {
      isLoading.value = true;
      await fetchSubscriptionPlans();
      isLoading.value = false;
    } catch (e) {
      isError.value = true;
      isLoading.value = false;
    }
  }

  Future fetchSubscriptionPlans() async {
    final req = ApiRequest(EncHelper.rcg_apiGPV2, params: {});
    final rsp = await ApiService.instance.sendRequest(req);
    if (rsp.isSuccess) {
      allPlans.value = rsp.data[EncHelper.rcg_cfg];
      if (allPlans.isNotEmpty) selectedPlan.value = allPlans.first;
      allPlans.refresh();
    }
  }

  void selectPlan(Map plan) {
    selectedPlan.value = plan;
  }

  void navigateBack() {
    Get.back();
  }

  Future<void> processSubscription() async {
    try {
      final rcgItm = selectedPlan[EncHelper.rcg_rcgItm];
      var chnlInfo;
      if (Platform.isIOS) {
        chnlInfo = rcgItm[EncHelper.rcg_chnlInfo][EncHelper.rcg_iosChnnl];
      } else if (Platform.isAndroid) {
        chnlInfo = rcgItm[EncHelper.rcg_chnlInfo][EncHelper.rcg_adrCnnl];
      }
      if (chnlInfo == null ||
          chnlInfo[EncHelper.rcg_inapId] == null ||
          chnlInfo[EncHelper.rcg_inapId].isEmpty) {
        EasyLoading.showToast(EncHelper.rcg_errPlafm);
        return;
      }
      String pid = chnlInfo[EncHelper.rcg_inapId];
      PurchaseManager.instance.startRecharge(pid);
    } catch (e) {
      EasyLoading.showToast(EncHelper.rcg_errSubs);
    }
  }
}
