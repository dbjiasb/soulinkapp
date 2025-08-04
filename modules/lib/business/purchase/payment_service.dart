import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:modules/base/crypt/security.dart';
import 'package:modules/base/preferences/preferences.dart';

import '../../base/api_service/api_service_export.dart';
import '../../core/account/account_service.dart';

String kCachedExceptionOrderKey = Security.security_kCachedExceptionOrderKey;

class PurchaseManager {
  static final PurchaseManager instance = PurchaseManager._internal();
  factory PurchaseManager() => instance;
  PurchaseManager._internal();

  Function(bool, String?)? rechargeEventCallback;
  List<ProductDetails> _products = [];
  bool _initialized = false;

  Map<String, Map<String, String>> cachedReceipts = {};

  InAppPurchase get iap => InAppPurchase.instance;

  Future<void> setup() async {
    if (_initialized) return;
    _initialized = true;

    if (!(await iap.isAvailable())) {
      EasyLoading.showToast('Current device not support, try restart app.');
      return;
    }

    fixedExceptionOrdersIfNeeded();

    InAppPurchase.instance.purchaseStream.listen((List<PurchaseDetails> purchases) {
      for (var purchase in purchases) {
        onPurchaseEventCallback(purchase);
      }
    });
  }

  void fixedExceptionOrdersIfNeeded() async {
    await Future.delayed(const Duration(seconds: 5));

    var exceptionOrders = Preferences.instance.getMap(kCachedExceptionOrderKey);
    if (exceptionOrders.isNotEmpty) {
      for (var key in exceptionOrders.keys) {
        var pair = exceptionOrders[key];
        var productId = pair[Security.security_pid];
        var receipt = pair[Security.security_receipt];
        checkPurchasedToken(productId, receipt, key);
      }
    }
  }

  Future<List<ProductDetails>> getIapProducts(Set<String> ids) async {
    // final Set<String> ids = productConfig.keys.toSet();
    debugPrint("Recharge >> getIapProducts, ids: $ids");

    try {
      final ProductDetailsResponse response = await iap.queryProductDetails(ids);
      if (response.notFoundIDs.isNotEmpty) {
        debugPrint("Recharge >> getIapProducts not found ids: ${response.notFoundIDs}");
      }
      _products = response.productDetails;
      debugPrint("Recharge >> getIapProducts  ${_products.length}");
    } catch (e) {
      debugPrint("Recharge >> getIapProducts $e");
    }
    return _products;
  }

  Future<bool> checkPurchase(PurchaseDetails purchase) async {
    return await checkPurchasedToken(purchase.productID, purchase.verificationData.serverVerificationData, purchase.purchaseID ?? '');
  }

  Future<bool> checkPurchasedToken(String pid, String receipt, String cacheKey) async {
    final req = ApiRequest(
      'fullConfirmPurchase',
      params: {
        Security.security_receipt: receipt,
        Security.security_id: pid,
        Security.security_store: "1",
        Security.security_order: '${MyAccount.id}_${DateTime.now().millisecondsSinceEpoch}',
        Security.security_channel: Platform.isIOS ? 2 : 1,
      },
    );

    var rsp = await ApiService.instance.sendRequest(req);

    if (rsp.statusCode == 200 && (rsp.bsnsCode == 0 || rsp.bsnsCode == 2010)) {
      AccountService.instance.refreshBalance();
      EasyLoading.showToast('Purchased Success');
      if (cachedReceipts.containsKey(cacheKey)) {
        cachedReceipts.remove(cacheKey);
        Preferences.instance.setMap(kCachedExceptionOrderKey, cachedReceipts);
      }
      return true;
    }

    return false;
  }

  Future<void> onPurchaseEventCallback(PurchaseDetails purchase) async {
    debugPrint("Recharge >> purchase callback: ${purchase.productID} pid ${purchase.purchaseID} status: ${purchase.status} error: ${purchase.error}");

    switch (purchase.status) {
      case PurchaseStatus.purchased:
      case PurchaseStatus.restored:
        Preferences.instance.setMap(kCachedExceptionOrderKey, {
          Security.security_pid: purchase.productID,
          Security.security_receipt: purchase.verificationData.serverVerificationData,
        });
        var isSuc = await checkPurchase(purchase);
        rechargeEventCallback?.call(isSuc, purchase.productID);
        break;

      case PurchaseStatus.error:
        EasyLoading.showToast('Recharge >> Purchase Failed: ${purchase.error}');
        rechargeEventCallback?.call(false, purchase.productID);
        break;

      case PurchaseStatus.pending:
        break;
      case PurchaseStatus.canceled:
        EasyLoading.dismiss();
        break;
    }

    if (purchase.pendingCompletePurchase) {
      InAppPurchase.instance.completePurchase(purchase);
    }
  }

  Future<void> startRecharge(String productId) async {
    debugPrint("Recharge >> startRecharge $productId, products ${_products.length}");
    ProductDetails? product;
    for (var pro in _products) {
      if (pro.id == productId) {
        product = pro;
      }
    }

    if (product == null || product.id.isEmpty) {
      debugPrint("Recharge >> product id not found");
      return;
    }

    EasyLoading.show(status: 'Purchasing...');

    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product, applicationUserName: MyAccount.id);
    iap.buyConsumable(purchaseParam: purchaseParam);
  }
}
