import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:noting/repository/app_data.dart';
import 'package:provider/provider.dart';

Future<void> fappsProcessInAppPurchase(BuildContext context) async {
  bool _isDonateMode = (context.read<AppData>().removeAds);
  print('iap donate mode? $_isDonateMode');
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: AspectRatio(
        child: CircularProgressIndicator(),
        aspectRatio: 1.0,
      ),
    ),
  );

  // 1. check available
  final bool available = await InAppPurchaseConnection.instance.isAvailable();
  if (!available) {
    print('iap unavailable');
    gIApStatus = InAppPurchaseStatus.error;
  }

  // 2. get product info
  String _iOSRemoveAdsId = 'removeAds';
  String _androidRemoveAdsId = 'remove_ads';
  String _removeAdsId = Platform.isIOS ? _iOSRemoveAdsId : _androidRemoveAdsId;
  Set<String> _kIdsRemoveAds = {_removeAdsId};
  Set<String> _kIdsDonate = {'donation'};

  final ProductDetailsResponse response = await InAppPurchaseConnection.instance
      .queryProductDetails(_isDonateMode ? _kIdsDonate : _kIdsRemoveAds);
  if (response.notFoundIDs.isNotEmpty) {
    print('iap query error');
    gIApStatus = InAppPurchaseStatus.error;
  }
  List<ProductDetails> products = response.productDetails;

  // 3. check past purchases
  if (_isDonateMode == false) {
    final QueryPurchaseDetailsResponse responsePast =
        await InAppPurchaseConnection.instance.queryPastPurchases();
    if (response.error != null) {
      print('iap past response error');
      gIApStatus = InAppPurchaseStatus.error;
    }
    for (PurchaseDetails purchase in responsePast.pastPurchases) {
      print('iap past response occur');
      context.read<AppData>().setRemoveAds();
      gIApStatus = InAppPurchaseStatus.alreadyPurchased;
      if (Platform.isIOS) {
        InAppPurchaseConnection.instance.completePurchase(purchase);
      }
    }
  }

  // 4. process purchase
  if (gIApStatus == InAppPurchaseStatus.alreadyPurchased) {
  } else if (gIApStatus != InAppPurchaseStatus.error) {
    gIApStatus = InAppPurchaseStatus.processing;
    print('iap process start');
    final ProductDetails productDetails = products.last;
    final PurchaseParam purchaseParam =
        PurchaseParam(productDetails: productDetails);
    if (_isConsumable(productDetails)) {
      InAppPurchaseConnection.instance
          .buyConsumable(purchaseParam: purchaseParam);
    } else {
      InAppPurchaseConnection.instance
          .buyNonConsumable(purchaseParam: purchaseParam);
    }
  }

  // 5. wait until finish process
  print('await');
  await _whenIapDone();
  Navigator.of(context).pop();
  print('await done');

  if (gIApStatus == InAppPurchaseStatus.alreadyPurchased) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchasing Restored!'),
      ),
    );
  } else if (gIApStatus == InAppPurchaseStatus.error) {
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Payment Failed.'),
      ),
    );
  } else if (gIApStatus == InAppPurchaseStatus.success) {
    context.read<AppData>().setRemoveAds();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thank You!'),
      ),
    );
  }

  gIApStatus = InAppPurchaseStatus.ready;
}

bool _isConsumable(ProductDetails productDetails) {
  if (Platform.isAndroid) {
    if (productDetails.id == 'remove_ads') {
      return false;
    } else {
      return true;
    }
  } else {
    if (productDetails.id == 'removeAds') {
      return false;
    } else {
      return true;
    }
  }
}

Future<bool> _whenIapDone() async {
  for (int i = 0; i < 6000; i++) {
    if (gIApStatus == InAppPurchaseStatus.processing) {
      await Future.delayed(const Duration(milliseconds: 100), () {});
    } else {
      print(gIApStatus);
      return true;
    }
  }
  return false;
}

void initFappsInAppPurchase(
    StreamSubscription<List<PurchaseDetails>> _subscription) {
  final Stream purchaseUpdates =
      InAppPurchaseConnection.instance.purchaseUpdatedStream;
  _subscription = purchaseUpdates.listen((purchases) {
    print('listener..');
    _listenToPurchaseUpdated(purchases);
  });
}

void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
  purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
    print(purchaseDetails.status);
    if (purchaseDetails.status == PurchaseStatus.pending) {
      // showPendingUI();
    } else {
      if (purchaseDetails.status == PurchaseStatus.error) {
        // handleError(purchaseDetails.error);
        gIApStatus = InAppPurchaseStatus.error;
        print('error : ${purchaseDetails.error.message}');
      } else if (purchaseDetails.status == PurchaseStatus.purchased) {
        gIApStatus = InAppPurchaseStatus.success;
        InAppPurchaseConnection.instance.completePurchase(purchaseDetails);
      }
      if (Platform.isAndroid) {
        if (purchaseDetails.productID == 'donation') {
          await InAppPurchaseConnection.instance
              .consumePurchase(purchaseDetails);
        }
      }
      if (purchaseDetails.pendingCompletePurchase) {
        await InAppPurchaseConnection.instance
            .completePurchase(purchaseDetails);
      }
    }
  });
}
