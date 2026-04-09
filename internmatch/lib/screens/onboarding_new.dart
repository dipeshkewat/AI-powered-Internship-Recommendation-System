import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class OnboardingScreenNew extends StatefulWidget {
  const OnboardingScreenNew({Key? key}) : super(key: key);

  @override
  State<OnboardingScreenNew> createState() => _OnboardingScreenNewState();
}

class _OnboardingScreenNewState extends State<OnboardingScreenNew> {
  int _currentStep = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: _currentStep > 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.textPrimary,
                  onPressed: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                )
              : null,
          title: Text(
            'Step ${_currentStep + 1}/5',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  value: (_currentStep + 1) / 5,
                  backgroundColor: AppColors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentStep = index);
                },
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _BasicInfoStep(pageController: _pageController),
                  _AcademicStep(pageController: _pageController),
                  _SkillsStep(pageController: _pageController),
                  _InterestsStep(pageController: _pageController),
                  _PreferencesStep(pageController: _pageController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Step 1: Basic Info
class _BasicInfoStep extends StatefulWidget {
  final PageController pageController;

  const _BasicInfoStep({required this.pageController});

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  final _nameController = TextEditingController();
  final _collegeController = TextEditingController();
  final _phoneController = TextEditingController();

  bool get _isValid => _nameController.text.isNotEmpty &&
      _collegeController.text.isNotEmpty &&
      _phoneController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Let\'s start with basics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Help us learn more about you',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          _buildTextField('Full Name', _nameController),
          const SizedBox(height: 16),
          _buildTextField('College Name', _collegeController),
          const SizedBox(height: 16),
          _buildTextField('Phone Number', _phoneController,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid
                  ? () {
                      widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
            ),
            contentPadding: const EdgeInsets.all(16),
            hintText: 'Enter $label',
          ),
        ),
      ],
    );
  }
}

// Step 2: Academic
class _AcademicStep extends StatefulWidget {
  final PageController pageController;

  const _AcademicStep({required this.pageController});

  @override
  State<_AcademicStep> createState() => _AcademicStepState();
}

class _AcademicStepState extends State<_AcademicStep> {
  String? _degree;
  String? _yearOfStudy;
  final _cgpaController = TextEditingController();

  bool get _isValid => _degree != null && _yearOfStudy != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Academic Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tell us about your academic qualification',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Text('Degree/Program', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _degree,
            items: ['B.Tech', 'B.Sc', 'BE', 'BCA', 'MBA', 'MSc']
                .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                .toList(),
            onChanged: (value) => setState(() => _degree = value),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Text('Current Year', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _yearOfStudy,
            items: ['1st Year', '2nd Year', '3rd Year', '4th Year', 'Graduated']
                .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                .toList(),
            onChanged: (value) => setState(() => _yearOfStudy = value),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
          const SizedBox(height: 16),
          Text('CGPA (Optional)', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          TextField(
            controller: _cgpaController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.all(16),
              hintText: '3.5',
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid
                  ? () {
                      widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// Step 3: Skills
class _SkillsStep extends StatefulWidget {
  final PageController pageController;

  const _SkillsStep({required this.pageController});

  @override
  State<_SkillsStep> createState() => _SkillsStepState();
}

class _SkillsStepState extends State<_SkillsStep> {
  final Set<String> _selectedSkills = {};
  final List<String> _allSkills = [
    'Python', 'JavaScript', 'React', 'Django', 'FastAPI',
    'SQL', 'MongoDB', 'Git', 'AWS', 'Docker',
    'Java', 'C++', 'Data Analysis', 'Machine Learning', 'UI/UX'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Skills',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the skills you have (select at least 1)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSkills
                .map((skill) => FilterChip(
              label: Text(skill),
              selected: _selectedSkills.contains(skill),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedSkills.add(skill);
                  } else {
                    _selectedSkills.remove(skill);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
            ))
                .toList(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedSkills.isNotEmpty
                  ? () {
                      widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// Step 4: Interests
class _InterestsStep extends StatefulWidget {
  final PageController pageController;

  const _InterestsStep({required this.pageController});

  @override
  State<_InterestsStep> createState() => _InterestsStepState();
}

class _InterestsStepState extends State<_InterestsStep> {
  final Set<String> _selectedInterests = {};
  final List<String> _allInterests = [
    'Web Development', 'Mobile Development', 'Machine Learning',
    'Cloud Computing', 'Data Science', 'DevOps',
    'Cybersecurity', 'Blockchain', 'AI/NLP', 'IoT'
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Areas of Interest',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'What interests you the most? (select at least 1)',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allInterests
                .map((interest) => FilterChip(
              label: Text(interest),
              selected: _selectedInterests.contains(interest),
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedInterests.add(interest);
                  } else {
                    _selectedInterests.remove(interest);
                  }
                });
              },
              selectedColor: AppColors.tertiary.withOpacity(0.2),
              checkmarkColor: AppColors.tertiary,
            ))
                .toList(),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedInterests.isNotEmpty
                  ? () {
                      widget.pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tertiary,
              ),
              child: const Text('Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

// Step 5: Preferences
class _PreferencesStep extends StatefulWidget {
  final PageController pageController;

  const _PreferencesStep({required this.pageController});

  @override
  State<_PreferencesStep> createState() => _PreferencesStepState();
}

class _PreferencesStepState extends State<_PreferencesStep> {
  String? _locationType;
  String? _workArrangement;

  bool get _isValid => _locationType != null && _workArrangement != null;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Work Preferences',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How would you like to work?',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Text('Work Location', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ..._buildLocationOptions(),
          const SizedBox(height: 24),
          Text('Work Arrangement', style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ..._buildArrangementOptions(),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid
                  ? () {
                      // Complete onboarding - navigate to main shell
                      context.go('/main-shell');
                    }
                  : null,
              child: const Text('Complete Profile'),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLocationOptions() {
    return ['Remote', 'On-site', 'Hybrid']
        .map((location) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioListTile<String>(
            value: location,
            groupValue: _locationType,
            onChanged: (value) => setState(() => _locationType = value),
            title: Text(location),
            contentPadding: EdgeInsets.zero,
          ),
        ))
        .toList();
  }

  List<Widget> _buildArrangementOptions() {
    return ['Full-time', 'Part-time', 'Flexible']
        .map((arrangement) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: RadioListTile<String>(
            value: arrangement,
            groupValue: _workArrangement,
            onChanged: (value) => setState(() => _workArrangement = value),
            title: Text(arrangement),
            contentPadding: EdgeInsets.zero,
          ),
        ))
        .toList();
  }
}
