import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class ConnectivityController {
  ConnectivityController._();

  static bool _isDialogShowing = false;
  static StreamSubscription<List<ConnectivityResult>>? _subscription;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    final connectivity = Connectivity();
    void handle(List<ConnectivityResult> result) {
      final hasConnection = result.any((r) => r != ConnectivityResult.none);
      if (hasConnection) {
        _dismiss(navigatorKey);
      } else {
        _show(navigatorKey);
      }
    }
    connectivity.checkConnectivity().then(handle);
    _subscription = connectivity.onConnectivityChanged.listen(handle);
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isDialogShowing = false;
  }

  static void _show(GlobalKey<NavigatorState> navigatorKey) {
    if (_isDialogShowing) return;
    _isDialogShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = navigatorKey.currentContext;
      if (context == null) {
        _isDialogShowing = false;
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            backgroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            title: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.wifi_off_rounded, size: 48, color: AppColors.error),
                SizedBox(height: 12),
                Text(
                  'لا يوجد اتصال بالإنترنت',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black10,
                  ),
                ),
              ],
            ),
            content: Text(
              'يرجى الاتصال بالإنترنت للمتابعة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppColors.font01,
              ),
            ),
          ),
        ),
      ).then((_) => _isDialogShowing = false);
    });
  }

  static void _dismiss(GlobalKey<NavigatorState> navigatorKey) {
    if (!_isDialogShowing) return;
    _isDialogShowing = false;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigatorKey.currentState?.pop();
    });
  }
}
