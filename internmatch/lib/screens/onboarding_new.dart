import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';

class OnboardingScreenNew extends StatefulWidget {
  const OnboardingScreenNew({super.key});

  @override
  State<OnboardingScreenNew> createState() => _OnboardingScreenNewState();
}

class _OnboardingScreenNewState extends State<OnboardingScreenNew> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _collegeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _degree;
  String? _yearOfStudy;
  final TextEditingController _cgpaController = TextEditingController();
  final List<String> _skills = [];
  final List<String> _interests = [];
  String? _preferredLocation;
  String? _preferredType;
  String? _availability;
  final TextEditingController _portfolioController = TextEditingController();

  static const int _stepCount = 11;

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _nameController.text.isNotEmpty &&
            _collegeController.text.isNotEmpty &&
            _phoneController.text.isNotEmpty;
      case 1:
        return _degree != null && _yearOfStudy != null;
      case 2:
        return _skills.isNotEmpty;
      case 3:
        return _interests.isNotEmpty;
      case 4:
        return _preferredLocation != null;
      case 5:
        return _preferredType != null;
      case 6:
        return _availability != null && _availability!.isNotEmpty;
      case 7:
      case 8:
      case 9:
      case 10:
        return true;
      default:
        return false;
    }
  }

  Future<void> _goNext() async {
    if (_currentStep < _stepCount - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _completeOnboarding();
    }
  }

  Future<void> _completeOnboarding() async {
    final storage = await StorageService.getInstance();
    await storage.setOnboardingDone();
    if (!mounted) return;
    context.go(AppRoutes.mainShell);
  }

  void _goPrevious() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _collegeController.dispose();
    _phoneController.dispose();
    _cgpaController.dispose();
    _portfolioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentStep > 0) {
          _goPrevious();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          minHeight: 8,
                          value: (_currentStep + 1) / _stepCount,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentStep = index),
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildIntroStep(context),
                    _buildAcademicStep(context),
                    _buildSkillsStep(context),
                    _buildInterestsStep(context),
                    _buildLocationStep(context),
                    _buildTypeStep(context),
                    _buildAvailabilityStep(context),
                    _buildPortfolioStep(context),
                    _buildReviewStep(context),
                    _buildFinishStep(context),
                    _buildSuccessStep(context),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: Row(
                  children: [
                    if (_currentStep > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _goPrevious,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textPrimary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Back'),
                        ),
                      ),
                    if (_currentStep > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _canContinue ? _goNext : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          _currentStep == _stepCount - 1 ? 'Finish Setup' : 'Continue',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pageHeader(BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildIntroStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Tell us about you',
            'We’ll tailor internship matches to your profile.',
          ),
          _buildTextField('Full Name', _nameController),
          const SizedBox(height: 16),
          _buildTextField('College / University', _collegeController),
          const SizedBox(height: 16),
          _buildTextField('Phone number', _phoneController,
              keyboardType: TextInputType.phone),
        ],
      ),
    );
  }

  Widget _buildAcademicStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Academic profile',
            'Your degree and year help us match the right internships.',
          ),
          _buildDropdown(
            label: 'Degree / Program',
            value: _degree,
            options: ['B.Tech', 'B.Sc', 'BE', 'BCA', 'MBA', 'MSc'],
            onChanged: (value) => setState(() => _degree = value),
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Current Year',
            value: _yearOfStudy,
            options: ['1st Year', '2nd Year', '3rd Year', '4th Year', 'Graduated'],
            onChanged: (value) => setState(() => _yearOfStudy = value),
          ),
          const SizedBox(height: 16),
          _buildTextField('CGPA (Optional)', _cgpaController,
              keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildSkillsStep(BuildContext context) {
    const availableSkills = [
      'Python',
      'JavaScript',
      'Flutter',
      'UI/UX',
      'Machine Learning',
      'Data Analysis',
      'Backend',
      'Product',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Select your skills',
            'Choose the abilities that describe you best.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableSkills.map((skill) {
              final selected = _skills.contains(skill);
              return ChoiceChip(
                label: Text(skill),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _skills.remove(skill);
                    } else {
                      _skills.add(skill);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.14),
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsStep(BuildContext context) {
    const availableInterests = [
      'Fintech',
      'Healthtech',
      'Edtech',
      'SaaS',
      'E-commerce',
      'Gaming',
      'AI / ML',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Pick your interests',
            'Tell us which internship sectors excite you.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: availableInterests.map((interest) {
              final selected = _interests.contains(interest);
              return ChoiceChip(
                label: Text(interest),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    if (selected) {
                      _interests.remove(interest);
                    } else {
                      _interests.add(interest);
                    }
                  });
                },
                selectedColor: AppColors.tertiary.withOpacity(0.14),
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: TextStyle(
                  color: selected ? AppColors.tertiary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStep(BuildContext context) {
    const locations = ['Remote', 'Hybrid', 'On-site'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Location preference',
            'Where would you like to work?',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: locations.map((location) {
              final selected = _preferredLocation == location;
              return ChoiceChip(
                label: Text(location),
                selected: selected,
                onSelected: (_) => setState(() => _preferredLocation = location),
                selectedColor: AppColors.primary.withOpacity(0.14),
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeStep(BuildContext context) {
    const types = ['Full-time', 'Part-time', 'Flexible'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Work style',
            'Choose the internship type you prefer.',
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: types.map((type) {
              final selected = _preferredType == type;
              return ChoiceChip(
                label: Text(type),
                selected: selected,
                onSelected: (_) => setState(() => _preferredType = type),
                selectedColor: AppColors.primary.withOpacity(0.14),
                backgroundColor: AppColors.surfaceElevated,
                labelStyle: TextStyle(
                  color: selected ? AppColors.primary : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityStep(BuildContext context) {
    const availabilityOptions = ['ASAP', 'In 1 month', 'In 3 months'];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Availability',
            'When can you begin your next internship?',
          ),
          Column(
            children: availabilityOptions.map((option) {
              return RadioListTile<String>(
                title: Text(option),
                value: option,
                groupValue: _availability,
                activeColor: AppColors.primary,
                onChanged: (value) => setState(() => _availability = value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPortfolioStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Portfolio links',
            'Add a resume or portfolio link if you have one.',
          ),
          _buildTextField('Portfolio / GitHub / LinkedIn', _portfolioController,
              keyboardType: TextInputType.url),
        ],
      ),
    );
  }

  Widget _buildReviewStep(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _pageHeader(
            context,
            'Review your profile',
            'Check your selections before we finish setup.',
          ),
          _buildReviewTile('Name', _nameController.text),
          _buildReviewTile('College', _collegeController.text),
          _buildReviewTile('Phone', _phoneController.text),
          _buildReviewTile('Degree', _degree ?? '-'),
          _buildReviewTile('Year', _yearOfStudy ?? '-'),
          _buildReviewTile('Skills', _skills.isNotEmpty ? _skills.join(', ') : '-'),
          _buildReviewTile('Interests', _interests.isNotEmpty ? _interests.join(', ') : '-'),
          _buildReviewTile('Location', _preferredLocation ?? '-'),
          _buildReviewTile('Type', _preferredType ?? '-'),
          _buildReviewTile('Availability', _availability ?? '-'),
          _buildReviewTile('Portfolio', _portfolioController.text.isNotEmpty ? _portfolioController.text : 'Not provided'),
        ],
      ),
    );
  }

  Widget _buildFinishStep(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'You’re all set!',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'We will use this information to surface the best internships for your profile.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle_outline, size: 56, color: AppColors.tertiary),
                const SizedBox(height: 16),
                Text(
                  'Profile saved successfully',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rocket_launch, size: 88, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              'You’re ready to discover internships!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Tap Finish Setup to land on your dashboard and see the best matches.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: label,
            fillColor: AppColors.surface,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map((option) => DropdownMenuItem(value: option, child: Text(option)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewTile(String title, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
