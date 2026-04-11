import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    final storage = await StorageService.getInstance();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    if (storage.onboardingDone) {
      context.go(AppRoutes.mainShell);
    } else {
      context.go(AppRoutes.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.work_outline_rounded,
                color: AppColors.primary,
                size: 40,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            RichText(
              text: const TextSpan(
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5),
                children: [
                  TextSpan(
                      text: 'Intern',
                      style: TextStyle(color: Colors.white)),
                  TextSpan(
                      text: 'Match',
                      style: TextStyle(color: Color(0xFF7DF5A0))),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms, duration: 400.ms)
                .slideY(begin: 0.3, end: 0, delay: 400.ms),

            const SizedBox(height: 8),

            Text(
              'Internships that match you.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ).animate().fadeIn(delay: 600.ms, duration: 400.ms),

            const SizedBox(height: 64),

            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: const LinearProgressIndicator(
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 3,
                ),
              ),
            ).animate().fadeIn(delay: 800.ms, duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
