// ============================================================
// AUTH SCREEN — Connected to FastAPI backend
// Blue gradient header, white card body, Login/Sign Up tabs
// ============================================================
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/app_components.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen>
    with SingleTickerProviderStateMixin {
  late bool _isLogin;
  late TabController _tabController;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _showPass = false;
  bool _showConfirm = false;
  String _error = '';

  @override
  void initState() {
    super.initState();
    // Read mode from route (default: login)
    _isLogin = true;
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _isLogin = _tabController.index == 0;
        _error = '';
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we came with ?mode=register
    final uri = GoRouterState.of(context).uri;
    final mode = uri.queryParameters['mode'] ?? 'login';
    if (mode == 'register' && _tabController.index != 1) {
      _tabController.animateTo(1);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = '';
    });

    final notifier = ref.read(userProvider.notifier);

    try {
      if (_isLogin) {
        await notifier.login(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
        );
        if (mounted) {
          context.go(AppRoutes.mainShell);
        }
      } else {
        await notifier.register(
          _emailCtrl.text.trim(),
          _passwordCtrl.text,
          name: _nameCtrl.text.trim(),
        );
        if (mounted) context.go(AppRoutes.mainShell);
      }
    } on DioException catch (e) {
      // Parse backend error message
      String msg = 'Something went wrong. Please try again.';
      final detail = e.response?.data?['detail'];
      if (detail != null) {
        msg = detail.toString();
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        msg = 'Connection timed out. Is the backend running?';
      } else if (e.type == DioExceptionType.connectionError) {
        msg = 'Cannot connect to server. Make sure the backend is running on port 8000.';
      }
      if (mounted) {
        setState(() {
          _error = msg;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Blue gradient header ──────────────────────────
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2B3BF7), Color(0xFF1A2AD4)],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0),
                  bottomRight: Radius.circular(0),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: Colors.white, size: 18),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Logo row
                      Row(
                        children: [
                          SizedBox(
                            width: 38,
                            height: 38,
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 38,
                              height: 38,
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 10),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w800),
                              children: [
                                TextSpan(
                                    text: 'Intern',
                                    style: TextStyle(color: Colors.white)),
                                TextSpan(
                                    text: 'Match',
                                    style: TextStyle(
                                        color: Color(0xFF7DF5A0))),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Title
                      AnimatedSwitcher(
                        duration: 300.ms,
                        child: Text(
                          _isLogin
                              ? 'Welcome back! 👋'
                              : 'Create account 🚀',
                          key: ValueKey(_isLogin),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Join 50,000+ students finding great internships',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── White card body ───────────────────────────────
            Container(
              margin: const EdgeInsets.only(top: 0),
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.background,
              ),
              child: Column(
                children: [
                  // Tab switcher
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicator: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppColors.textSecondary,
                      labelStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600),
                      tabs: const [
                        Tab(text: 'Login'),
                        Tab(text: 'Sign Up'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Form
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Name (sign up only)
                        if (!_isLogin) ...[
                          AppTextField(
                            hint: 'Your full name',
                            controller: _nameCtrl,
                            prefixIcon: Icons.person_outline,
                            label: 'Full Name',
                            validator: (v) {
                              if (!_isLogin && (v == null || v.isEmpty)) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                        // Email
                        AppTextField(
                          hint: 'your@email.com',
                          controller: _emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          suffixIcon: Icons.verified_outlined,
                          label: 'Email Address',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Email is required';
                            }
                            if (!v.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        // Password
                        AppTextField(
                          hint: 'Min. 6 characters',
                          controller: _passwordCtrl,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: _showPass
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          onSuffixTap: () =>
                              setState(() => _showPass = !_showPass),
                          obscureText: !_showPass,
                          label: 'Password',
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Password is required';
                            }
                            if (v.length < 6) {
                              return 'Min. 6 characters';
                            }
                            return null;
                          },
                        ),

                        // Confirm password (sign up only)
                        if (!_isLogin) ...[
                          const SizedBox(height: 16),
                          AppTextField(
                            hint: 'Re-enter password',
                            controller: _confirmCtrl,
                            prefixIcon: Icons.lock_outline,
                            suffixIcon: _showConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            onSuffixTap: () =>
                                setState(() => _showConfirm = !_showConfirm),
                            obscureText: !_showConfirm,
                            label: 'Confirm Password',
                            validator: (v) {
                              if (!_isLogin &&
                                  v != _passwordCtrl.text) {
                                return 'Passwords do not match';
                              }
                              return null;
                            },
                          ),
                        ],

                        if (_isLogin) ...[
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('Forgot password?',
                                  style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500)),
                            ),
                          ),
                        ],

                        const SizedBox(height: 8),

                        // Error
                        if (_error.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border:
                                  Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                            ),
                            child: Text(_error,
                                style: const TextStyle(
                                    color: AppColors.error, fontSize: 13)),
                          ),

                        const SizedBox(height: 16),

                        // Submit button
                        PrimaryButton(
                          label: _isLogin ? 'Sign In' : 'Create Account',
                          isLoading: _isLoading,
                          onPressed: _handleSubmit,
                        ),

                        const SizedBox(height: 16),



                        const SizedBox(height: 20),

                        // Feature checklist
                        const _FeatureCheckItem(
                            text: 'AI-powered internship matching'),
                        const SizedBox(height: 8),
                        const _FeatureCheckItem(
                            text: 'Track all your applications'),
                        const SizedBox(height: 8),
                        const _FeatureCheckItem(
                            text: 'Get personalized recommendations'),

                        const SizedBox(height: 20),

                        // Terms
                        const Text.rich(
                          TextSpan(
                            text: 'By continuing, you agree to our ',
                            style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500),
                              ),
                              TextSpan(text: ' & '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCheckItem extends StatelessWidget {
  final String text;
  const _FeatureCheckItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: AppColors.accent, size: 16),
        const SizedBox(width: 8),
        Text(text,
            style: const TextStyle(
                fontSize: 13, color: AppColors.textSecondary)),
      ],
    );
  }
}
