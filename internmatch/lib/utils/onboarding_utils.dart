import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Builds the onboarding screen header with progress indicator
Widget buildOnboardingHeader(
  BuildContext context,
  int current,
  int total,
) {
  final progress = current / total;
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Text(
              'Step $current of $total',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
            const SizedBox(width: 40),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
      ],
    ),
  );
}

/// Builds navigation buttons for onboarding screens
Widget buildOnboardingNavigationButtons(
  BuildContext context, {
  VoidCallback? onNext,
  VoidCallback? onBack,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
    child: Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onBack ?? () => context.pop(),
            child: Text(
              'Back',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: AppColors.primary,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: onNext,
            child: Text(
              'Next',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ),
        ),
      ],
    ),
  );
}
