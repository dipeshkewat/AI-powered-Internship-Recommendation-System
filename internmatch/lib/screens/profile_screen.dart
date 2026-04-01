import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../utils/app_router.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/resume_upload_widget.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final bool isOnboarding;

  const ProfileScreen({super.key, this.isOnboarding = false});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _collegeCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  List<String> _skills = [];
  double _cgpa = 7.0;
  List<String> _interests = [];
  String _preferredType = 'Any';
  int _gradYear = DateTime.now().year + 1;

  final List<String> _domainOptions = [
    'AI/ML',
    'App Dev',
    'Web',
    'Data Science',
    'Cloud',
    'DevOps',
    'Cybersecurity'
  ];
  final List<String> _typeOptions = ['Any', 'Remote', 'Hybrid', 'On-site'];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _skills = List.from(profile.skills);
    _cgpa = profile.cgpa;
    _interests = List.from(profile.interests);
    _preferredType = profile.preferredType;
    _nameCtrl.text = profile.name;
    _locationCtrl.text = profile.preferredLocation;
    if (profile.college != null) _collegeCtrl.text = profile.college!;
    if (profile.graduationYear != null) _gradYear = profile.graduationYear!;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _collegeCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  void _saveProfile() {
    ref.read(profileProvider.notifier).updateLocally(
          name: _nameCtrl.text,
          skills: _skills,
          cgpa: _cgpa,
          interests: _interests,
          preferredLocation: _locationCtrl.text,
          preferredType: _preferredType,
          college: _collegeCtrl.text,
          graduationYear: _gradYear,
        );

    if (widget.isOnboarding) {
      context.go(AppRoutes.home);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated!')),
      );
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.isOnboarding) ...[
                      _SectionCard(
                        title: 'Basic Info',
                        icon: Icons.person_outline,
                        child: Column(
                          children: [
                            AppTextField(
                              controller: _nameCtrl,
                              label: 'Full Name',
                              prefixIcon: const Icon(Icons.badge_outlined),
                            ),
                            const SizedBox(height: 12),
                            AppTextField(
                              controller: _collegeCtrl,
                              label: 'College / University',
                              prefixIcon: const Icon(Icons.school_outlined),
                            ),
                            const SizedBox(height: 12),
                            _GradYearPicker(
                              value: _gradYear,
                              onChanged: (y) => setState(() => _gradYear = y),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Skills
                    _SectionCard(
                      title: 'Your Skills',
                      subtitle: 'Used by the ML model to match internships',
                      icon: Icons.code,
                      child: SkillChipInput(
                        skills: _skills,
                        onChanged: (s) => setState(() => _skills = s),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // CGPA
                    _SectionCard(
                      title: 'CGPA',
                      subtitle: 'Your current GPA',
                      icon: Icons.school_outlined,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '0.0',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 6),
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _cgpa.toStringAsFixed(1),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Text(
                                '10.0',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Slider(
                            value: _cgpa,
                            min: 0,
                            max: 10,
                            divisions: 100,
                            onChanged: (v) => setState(() => _cgpa = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interests
                    _SectionCard(
                      title: 'Domains of Interest',
                      subtitle: 'Select all that apply',
                      icon: Icons.interests_outlined,
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _domainOptions.map((d) {
                          final selected = _interests.contains(d);
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (selected) {
                                  _interests.remove(d);
                                } else {
                                  _interests.add(d);
                                }
                              });
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary.withOpacity(0.2)
                                    : AppColors.surfaceElevated,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                d,
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.primaryLight
                                      : AppColors.textSecondary,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preferences
                    _SectionCard(
                      title: 'Work Preferences',
                      icon: Icons.tune,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppTextField(
                            controller: _locationCtrl,
                            label: 'Preferred Location',
                            hint: 'e.g. Bangalore, Mumbai, Remote',
                            prefixIcon:
                                const Icon(Icons.location_on_outlined),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Internship Type',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: _typeOptions.map((t) {
                              final selected = _preferredType == t;
                              return Expanded(
                                child: GestureDetector(
                                  onTap: () =>
                                      setState(() => _preferredType = t),
                                  child: AnimatedContainer(
                                    duration:
                                        const Duration(milliseconds: 150),
                                    margin: EdgeInsets.only(
                                        right:
                                            t == _typeOptions.last ? 0 : 6),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    decoration: BoxDecoration(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.surfaceElevated,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: selected
                                            ? AppColors.primary
                                            : AppColors.border,
                                      ),
                                    ),
                                    child: Text(
                                      t,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: selected
                                            ? Colors.white
                                            : AppColors.textSecondary,
                                        fontSize: 11,
                                        fontWeight: selected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Resume upload
                    _SectionCard(
                      title: 'Resume',
                      subtitle: 'PDF, DOC or DOCX · Max 5 MB',
                      icon: Icons.description_outlined,
                      child: ResumeUploadWidget(
                        existingResumeUrl:
                            ref.read(profileProvider).resumeUrl,
                        onFileSelected: (file) {
                          // TODO: Call ApiService.uploadResume(file)
                          // and update profileProvider with the returned URL
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: GradientButton(
          label: widget.isOnboarding ? 'Complete Setup →' : 'Save Profile',
          onPressed: _saveProfile,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          if (!widget.isOnboarding)
            IconButton(
              icon: const Icon(Icons.arrow_back_ios,
                  size: 18, color: AppColors.textSecondary),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.home);
                }
              },
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.isOnboarding ? 'Set up your profile' : 'Edit Profile',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                widget.isOnboarding
                    ? 'This helps the ML model find your best matches'
                    : 'Update your skills and preferences',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, color: AppColors.primary, size: 14),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Grad Year Picker ──────────────────────────────────────────────────────────

class _GradYearPicker extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;

  const _GradYearPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final currentYear = DateTime.now().year;
    final years = List.generate(6, (i) => currentYear + i - 1);

    return DropdownButtonFormField<int>(
      initialValue: value,
      dropdownColor: AppColors.surfaceElevated,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: const InputDecoration(labelText: 'Graduation Year'),
      items: years
          .map((y) => DropdownMenuItem(
                value: y,
                child: Text(y.toString()),
              ))
          .toList(),
      onChanged: (y) {
        if (y != null) onChanged(y);
      },
    );
  }
}
