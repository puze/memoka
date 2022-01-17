import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class MyInappPurchase {
  static final MyInappPurchase _instance = MyInappPurchase._internal();
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> productDetails = [];

  factory MyInappPurchase() {
    return _instance;
  }

  MyInappPurchase._internal() {
    // 초기화
    // final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    // _subscription = purchaseUpdated.listen((purchaseDetailsList) {
    //   _listenToPurchaseUpdated(purchaseDetailsList);
    // }, onDone: () {
    //   _subscription.cancel();
    // }, onError: (error) {
    //   // handle error here.
    // }) as StreamSubscription<List<PurchaseDetails>>;
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // _handleError(purchaseDetails.error!);
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            // _deliverProduct(purchaseDetails);
          } else {
            // _handleInvalidPurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    switch (purchaseDetails.productID) {
      case "add_memoka_ad_remove":
        debugPrint('purchase : add_memoka_ad_remove');
        return true;
    }
    return false;
  }

  void fetch() async {
    final bool available = await InAppPurchase.instance.isAvailable();
    if (available) {
      // The store cannot be reached or accessed. Update the UI accordingly.
      // Set literals require Dart 2.2. Alternatively, use
      // `Set<String> _kIds = <String>['product1', 'product2'].toSet()`.
      const Set<String> _kIds = <String>{'add_memoka_ad_remove'};
      final ProductDetailsResponse response =
          await InAppPurchase.instance.queryProductDetails(_kIds);
      if (response.notFoundIDs.isNotEmpty) {
        // Handle the error.
      }
      productDetails = response.productDetails;
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
