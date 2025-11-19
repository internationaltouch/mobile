import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../providers/device_providers.dart';

class ConnectionStatusWidget extends ConsumerWidget {
  final Widget child;
  final bool showOfflineMessage;

  const ConnectionStatusWidget({
    super.key,
    required this.child,
    this.showOfflineMessage = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivityState = ref.watch(connectivityProvider);

    return connectivityState.when(
      data: (connectivityResults) {
        final isOffline = connectivityResults.every(
          (result) => result == ConnectivityResult.none,
        );

        if (isOffline && showOfflineMessage) {
          return Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                color: Colors.red.shade100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 16,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'No internet connection',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          );
        }

        return child;
      },
      loading: () => child,
      error: (_, __) => child,
    );
  }
}

class AdaptiveLoadingWidget extends ConsumerWidget {
  final Widget child;
  final Widget? loadingWidget;

  const AdaptiveLoadingWidget({
    super.key,
    required this.child,
    this.loadingWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLowEndDevice = ref.watch(isLowEndDeviceProvider);

    return isLowEndDevice.when(
      data: (isLowEnd) {
        if (isLowEnd && loadingWidget != null) {
          return loadingWidget!;
        }
        return child;
      },
      loading: () => loadingWidget ?? child,
      error: (_, __) => child,
    );
  }
}

class NetworkAwareWidget extends ConsumerWidget {
  final Widget onlineChild;
  final Widget offlineChild;
  final Widget? loadingChild;

  const NetworkAwareWidget({
    super.key,
    required this.onlineChild,
    required this.offlineChild,
    this.loadingChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isConnected = ref.watch(isConnectedProvider);

    return isConnected.when(
      data: (connected) => connected ? onlineChild : offlineChild,
      loading: () => loadingChild ?? onlineChild,
      error: (_, __) => offlineChild,
    );
  }
}
