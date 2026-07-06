import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_colors.dart';

class ConnectivityController {
  ConnectivityController._();

  static const _requestTimeout = Duration(seconds: 4);
  static const _periodicCheckInterval = Duration(seconds: 20);

  static final Connectivity _connectivity = Connectivity();
  static StreamSubscription<List<ConnectivityResult>>? _subscription;
  static Timer? _periodicTimer;
  static Timer? _connectionChangeDebounce;
  static _ConnectivityLifecycleObserver? _lifecycleObserver;
  static GlobalKey<NavigatorState>? _navigatorKey;

  static bool _isChecking = false;
  static bool _isDialogShowing = false;
  static bool? _isOnline;
  static BuildContext? _dialogContext;

  static void init(GlobalKey<NavigatorState> navigatorKey) {
    _navigatorKey = navigatorKey;

    _lifecycleObserver ??= _ConnectivityLifecycleObserver(
      onResumed: () {
        _startPeriodicChecks();
        unawaited(checkNow());
      },
      onPaused: _stopPeriodicChecks,
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver!);

    unawaited(checkNow());
    _subscription = _connectivity.onConnectivityChanged.listen((_) {
      _connectionChangeDebounce?.cancel();
      _connectionChangeDebounce = Timer(
        const Duration(milliseconds: 350),
        () => unawaited(checkNow()),
      );
    });
    _startPeriodicChecks();
  }

  static Future<void> checkNow() async {
    if (_isChecking) return;
    _isChecking = true;
    try {
      final connectivity = await _connectivity.checkConnectivity();
      await _handleConnectivityChange(connectivity);
    } catch (_) {
      _updateStatus(false);
    } finally {
      _isChecking = false;
    }
  }

  static Future<void> _handleConnectivityChange(
    List<ConnectivityResult> results,
  ) async {
    final hasNetworkInterface = results.any(
      (result) => result != ConnectivityResult.none,
    );
    if (!hasNetworkInterface) {
      _updateStatus(false);
      return;
    }

    _updateStatus(await _canReachSupabase());
  }

  static Future<bool> _canReachSupabase() async {
    final client = HttpClient()..connectionTimeout = _requestTimeout;
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/auth/v1/health');
      final request = await client.getUrl(uri).timeout(_requestTimeout);
      request.headers.set('apikey', ApiConstants.apiKey);
      final response = await request.close().timeout(_requestTimeout);
      await response.drain<void>().timeout(_requestTimeout);
      return true;
    } on TimeoutException {
      return false;
    } on SocketException {
      return false;
    } on HandshakeException {
      return false;
    } on HttpException {
      return false;
    } catch (_) {
      return false;
    } finally {
      client.close(force: true);
    }
  }

  static void _updateStatus(bool isOnline) {
    _isOnline = isOnline;
    final navigatorKey = _navigatorKey;
    if (navigatorKey == null) return;

    if (isOnline) {
      _dismiss();
      return;
    }

    _show(navigatorKey);
  }

  static void _startPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(
      _periodicCheckInterval,
      (_) => unawaited(checkNow()),
    );
  }

  static void _stopPeriodicChecks() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _connectionChangeDebounce?.cancel();
    _connectionChangeDebounce = null;
    _stopPeriodicChecks();

    final observer = _lifecycleObserver;
    if (observer != null) {
      WidgetsBinding.instance.removeObserver(observer);
    }
    _lifecycleObserver = null;
    _navigatorKey = null;
    _dialogContext = null;
    _isChecking = false;
    _isDialogShowing = false;
    _isOnline = null;
  }

  static void _onDialogClosed() {
    _dialogContext = null;
    _isDialogShowing = false;
  }

  static void _show(GlobalKey<NavigatorState> navigatorKey) {
    if (_isOnline != false || _isDialogShowing) return;
    _isDialogShowing = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isOnline != false) {
        _isDialogShowing = false;
        return;
      }

      final context = navigatorKey.currentContext;
      if (context == null) {
        _isDialogShowing = false;
        return;
      }
      final l = AppLocalizations.of(context);

      showDialog<void>(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true,
        builder: (dialogContext) {
          _dialogContext = dialogContext;
          return PopScope(
            canPop: false,
            child: GestureDetector(
              onTap: () => Navigator.of(dialogContext, rootNavigator: true).pop(),
              behavior: HitTestBehavior.opaque,
              child: AlertDialog(
                backgroundColor: AppColors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                title: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.wifi_off_rounded,
                      size: 48,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l?.noInternetTitle ?? 'No internet connection',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black10,
                      ),
                    ),
                  ],
                ),
                content: Text(
                  l?.noInternetMessage ??
                      'Check your connection to continue using the app.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.font01,
                  ),
                ),
              ),
            ),
          );
        },
      ).then((_) => _onDialogClosed());
    });
  }

  static void _dismiss() {
    if (!_isDialogShowing) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _dialogContext;
      if (context == null || !context.mounted) {
        _onDialogClosed();
        return;
      }

      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      } else {
        _onDialogClosed();
      }
    });
  }
}

class _ConnectivityLifecycleObserver extends WidgetsBindingObserver {
  final VoidCallback onResumed;
  final VoidCallback onPaused;

  _ConnectivityLifecycleObserver({
    required this.onResumed,
    required this.onPaused,
  });

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        onResumed();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        onPaused();
        break;
    }
  }
}
