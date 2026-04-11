// ============================================================
// ONBOARDING SCREEN — 8 steps, matches reference video
// White bg, progress bar + dots, bold step headers
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/user_provider.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/app_components.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _page = PageController();
  int _step = 0;
  final int _total = 8;

  // Step data
  String? _educationLevel;
  String? _experienceLevel;
  bool? _hasDoneInternship;

  // Basic info
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Academic
  String? _degree;
  String? _year;
  double _cgpa = 7.0;

  // Skills
  final List<String> _skills = [];
  final List<String> _tools = [];
  final _customSkillCtrl = TextEditingController();
  final _customToolCtrl = TextEditingController();

  // Interests
  final List<String> _interests = [];

  // Preferences
  String? _locPref;
  String? _typePref;
  String? _durationPref;

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _educationLevel != null;
      case 1:
        return _experienceLevel != null;
      case 2:
        return _hasDoneInternship != null;
      case 3:
        return _nameCtrl.text.isNotEmpty;
      case 4:
        return _degree != null && _year != null;
      case 5:
        return _skills.isNotEmpty;
      case 6:
        return _interests.isNotEmpty;
      case 7:
        return _locPref != null && _typePref != null;
      default:
        return true;
    }
  }

  Future<void> _next() async {
    if (_step < _total - 1) {
      _page.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    } else {
      await _finish();
    }
  }

  void _prev() {
    if (_step > 0) {
      _page.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  Future<void> _finish() async {
    final notifier = ref.read(userProvider.notifier);
    notifier.updateEducation(_educationLevel ?? '');
    notifier.updateExperience(_experienceLevel ?? '');
    notifier.updateProfile(
      fullName: _nameCtrl.text,
      phoneNo: _phoneCtrl.text,
      degree: _degree ?? '',
      currentYear: _year ?? '',
      cgpa: _cgpa.toStringAsFixed(1),
    );
    notifier.updateSkills(_skills);
    notifier.updateTools(_tools);
    notifier.updateInterests(_interests);
    notifier.updatePreferences(
      preferredLocation: _locPref ?? '',
      internshipType: _typePref ?? '',
      duration: _durationPref ?? '',
    );
    notifier.completeOnboarding();

    final storage = await StorageService.getInstance();
    await storage.setOnboardingDone();
    

    if (mounted) context.go(AppRoutes.mainShell);
  }

  @override
  void dispose() {
    _page.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _customSkillCtrl.dispose();
    _customToolCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  // Logo + skip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.work_outline_rounded,
                                color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 8),
                          const Text('InternMatch',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary)),
                        ],
                      ),
                      if (_step > 0)
                        GestureDetector(
                          onTap: () => context.go(AppRoutes.mainShell),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_back,
                                color: AppColors.textSecondary, size: 16),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress
                  OnboardingProgress(current: _step + 1, total: _total),
                ],
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _step = i),
                children: [
                  _Step1Education(
                    selected: _educationLevel,
                    onSelect: (v) => setState(() => _educationLevel = v),
                  ),
                  _Step2Experience(
                    selected: _experienceLevel,
                    onSelect: (v) => setState(() => _experienceLevel = v),
                  ),
                  _Step3PastInternship(
                    selected: _hasDoneInternship,
                    onSelect: (v) => setState(() => _hasDoneInternship = v),
                  ),
                  _Step4BasicInfo(
                    nameCtrl: _nameCtrl,
                    phoneCtrl: _phoneCtrl,
                    onChanged: () => setState(() {}),
                  ),
                  _Step5Academics(
                    degree: _degree,
                    year: _year,
                    cgpa: _cgpa,
                    onDegree: (v) => setState(() => _degree = v),
                    onYear: (v) => setState(() => _year = v),
                    onCgpa: (v) => setState(() => _cgpa = v),
                  ),
                  _Step6Skills(
                    skills: _skills,
                    tools: _tools,
                    customSkillCtrl: _customSkillCtrl,
                    customToolCtrl: _customToolCtrl,
                    onChanged: () => setState(() {}),
                  ),
                  _Step7Interests(
                    selected: _interests,
                    onChanged: () => setState(() {}),
                  ),
                  _Step8Preferences(
                    locPref: _locPref,
                    typePref: _typePref,
                    durationPref: _durationPref,
                    onLoc: (v) => setState(() => _locPref = v),
                    onType: (v) => setState(() => _typePref = v),
                    onDuration: (v) => setState(() => _durationPref = v),
                  ),
                ],
              ),
            ),

            // Bottom nav
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: PrimaryButton(
                label: _step == _total - 1
                    ? 'Finish & Find Internships 🎉'
                    : 'Continue',
                onPressed: _canContinue ? _next : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step 1 — Education Level ────────────────────────────────
class _Step1Education extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _Step1Education({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 1 · EDUCATION',
      title: 'Your education\nlevel?',
      subtitle: "We'll tailor recommendations to your background.",
      child: Column(
        children: [
          OptionCard(
            title: 'Undergraduate',
            subtitle: 'Currently pursuing a Bachelor\'s degree',
            icon: Icons.school_outlined,
            isSelected: selected == 'Undergraduate',
            onTap: () => onSelect('Undergraduate'),
          ),
          const SizedBox(height: 12),
          OptionCard(
            title: 'Graduate',
            subtitle: 'Pursuing or completed a Master\'s/PhD',
            icon: Icons.workspace_premium_outlined,
            isSelected: selected == 'Graduate',
            onTap: () => onSelect('Graduate'),
          ),
          const SizedBox(height: 12),
          OptionCard(
            title: 'Diploma / Other',
            subtitle: 'Diploma, certification or other program',
            icon: Icons.card_membership_outlined,
            isSelected: selected == 'Diploma',
            onTap: () => onSelect('Diploma'),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2 — Experience Level ───────────────────────────────
class _Step2Experience extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;
  const _Step2Experience({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 2 · EXPERIENCE',
      title: 'Your experience\nlevel?',
      subtitle: "We'll tailor recommendations to your current experience level.",
      child: Column(
        children: [
          OptionCard(
            title: 'Fresher',
            subtitle: 'No prior internship or work experience',
            icon: Icons.bolt_outlined,
            isSelected: selected == 'Fresher',
            onTap: () => onSelect('Fresher'),
          ),
          const SizedBox(height: 12),
          OptionCard(
            title: 'Intermediate',
            subtitle: 'Have done at least one internship before',
            icon: Icons.verified_outlined,
            isSelected: selected == 'Intermediate',
            onTap: () => onSelect('Intermediate'),
          ),
          const SizedBox(height: 12),
          OptionCard(
            title: 'Experienced',
            subtitle: 'Multiple internships or part-time work',
            icon: Icons.star_outline,
            isSelected: selected == 'Experienced',
            onTap: () => onSelect('Experienced'),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3 — Past Internship ────────────────────────────────
class _Step3PastInternship extends StatelessWidget {
  final bool? selected;
  final ValueChanged<bool> onSelect;
  const _Step3PastInternship({this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 3 · HISTORY',
      title: 'Any past\ninternships?',
      subtitle: 'This helps us suggest opportunities at the right level.',
      child: Column(
        children: [
          OptionCard(
            title: 'Yes, I have',
            subtitle: 'I\'ve completed at least one internship',
            icon: Icons.check_circle_outline,
            isSelected: selected == true,
            onTap: () => onSelect(true),
          ),
          const SizedBox(height: 12),
          OptionCard(
            title: 'No, this is my first',
            subtitle: 'I\'m looking for my first internship',
            icon: Icons.new_releases_outlined,
            isSelected: selected == false,
            onTap: () => onSelect(false),
          ),
        ],
      ),
    );
  }
}

// ─── Step 4 — Basic Info ──────────────────────────────────────
class _Step4BasicInfo extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController phoneCtrl;
  final VoidCallback onChanged;

  const _Step4BasicInfo({
    required this.nameCtrl,
    required this.phoneCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 4 · BASIC INFO',
      title: 'Basic\nInformation',
      subtitle:
          'Let us know who you are so we can personalize your profile.',
      child: Column(
        children: [
          AppTextField(
            hint: 'Your full name',
            controller: nameCtrl,
            prefixIcon: Icons.person_outline,
            label: 'Full Name',
            onChanged: (_) => onChanged(),
          ),
          const SizedBox(height: 16),
          AppTextField(
            hint: '10-digit mobile number',
            controller: phoneCtrl,
            prefixIcon: Icons.phone_outlined,
            label: 'Phone Number',
            keyboardType: TextInputType.phone,
          ),
        ],
      ),
    );
  }
}

// ─── Step 5 — Academics ───────────────────────────────────────
class _Step5Academics extends StatelessWidget {
  final String? degree;
  final String? year;
  final double cgpa;
  final ValueChanged<String> onDegree;
  final ValueChanged<String> onYear;
  final ValueChanged<double> onCgpa;

  const _Step5Academics({
    this.degree,
    this.year,
    required this.cgpa,
    required this.onDegree,
    required this.onYear,
    required this.onCgpa,
  });

  static const _degrees = ['B.Sc', 'B.Tech', 'B.E', 'BCA', 'MCA', 'M.Tech', 'MBA', 'Other'];
  static const _years = ['1st Year', '2nd Year', '3rd Year', '4th Year', 'Final Year'];

  String get _cgpaLabel {
    if (cgpa >= 9) return 'Excellent 🏆';
    if (cgpa >= 8) return 'Very Good ⭐';
    if (cgpa >= 7) return 'Good 👍';
    if (cgpa >= 6) return 'Average 😊';
    return 'Below Average';
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 5 · ACADEMICS',
      title: 'Academic\nDetails',
      subtitle: 'Your academic background helps us find the most relevant opportunities.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('DEGREE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _degrees.map((d) => SelectableChip(
                  label: d,
                  isSelected: degree == d,
                  onTap: () => onDegree(d),
                )).toList(),
          ),
          const SizedBox(height: 20),
          const Text('CURRENT YEAR',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _years.map((y) => SelectableChip(
                  label: y,
                  isSelected: year == y,
                  onTap: () => onYear(y),
                )).toList(),
          ),
          const SizedBox(height: 20),
          const Text('CURRENT CGPA / PERCENTAGE',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.8)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.school_outlined,
                        color: AppColors.textMuted, size: 16),
                    const SizedBox(width: 8),
                    Text(cgpa.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600)),
                  ],
                ),
                Slider(
                  value: cgpa,
                  min: 0,
                  max: 10,
                  divisions: 20,
                  onChanged: onCgpa,
                  activeColor: AppColors.primary,
                  inactiveColor: AppColors.border,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('0',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                    Text(_cgpaLabel,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600)),
                    const Text('10',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 6 — Skills & Tools ─────────────────────────────────
class _Step6Skills extends StatelessWidget {
  final List<String> skills;
  final List<String> tools;
  final TextEditingController customSkillCtrl;
  final TextEditingController customToolCtrl;
  final VoidCallback onChanged;

  const _Step6Skills({
    required this.skills,
    required this.tools,
    required this.customSkillCtrl,
    required this.customToolCtrl,
    required this.onChanged,
  });

  static const _skillList = [
    'Flutter', 'Java', 'Python', 'React', 'JavaScript',
    'C/C++', 'SQL', 'Node.js/Express', 'TypeScript', 'Kotlin',
    'Swift', 'PHP', 'Ruby', 'Go', 'Rust', 'MATLAB',
  ];

  static const _toolList = [
    'Git/Github', 'Docker', 'AWS', 'Linux',
    'Kubernetes', 'Jenkins', 'Figma', 'Postman', 'Firebase',
  ];

  void _toggle(List<String> list, String item) {
    if (list.contains(item)) {
      list.remove(item);
    } else {
      list.add(item);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 6 · SKILLS',
      title: 'Your Skills\n& Tools',
      subtitle: 'Select skills and tools you\'re comfortable with. This is the key to accurate matching.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary badges
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${skills.length} skills selected',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600)),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${tools.length} tools selected',
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          const Text('Programming Languages & Frameworks',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skillList
                .map((s) => SelectableChip(
                      label: s,
                      isSelected: skills.contains(s),
                      onTap: () => _toggle(skills, s),
                    ))
                .toList(),
          ),

          // Custom skill input
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customSkillCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add custom skill...',
                    hintStyle:
                        const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty && !skills.contains(v.trim())) {
                      skills.add(v.trim());
                      customSkillCtrl.clear();
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final v = customSkillCtrl.text.trim();
                  if (v.isNotEmpty && !skills.contains(v)) {
                    skills.add(v);
                    customSkillCtrl.clear();
                    onChanged();
                  }
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          const Text('Tools & Platforms',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _toolList
                .map((t) => SelectableChip(
                      label: t,
                      isSelected: tools.contains(t),
                      onTap: () => _toggle(tools, t),
                    ))
                .toList(),
          ),

          // Custom tool input
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: customToolCtrl,
                  style: const TextStyle(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Add custom tool...',
                    hintStyle:
                        const TextStyle(fontSize: 13, color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide:
                          const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    filled: true,
                    fillColor: AppColors.surface,
                  ),
                  onSubmitted: (v) {
                    if (v.trim().isNotEmpty && !tools.contains(v.trim())) {
                      tools.add(v.trim());
                      customToolCtrl.clear();
                      onChanged();
                    }
                  },
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  final v = customToolCtrl.text.trim();
                  if (v.isNotEmpty && !tools.contains(v)) {
                    tools.add(v);
                    customToolCtrl.clear();
                    onChanged();
                  }
                },
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      const Icon(Icons.add, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 7 — Interests ───────────────────────────────────────
class _Step7Interests extends StatelessWidget {
  final List<String> selected;
  final VoidCallback onChanged;

  const _Step7Interests(
      {required this.selected, required this.onChanged});

  static const _interests = [
    ('Web Dev', Icons.web_outlined, Color(0xFF8B5CF6)),
    ('App Dev', Icons.smartphone_outlined, Color(0xFF06B6D4)),
    ('Data Science', Icons.analytics_outlined, Color(0xFF0EA5E9)),
    ('AI/ML', Icons.psychology_outlined, Color(0xFF22C55E)),
    ('Cybersecurity', Icons.security_outlined, Color(0xFFEF4444)),
    ('Cloud Computing', Icons.cloud_outlined, Color(0xFFF59E0B)),
    ('DevOps', Icons.settings_outlined, Color(0xFF64748B)),
    ('Blockchain', Icons.link_outlined, Color(0xFF6366F1)),
    ('UI/UX Design', Icons.design_services_outlined, Color(0xFFEC4899)),
    ('IoT', Icons.device_hub_outlined, Color(0xFF10B981)),
  ];

  void _toggle(String item) {
    if (selected.contains(item)) {
      selected.remove(item);
    } else {
      selected.add(item);
    }
    onChanged();
  }

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 7 · INTERESTS',
      title: 'Your Interests',
      subtitle: "Choose the domains you're passionate about. Select multiple!",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selected.isNotEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.primary.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle,
                      color: AppColors.primary, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${selected.length} selected: ${selected.join(', ')}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.5,
            children: _interests
                .map((item) => InterestCard(
                      title: item.$1,
                      icon: item.$2,
                      color: item.$3,
                      isSelected: selected.contains(item.$1),
                      onTap: () => _toggle(item.$1),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ─── Step 8 — Preferences ────────────────────────────────────
class _Step8Preferences extends StatelessWidget {
  final String? locPref;
  final String? typePref;
  final String? durationPref;
  final ValueChanged<String> onLoc;
  final ValueChanged<String> onType;
  final ValueChanged<String> onDuration;

  const _Step8Preferences({
    this.locPref,
    this.typePref,
    this.durationPref,
    required this.onLoc,
    required this.onType,
    required this.onDuration,
  });

  @override
  Widget build(BuildContext context) {
    return _StepWrapper(
      step: 'STEP 8 · PREFERENCES',
      title: 'Your\nPreferences',
      subtitle: 'Help us find opportunities that fit your lifestyle.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PrefSection(
            label: 'PREFERRED LOCATION',
            options: const ['Remote', 'On-site', 'Hybrid'],
            selected: locPref,
            icons: const [
              Icons.wifi_outlined,
              Icons.business_outlined,
              Icons.blur_on_outlined,
            ],
            onSelect: onLoc,
          ),
          const SizedBox(height: 20),
          _PrefSection(
            label: 'INTERNSHIP TYPE',
            options: const ['Full-time', 'Part-time'],
            selected: typePref,
            icons: const [
              Icons.work_outline,
              Icons.work_history_outlined,
            ],
            onSelect: onType,
          ),
          const SizedBox(height: 20),
          _PrefSection(
            label: 'DURATION',
            options: const ['1 month', '3 months', '6 months', '1 year'],
            selected: durationPref,
            icons: const [
              Icons.calendar_month_outlined,
              Icons.calendar_month_outlined,
              Icons.calendar_month_outlined,
              Icons.calendar_month_outlined,
            ],
            onSelect: onDuration,
          ),
        ],
      ),
    );
  }
}

class _PrefSection extends StatelessWidget {
  final String label;
  final List<String> options;
  final String? selected;
  final List<IconData> icons;
  final ValueChanged<String> onSelect;

  const _PrefSection({
    required this.label,
    required this.options,
    this.selected,
    required this.icons,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                letterSpacing: 0.8)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(options.length, (i) {
            final opt = options[i];
            final isSel = selected == opt;
            return GestureDetector(
              onTap: () => onSelect(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSel ? AppColors.primary : AppColors.border,
                    width: isSel ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icons[i],
                        size: 16,
                        color: isSel ? Colors.white : AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(opt,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color:
                              isSel ? Colors.white : AppColors.textPrimary,
                        )),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Step Wrapper — shared layout ────────────────────────────
class _StepWrapper extends StatelessWidget {
  final String step;
  final String title;
  final String subtitle;
  final Widget child;

  const _StepWrapper({
    required this.step,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(step,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
                letterSpacing: 1.2,
              )),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                height: 1.15,
              )),
          const SizedBox(height: 10),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.4)),
          const SizedBox(height: 24),
          child,
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05, end: 0, duration: 300.ms);
  }
}
