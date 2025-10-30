import 'package:flutter/material.dart';
import '../utils/app_styles.dart';

class LoadingState extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onRetry;

  const LoadingState({
    Key? key,
    this.message = 'Loading...',
    this.isError = false,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppStyles.standardPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isError) ...[
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor),
              ),
              const SizedBox(height: AppStyles.standardSpacing),
            ] else ...[
              Icon(
                Icons.error_outline,
                size: 48,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: AppStyles.smallSpacing),
            ],
            Text(
              message,
              style: AppStyles.bodyStyle.copyWith(
                color: isError ? Theme.of(context).colorScheme.error : null,
              ),
              textAlign: TextAlign.center,
            ),
            if (isError && onRetry != null) ...[
              const SizedBox(height: AppStyles.standardSpacing),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}