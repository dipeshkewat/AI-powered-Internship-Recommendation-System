import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/shared_widgets.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.auto_awesome,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'InternMatch',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),

                const Spacer(flex: 2),

                // Headline
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Find internships\ntailored to you.',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'AI-powered matching using your skills, CGPA,\nand interests — not just keywords.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 250.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 250.ms),

                const Spacer(flex: 1),

                // Feature pills
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    _FeaturePill(
                        label: '🤖 ML Matching', color: AppColors.primary),
                    _FeaturePill(
                        label: '📍 Location Filter',
                        color: AppColors.secondary),
                    _FeaturePill(
                        label: '⚡ Real-time Results',
                        color: AppColors.tertiary),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms),

                const Spacer(flex: 2),

                // CTAs
                Column(
                  children: [
                    GradientButton(
                      label: 'Get Started',
                      onPressed: () => context.go(AppRoutes.register),
                      icon: const Icon(Icons.arrow_forward,
                          color: Colors.white, size: 18),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('I already have an account'),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 550.ms, duration: 400.ms)
                    .slideY(begin: 0.15, end: 0, delay: 550.ms),

                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Trusted by 10,000+ students across India',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
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

class _FeaturePill extends StatelessWidget {
  final String label;
  final Color color;

  const _FeaturePill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
