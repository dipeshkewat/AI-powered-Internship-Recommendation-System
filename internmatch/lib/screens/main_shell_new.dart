import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';

class MainShellNew extends StatefulWidget {
  const MainShellNew({super.key});

  @override
  State<MainShellNew> createState() => _MainShellNewState();
}

class _MainShellNewState extends State<MainShellNew> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          // Home screen (Dashboard)
          _buildNavigationContent(0),
          // Search screen
          _buildNavigationContent(1),
          // Bookmarks screen
          _buildNavigationContent(2),
          // Applications screen
          _buildNavigationContent(3),
          // Profile screen
          _buildNavigationContent(4),
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
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textMuted,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment_outlined),
              activeIcon: Icon(Icons.assignment),
              label: 'Applied',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationContent(int index) {
    switch (index) {
      case 0:
        return const DashboardScreenNew();
      case 1:
        return const SearchScreenNew();
      case 2:
        return const BookmarksScreenNew();
      case 3:
        return const ApplicationsScreenNew();
      case 4:
        return const ProfileScreenNew();
      default:
        return const SizedBox.shrink();
    }
  }
}

// Dashboard Screen
class DashboardScreenNew extends ConsumerWidget {
  const DashboardScreenNew({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    final userName = profile.name.split(' ').first;
    final avatarInitial = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';
    
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: isMobile ? 45 : 50,
                    height: isMobile ? 45 : 50,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        avatarInitial,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
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
                          'Good evening, $userName 👋',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 16 : 18,
                          ),
                        ),
                        Text(
                          '1 Application - 0 Saved',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: isMobile ? 12 : 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search internships, companies...',
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Stats
              Row(
                children: [
                  const Expanded(
                    child: _StatCard(title: '1', subtitle: 'Applications'),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  const Expanded(
                    child: _StatCard(title: '0', subtitle: 'Saved'),
                  ),
                  SizedBox(width: isMobile ? 8 : 12),
                  const Expanded(
                    child: _StatCard(title: '85%', subtitle: 'Match Rate'),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // AI Recommendations
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'AI-Powered',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: isMobile ? 14 : 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Find Your Best Matches',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: isMobile ? 18 : 20,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Our ML model analyzes your profile to find the top internships for you.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Loading recommendations...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                      ),
                      child: Text(
                        '✨ Get Recommendations →',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.primary,
                          fontSize: isMobile ? 13 : 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Trending Now
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Trending Now',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                  Text(
                    'See all',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _InternshipCard(
                internshipId: 'google-frontend',
                company: 'Google',
                title: 'Frontend Developer Intern',
                salary: '₹30,000/month',
                location: 'Bangalore - Remote',
                skills: ['React', 'JavaScript', 'CSS'],
              ),
              const SizedBox(height: 12),
              const _InternshipCard(
                internshipId: 'microsoft-ml',
                company: 'Microsoft',
                title: 'Machine Learning Intern',
                salary: '₹40,000/month',
                location: 'Hyderabad - On-site',
                skills: ['Python', 'Machine Learning', 'SQL'],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Search Screen
class SearchScreenNew extends StatelessWidget {
  const SearchScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Explore Internships',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: 'Search by role, company, or skill...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'All'),
                      SizedBox(width: 8),
                      _FilterChip(label: 'Remote', isSelected: true),
                      SizedBox(width: 8),
                      _FilterChip(label: 'On-site'),
                      SizedBox(width: 8),
                      _FilterChip(label: 'Hybrid'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 5,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _InternshipCard(
                  internshipId: index.isEven ? 'google-frontend' : 'microsoft-ml',
                  company: index.isEven ? 'Google' : 'Microsoft',
                  title: index.isEven ? 'Frontend Developer Intern' : 'ML Engineer Intern',
                  salary: index.isEven ? '₹30,000/month' : '₹40,000/month',
                  location: index.isEven ? 'Bangalore - Remote' : 'Hyderabad - On-site',
                  skills: index.isEven
                      ? ['React', 'JavaScript', 'CSS']
                      : ['Python', 'ML', 'SQL'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Bookmarks Screen
class BookmarksScreenNew extends StatelessWidget {
  const BookmarksScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saved Internships',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '2 internships bookmarked',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: const [
                  _InternshipCard(
                    internshipId: 'google-frontend',
                    company: 'Google',
                    title: 'Frontend Developer Intern',
                    salary: '₹30,000/month',
                    location: 'Bangalore - Remote',
                    skills: ['React', 'JavaScript', 'CSS'],
                  ),
                  SizedBox(height: 12),
                  _InternshipCard(
                    internshipId: 'amazon-data',
                    company: 'Amazon',
                    title: 'Data Science Intern',
                    salary: '₹50,000/month',
                    location: 'Remote',
                    skills: ['Python', 'SQL', 'Data Analysis'],
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

// Applications Screen
class ApplicationsScreenNew extends StatelessWidget {
  const ApplicationsScreenNew({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'My Applications',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _AppStatusBox(count: '0', label: 'Applied'),
                  _AppStatusBox(count: '1', label: 'Under Review'),
                  _AppStatusBox(count: '0', label: 'Shortlisted'),
                  _AppStatusBox(count: '0', label: 'Rejected'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
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
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: const Color(0xFF4285F4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Center(
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
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
                                    'Machine Learning Intern',
                                    style: Theme.of(context).textTheme.titleSmall,
                                  ),
                                  Text(
                                    'Microsoft',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF3C7),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                '⏳ Under Review',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Applied on Apr 3, 2026',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
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

// Profile Screen
class ProfileScreenNew extends ConsumerWidget {
  const ProfileScreenNew({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 600;
    
    // Generate avatar initials
    final names = profile.name.split(' ');
    final avatarInitial = names.length > 1 
        ? '${names[0][0]}${names[1][0]}' 
        : names[0].isNotEmpty ? names[0][0] : 'U';
    
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                ),
              ),
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                children: [
                  Container(
                    width: isMobile ? 70 : 80,
                    height: isMobile ? 70 : 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        avatarInitial.toUpperCase(),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 24 : 28,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.name.isNotEmpty ? profile.name : 'User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 20 : 24,
                    ),
                  ),
                  Text(
                    profile.degree.isNotEmpty 
                        ? profile.degree 
                        : 'Not specified',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: const LinearProgressIndicator(
                      minHeight: 8,
                      value: 0.75,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Profile Completion: 75%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ProfileStatBox(count: '1', label: 'Applied'),
                      _ProfileStatBox(count: '0', label: 'Saved'),
                      _ProfileStatBox(count: '24', label: 'Matches'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _ProfileSection(
                    title: 'Personal Info',
                    children: [
                      _ProfileItem(
                        label: 'Email',
                        value: profile.email.isNotEmpty 
                            ? profile.email 
                            : 'Not provided',
                      ),
                      _ProfileItem(
                        label: 'Phone',
                        value: profile.phone.isNotEmpty 
                            ? profile.phone 
                            : 'Not provided',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _ProfileSection(
                    title: 'Academic Details',
                    children: [
                      _ProfileItem(
                        label: 'Degree',
                        value: profile.degree.isNotEmpty 
                            ? profile.degree 
                            : 'Not specified',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (profile.skills.isNotEmpty)
                    _ProfileSection(
                      title: 'Skills',
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.skills
                              .map((skill) => Chip(
                            label: Text(skill),
                            backgroundColor: AppColors.primary.withOpacity(0.1),
                            side: const BorderSide(color: AppColors.primary),
                          ))
                              .toList(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: isMobile ? 48 : 56,
                    child: ElevatedButton(
                      onPressed: () async {
                        await ref.read(authProvider.notifier).logout();
                        context.go(AppRoutes.welcome);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      child: Text(
                        '← Logout',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white,
                          fontSize: isMobile ? 14 : 16,
                        ),
                      ),
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

// Helper Widgets
class _StatCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const _StatCard({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InternshipCard extends StatefulWidget {
  final String internshipId;
  final String company;
  final String title;
  final String salary;
  final String location;
  final List<String> skills;

  const _InternshipCard({
    required this.internshipId,
    required this.company,
    required this.title,
    required this.salary,
    required this.location,
    required this.skills,
  });

  @override
  State<_InternshipCard> createState() => _InternshipCardState();
}

class _InternshipCardState extends State<_InternshipCard> {
  bool _isSaved = false;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    widget.company[0],
                    style: const TextStyle(
                      color: Colors.white,
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
                      widget.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.company,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  _isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  color: _isSaved ? AppColors.primary : AppColors.textSecondary,
                ),
                onPressed: () {
                  setState(() => _isSaved = !_isSaved);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isSaved ? 'Added to saved' : 'Removed from saved',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            children: widget.skills
                .map((skill) => Chip(
              label: Text(skill),
              backgroundColor: AppColors.primary.withOpacity(0.1),
              side: BorderSide.none,
              labelStyle: const TextStyle(color: AppColors.primary, fontSize: 11),
              padding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.salary,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    widget.location,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Applied to ${widget.company}'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  context.go('${AppRoutes.mainShell}/internship/${widget.internshipId}');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text(
                  'Apply',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const _FilterChip({
    required this.label,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: isSelected ? AppColors.primary : Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.border,
      ),
    );
  }
}

class _AppStatusBox extends StatelessWidget {
  final String count;
  final String label;

  const _AppStatusBox({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ProfileStatBox extends StatelessWidget {
  final String count;
  final String label;

  const _ProfileStatBox({
    required this.count,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ProfileSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _ProfileItem extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
