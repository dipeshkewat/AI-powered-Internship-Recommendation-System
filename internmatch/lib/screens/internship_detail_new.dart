import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class InternshipDetailScreenNew extends StatefulWidget {
  final String internshipId;

  const InternshipDetailScreenNew({
    super.key,
    required this.internshipId,
  });

  @override
  State<InternshipDetailScreenNew> createState() => _InternshipDetailScreenNewState();
}

class _InternshipDetailScreenNewState extends State<InternshipDetailScreenNew> {
  bool _isSaved = false;
  bool _isApplying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppColors.primary,
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () => context.pop(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'G',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Frontend Developer',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Google',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                    color: AppColors.primary,
                  ),
                  onPressed: () => setState(() => _isSaved = !_isSaved),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Info
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _InfoBox(
                        icon: Icons.attach_money,
                        label: '₹30,000/month',
                      ),
                      _InfoBox(
                        icon: Icons.location_on,
                        label: 'Bangalore, India',
                      ),
                      _InfoBox(
                        icon: Icons.calendar_today,
                        label: '3 months',
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // About
                  Text(
                    'About the Internship',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Google is looking for talented frontend developers to help build next-generation web applications. You\'ll work with cutting-edge technologies like React, TypeScript, and CSS-in-JS to create beautiful, performant user interfaces.\n\nThis is a remote internship perfect for students who want to gain real-world experience in web development and work with industry-leading engineers.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Requirements
                  Text(
                    'Requirements',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildRequirements([
                    'Strong knowledge of React and JavaScript/TypeScript',
                    'Good understanding of HTML, CSS, and responsive design',
                    'Experience with Git and version control',
                    'Problem-solving skills and attention to detail',
                    'Excellent communication and teamwork abilities',
                  ]),
                  const SizedBox(height: 28),

                  // Skills Required
                  Text(
                    'Skills Required',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      'React',
                      'JavaScript',
                      'TypeScript',
                      'CSS',
                      'Git',
                      'UI/UX'
                    ]
                        .map((skill) => Chip(
                      label: Text(skill),
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      side: const BorderSide(color: AppColors.primary),
                    ))
                        .toList(),
                  ),
                  const SizedBox(height: 28),

                  // Company Info
                  Text(
                    'About Company',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4285F4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Text(
                                  'G',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Google LLC',
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Mountain View, California',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: AppColors.border),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _CompanyStatBox(
                              icon: Icons.people,
                              label: '156K',
                              subtitle: 'Employees',
                            ),
                            _CompanyStatBox(
                              icon: Icons.business,
                              label: '50+',
                              subtitle: 'Countries',
                            ),
                            _CompanyStatBox(
                              icon: Icons.star,
                              label: '4.8/5',
                              subtitle: 'Rating',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Similar Internships
                  Text(
                    'Similar Internships',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildSimilarInternships(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom: 12 + MediaQuery.of(context).padding.bottom,
        ),
        child: ElevatedButton(
          onPressed: _isApplying
              ? null
              : () {
                  setState(() => _isApplying = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isApplying = false);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Application submitted successfully!'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  });
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.tertiary,
            padding: const EdgeInsets.all(16),
          ),
          child: _isApplying
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(
                  'Apply Now',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  List<Widget> _buildRequirements(List<String> requirements) {
    return requirements
        .map((req) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  req,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ))
        .toList();
  }

  List<Widget> _buildSimilarInternships() {
    return [
      const _SimilarInternshipCard(
        company: 'Microsoft',
        title: 'Web Developer Intern',
        salary: '₹35,000/month',
      ),
      const SizedBox(height: 12),
      const _SimilarInternshipCard(
        company: 'Meta',
        title: 'Frontend Engineer Intern',
        salary: '₹40,000/month',
      ),
    ];
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoBox({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyStatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;

  const _CompanyStatBox({
    required this.icon,
    required this.label,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF6F6F6F)),
        ),
      ],
    );
  }
}

class _SimilarInternshipCard extends StatelessWidget {
  final String company;
  final String title;
  final String salary;

  const _SimilarInternshipCard({
    required this.company,
    required this.title,
    required this.salary,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                company[0],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$company • $salary',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
