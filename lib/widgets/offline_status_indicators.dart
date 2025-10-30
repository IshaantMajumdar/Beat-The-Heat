import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/connectivity_service.dart';
import '../utils/app_styles.dart';

class OfflineStatusBanner extends StatelessWidget {
  const OfflineStatusBanner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        if (!connectivity.isOffline) {
          return StreamBuilder<bool>(
            stream: connectivity.isSyncing,
            builder: (context, snapshot) {
              if (snapshot.data == true) {
                return _buildBanner(
                  context,
                  'Syncing data...',
                  Theme.of(context).colorScheme.primary,
                  Icons.sync,
                  true,
                );
              }
              return const SizedBox.shrink();
            },
          );
        }

        return _buildBanner(
          context,
          'Offline Mode - Using cached data',
          Theme.of(context).colorScheme.error,
          Icons.wifi_off_rounded,
          false,
        );
      },
    );
  }

  Widget _buildBanner(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
    bool isAnimated,
  ) {
    return AnimatedSlide(
      duration: AppStyles.quickAnimation,
      offset: const Offset(0, 0),
      child: Material(
        elevation: 2,
        child: Container(
          width: double.infinity,
          color: color.withOpacity(0.12),
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isAnimated)
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 4.0),
                    duration: const Duration(seconds: 2),
                    builder: (context, value, child) {
                      return Transform.rotate(
                        angle: value * 3.14159,
                        child: Icon(
                          icon,
                          size: 16,
                          color: color,
                        ),
                      );
                    },
                  )
                else
                  Icon(
                    icon,
                    size: 16,
                    color: color,
                  ),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OfflineIndicator extends StatelessWidget {
  final Widget child;
  final Widget? offlineWidget;

  const OfflineIndicator({
    Key? key,
    required this.child,
    this.offlineWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityService>(
      builder: (context, connectivity, _) {
        if (connectivity.isOffline && offlineWidget != null) {
          return AnimatedSwitcher(
            duration: AppStyles.standardAnimation,
            child: offlineWidget,
          );
        }

        if (connectivity.isOffline) {
          return Stack(
            children: [
              AnimatedOpacity(
                duration: AppStyles.standardAnimation,
                opacity: 0.6,
                child: child,
              ),
              Positioned(
                right: 8,
                top: 8,
                child: TweenAnimationBuilder<double>(
                  duration: AppStyles.standardAnimation,
                  tween: Tween(begin: 0.0, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.wifi_off_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Cached Data',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }

        return child;
      },
    );
  }
}

class SyncStatusIndicator extends StatelessWidget {
  final Stream<bool> isSyncing;

  const SyncStatusIndicator({
    Key? key,
    required this.isSyncing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: isSyncing,
      initialData: false,
      builder: (context, snapshot) {
        return AnimatedSwitcher(
          duration: AppStyles.standardAnimation,
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, -0.5),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            );
          },
          child: !snapshot.data!
              ? const SizedBox.shrink()
              : Container(
                  key: const ValueKey<String>('sync_indicator'),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(seconds: 1),
                          tween: Tween(begin: 0.0, end: 4.0),
                          builder: (context, value, child) {
                            return Transform.rotate(
                              angle: value * 3.14159,
                              child: child,
                            );
                          },
                          child: const Icon(
                            Icons.sync,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Syncing data...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}