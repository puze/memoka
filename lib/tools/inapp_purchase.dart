import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import '../data_manager.dart';
import 'popup_dialog.dart';

class MyInappPurchase {
  static final MyInappPurchase _instance = MyInappPurchase._internal();
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> productDetails = [];
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late BuildContext _context;

  factory MyInappPurchase() {
    return _instance;
  }

  MyInappPurchase._internal() {
    // 초기화
    final Stream purchaseUpdated = InAppPurchase.instance.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      // handle error here.
    }) as StreamSubscription<List<PurchaseDetails>>;
  }

  void setContext(BuildContext context) {
    _context = context;
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // _showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // _handleError(purchaseDetails.error!);
          Navigator.push(_context,
              PopupDialog(message: '구매 중 오류가 발생 하였습니다. 잠시 후 다시 시도해 주세요.'));
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            _deliverProduct(purchaseDetails);
          } else {
            // _handleInvalidPurchase(purchaseDetails);
            Navigator.push(_context,
                PopupDialog(message: '구매 중 오류가 발생 하였습니다. 잠시 후 다시 시도해 주세요.'));
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
        DataManager().memokaGroupList!.addMemokaAdRemove =
            DataManager.adRemoveTrueValue;
        return true;
    }
    return false;
  }

  void fetch() async {
    final bool available = await _inAppPurchase.isAvailable();
    if (available) {
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

  void _deliverProduct(PurchaseDetails purchaseDetails) {
    switch (purchaseDetails.productID) {
      case "add_memoka_ad_remove":
        DataManager().memokaGroupList!.addMemokaAdRemove = 'true';
        DataManager().saveData();
        break;
    }
  }
}
