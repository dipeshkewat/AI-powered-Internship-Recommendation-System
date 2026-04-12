// ============================================================
// MAIN SHELL — Bottom nav with 5 tabs
// Dashboard, Search, Saved, Applied, Profile
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/internships_data.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_router.dart';
import '../widgets/app_components.dart';

class MainShell extends ConsumerStatefulWidget {
  final int initialTab;
  const MainShell({super.key, this.initialTab = 0});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  late int _tab;

  @override
  void initState() {
    super.initState();
    _tab = widget.initialTab;
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _tab = widget.initialTab;
    }
  }

  static const _navItems = [
    BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
    BottomNavigationBarItem(
        icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search), label: 'Search'),
    BottomNavigationBarItem(
        icon: Icon(Icons.bookmark_outline),
        activeIcon: Icon(Icons.bookmark),
        label: 'Saved'),
    BottomNavigationBarItem(
        icon: Icon(Icons.assignment_outlined),
        activeIcon: Icon(Icons.assignment),
        label: 'Applied'),
    BottomNavigationBarItem(
        icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final unread = user.notifications.where((n) => !n.read).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _tab,
        children: [
          DashboardTab(onTabChange: (i) => setState(() => _tab = i)),
          const SearchTab(),
          const SavedTab(),
          const AppliedTab(),
          const ProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: BottomNavigationBar(
              currentIndex: _tab,
              onTap: (i) => setState(() => _tab = i),
              items: _navItems,
              backgroundColor: AppColors.surface,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textMuted,
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              selectedLabelStyle: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600),
              unselectedLabelStyle:
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DASHBOARD TAB
// ============================================================
class DashboardTab extends ConsumerStatefulWidget {
  final ValueChanged<int> onTabChange;
  const DashboardTab({super.key, required this.onTabChange});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {
  String _filter = 'All';
  static const _filters = ['All', 'Web Dev', 'App Dev', 'AI/ML', 'Data Science', 'DevOps'];

  List<Internship> get _filteredData => _filter == 'All'
      ? internshipData
      : internshipData.where((i) => i.domain == _filter).toList();

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final firstName = user.fullName.isNotEmpty
        ? user.fullName.split(' ').first
        : user.email.split('@').first;
    final initial = firstName.isNotEmpty ? firstName[0].toUpperCase() : 'U';
    final unread = user.notifications.where((n) => !n.read).length;

    return CustomScrollView(
      slivers: [
        // ── Hero header ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2B3BF7), Color(0xFF1A2AD4)],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  children: [
                    // Top bar: avatar + bell
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(initial,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Good ${_greeting()}, ',
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 13),
                                  ),
                                  const Text('🌟',
                                      style: TextStyle(fontSize: 13)),
                                ],
                              ),
                              Text(
                                firstName,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.notifications_outlined,
                                  color: Colors.white, size: 20),
                            ),
                            if (unread > 0)
                              Positioned(
                                right: 6,
                                top: 6,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: AppColors.primary, width: 2),
                                  ),
                                  child: Center(
                                    child: Text('$unread',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700)),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Search bar
                    Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search,
                              color: Colors.white.withOpacity(0.6),
                              size: 18),
                          const SizedBox(width: 10),
                          Text('Search internships, companies...',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 14)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Stats row
                    Row(
                      children: [
                        StatCard(
                          value: '${user.appliedInternships.length}',
                          label: 'Applications',
                        ),
                        const SizedBox(width: 8),
                        StatCard(
                          value: '${user.savedInternships.length}',
                          label: 'Saved',
                        ),
                        const SizedBox(width: 8),
                        const StatCard(
                          value: '85%',
                          label: 'Match Rate',
                          textColor: Color(0xFF7DF5A0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // ── Content ──────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // AI Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A2AD4), Color(0xFF2B3BF7)],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Row(
                                  children: [
                                    Icon(Icons.auto_awesome,
                                        color: Color(0xFF7DF5A0), size: 12),
                                    SizedBox(width: 4),
                                    Text('AI-Powered · Random Forest ML',
                                        style: TextStyle(
                                            color: Color(0xFF7DF5A0),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text('Find Your Best\nMatches',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2)),
                          const SizedBox(height: 6),
                          Text(
                            'Our ML model analyzes your profile to find top internships personalized for you.',
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.75),
                                fontSize: 12,
                                height: 1.4),
                          ),
                          const SizedBox(height: 14),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.onboarding),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.settings_outlined,
                                      color: Colors.white, size: 14),
                                  SizedBox(width: 6),
                                  Text('Get Recommendations →',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(Icons.arrow_forward,
                        color: Colors.white.withOpacity(0.2), size: 48),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),

              const SizedBox(height: 24),

              // Trending Now
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🔥  Trending Now',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See all →',
                        style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                ],
              ),

              SizedBox(
                height: 180,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: internshipData.take(5).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, i) {
                    final item = internshipData[i];
                    final color = _logoColor(item.logoColor);
                    return TrendingCard(
                      title: item.title,
                      company: item.company,
                      companyInitial: item.companyInitial,
                      logoColor: color,
                      stipend: item.stipend,
                      locationType: item.locationType,
                      duration: item.duration,
                    ).animate().fadeIn(delay: (i * 80).ms);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Browse by Category header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Browse by Category',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary)),
                  Text('${_filteredData.length} results',
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.textSecondary)),
                ],
              ),

              const SizedBox(height: 12),

              // Category filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((f) {
                    final isSel = _filter == f;
                    return GestureDetector(
                      onTap: () => setState(() => _filter = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? AppColors.primary : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel ? AppColors.primary : AppColors.border,
                          ),
                        ),
                        child: Text(f,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isSel
                                    ? Colors.white
                                    : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 16),

              // Internship list
              ..._filteredData.map((item) {
                final user2 = ref.watch(userProvider);
                final isSaved =
                    user2.savedInternships.contains(item.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InternshipCard(
                    id: item.id,
                    title: item.title,
                    company: item.company,
                    companyInitial: item.companyInitial,
                    logoColor: _logoColor(item.logoColor),
                    stipend: item.stipend,
                    location: item.location,
                    locationType: item.locationType,
                    duration: item.duration,
                    skills: item.requiredSkills,
                    matchScore: item.matchScore,
                    isSaved: isSaved,
                    onSave: () {
                      ref
                          .read(userProvider.notifier)
                          .toggleSaveInternship(item.id);
                    },
                    onTap: () {},
                  ).animate().fadeIn(duration: 300.ms),
                );
              }),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ],
    );
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  Color _logoColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }
}

// ============================================================
// SEARCH TAB
// ============================================================
class SearchTab extends ConsumerStatefulWidget {
  const SearchTab({super.key});

  @override
  ConsumerState<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends ConsumerState<SearchTab> {
  final _ctrl = TextEditingController();
  String _query = '';
  String _filter = 'All';

  static const _filters = ['All', 'Web Dev', 'App Dev', 'AI/ML', 'Remote', 'On-site'];

  List<Internship> get _results {
    return internshipData.where((i) {
      final matchQ = _query.isEmpty ||
          i.title.toLowerCase().contains(_query.toLowerCase()) ||
          i.company.toLowerCase().contains(_query.toLowerCase()) ||
          i.requiredSkills
              .any((s) => s.toLowerCase().contains(_query.toLowerCase()));
      final matchF = _filter == 'All' ||
          i.domain == _filter ||
          i.locationType == _filter;
      return matchQ && matchF;
    }).toList();
  }

  Color _logoColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Search',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary)),
                const SizedBox(height: 14),
                // Search bar
                TextField(
                  controller: _ctrl,
                  onChanged: (v) => setState(() => _query = v),
                  style: const TextStyle(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Search internships, companies...',
                    hintStyle: const TextStyle(
                        color: AppColors.textMuted, fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: AppColors.textMuted, size: 20),
                    suffixIcon: _query.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _ctrl.clear();
                              setState(() => _query = '');
                            },
                            child: const Icon(Icons.close,
                                color: AppColors.textMuted, size: 18))
                        : null,
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                          color: AppColors.primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _filters.map((f) {
                      final isSel = _filter == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filter = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSel
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSel
                                  ? AppColors.primary
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(f,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: isSel
                                      ? Colors.white
                                      : AppColors.textSecondary)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Results count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              children: [
                Text('${_results.length} results found',
                    style: const TextStyle(
                        fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),

          // List
          Expanded(
            child: _results.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off_outlined,
                            size: 48, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No results found',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        Text('Try a different search',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                    itemCount: _results.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = _results[i];
                      final isSaved =
                          user.savedInternships.contains(item.id);
                      return InternshipCard(
                        id: item.id,
                        title: item.title,
                        company: item.company,
                        companyInitial: item.companyInitial,
                        logoColor: _logoColor(item.logoColor),
                        stipend: item.stipend,
                        location: item.location,
                        locationType: item.locationType,
                        duration: item.duration,
                        skills: item.requiredSkills,
                        matchScore: item.matchScore,
                        isSaved: isSaved,
                        onSave: () => ref
                            .read(userProvider.notifier)
                            .toggleSaveInternship(item.id),
                      ).animate().fadeIn(delay: (i * 50).ms);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SAVED TAB
// ============================================================
class SavedTab extends ConsumerWidget {
  const SavedTab({super.key});

  Color _logoColor(String hex) {
    try {
      return Color(int.parse(hex.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final saved = internshipData
        .where((i) => user.savedInternships.contains(i.id))
        .toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Saved',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${saved.length}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          saved.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border_outlined,
                            size: 52, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No saved internships',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        Text('Bookmark internships to find them here',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: saved.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final item = saved[i];
                      return InternshipCard(
                        id: item.id,
                        title: item.title,
                        company: item.company,
                        companyInitial: item.companyInitial,
                        logoColor: _logoColor(item.logoColor),
                        stipend: item.stipend,
                        location: item.location,
                        locationType: item.locationType,
                        duration: item.duration,
                        skills: item.requiredSkills,
                        matchScore: item.matchScore,
                        isSaved: true,
                        onSave: () => ref
                            .read(userProvider.notifier)
                            .toggleSaveInternship(item.id),
                      ).animate().fadeIn(delay: (i * 60).ms);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

// ============================================================
// APPLIED TAB
// ============================================================
class AppliedTab extends ConsumerWidget {
  const AppliedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final applied = user.appliedInternships;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                const Expanded(
                  child: Text('Applications',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${applied.length}',
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          applied.isEmpty
              ? const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined,
                            size: 52, color: AppColors.textMuted),
                        SizedBox(height: 12),
                        Text('No applications yet',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary)),
                        Text(
                            'Apply to internships and track them here',
                            style: TextStyle(
                                fontSize: 13, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: applied.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final app = applied[i];
                      return _ApplicationCard(application: app)
                          .animate()
                          .fadeIn(delay: (i * 60).ms);
                    },
                  ),
                ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  final AppliedInternship application;
  const _ApplicationCard({required this.application});

  Color _statusColor(String status) {
    switch (status) {
      case 'Applied':
        return AppColors.info;
      case 'Under Review':
        return AppColors.warning;
      case 'Shortlisted':
        return AppColors.success;
      case 'Rejected':
        return AppColors.error;
      case 'Selected':
        return AppColors.accent;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(application.status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(application.company.substring(0, 1),
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(application.title,
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary)),
                Text(application.company,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text('Applied on ${application.appliedDate}',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textMuted)),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(application.status,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE TAB
// ============================================================
class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final names = user.fullName.split(' ');
    final initials = names.length >= 2
        ? '${names[0][0]}${names[1][0]}'.toUpperCase()
        : user.fullName.isNotEmpty
            ? user.fullName[0].toUpperCase()
            : 'U';

    // Profile completion score
    int score = 0;
    if (user.fullName.isNotEmpty) score += 15;
    if (user.email.isNotEmpty) score += 10;
    if (user.degree.isNotEmpty) score += 15;
    if (user.skills.isNotEmpty) score += 20;
    if (user.interests.isNotEmpty) score += 20;
    if (user.preferredLocation.isNotEmpty) score += 10;
    if (user.phoneNo.isNotEmpty) score += 10;
    final completion = score / 100;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Profile hero
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2B3BF7), Color(0xFF1A2AD4)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
              child: Column(
                children: [
                  Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 2),
                    ),
                    child: Center(
                      child: Text(initials,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName.isNotEmpty ? user.fullName : 'Your Name',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.degree.isNotEmpty ? user.degree : 'Add your degree',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // Completion bar
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Profile Completion',
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12)),
                          Text('${(completion * 100).round()}%',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: completion,
                          minHeight: 6,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF7DF5A0)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ProfileStat(
                          count: '${user.appliedInternships.length}',
                          label: 'Applied'),
                      Container(
                          width: 1, height: 30, color: Colors.white24),
                      _ProfileStat(
                          count: '${user.savedInternships.length}',
                          label: 'Saved'),
                      Container(
                          width: 1, height: 30, color: Colors.white24),
                      const _ProfileStat(count: '24', label: 'Matches'),
                    ],
                  ),
                ],
              ),
            ),

            // Info sections
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _ProfileSection(
                    title: 'Personal Info',
                    icon: Icons.person_outline,
                    children: [
                      _InfoRow(label: 'Email',
                          value: user.email.isNotEmpty
                              ? user.email
                              : 'Not provided'),
                      _InfoRow(label: 'Phone',
                          value: user.phoneNo.isNotEmpty
                              ? user.phoneNo
                              : 'Not provided'),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _ProfileSection(
                    title: 'Academic Details',
                    icon: Icons.school_outlined,
                    children: [
                      _InfoRow(label: 'Degree',
                          value: user.degree.isNotEmpty
                              ? user.degree
                              : 'Not specified'),
                      _InfoRow(label: 'Year',
                          value: user.currentYear.isNotEmpty
                              ? user.currentYear
                              : 'Not specified'),
                      if (user.cgpa.isNotEmpty)
                        _InfoRow(label: 'CGPA', value: user.cgpa),
                    ],
                  ),

                  if (user.skills.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ProfileSection(
                      title: 'Skills & Tools',
                      icon: Icons.code_outlined,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [...user.skills, ...user.tools]
                              .map((s) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.primary
                                              .withOpacity(0.2)),
                                    ),
                                    child: Text(s,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.w500)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ],

                  if (user.interests.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _ProfileSection(
                      title: 'Interests',
                      icon: Icons.favorite_border,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: user.interests
                              .map((i) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: AppColors.accent.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: AppColors.accent.withOpacity(0.2)),
                                    ),
                                    child: Text(i,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.accent,
                                            fontWeight: FontWeight.w500)),
                                  ))
                              .toList(),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 16),
                  
                  _ProfileSection(
                    title: 'Preferences & Experience',
                    icon: Icons.settings_outlined,
                    children: [
                      _InfoRow(label: 'Education', value: user.educationLevel.isNotEmpty ? user.educationLevel : 'Not specified'),
                      _InfoRow(label: 'Experience', value: user.experienceLevel.isNotEmpty ? user.experienceLevel : 'Not specified'),
                      _InfoRow(label: 'Location Pref', value: user.preferredLocation.isNotEmpty ? user.preferredLocation : 'Not specified'),
                      _InfoRow(label: 'Type Pref', value: user.internshipType.isNotEmpty ? user.internshipType : 'Not specified'),
                      _InfoRow(label: 'Duration Pref', value: user.duration.isNotEmpty ? user.duration : 'Not specified'),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Edit Profile
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.onboarding);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Edit Profile',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white)),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Logout
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(userProvider.notifier).logout();
                        context.go(AppRoutes.welcome);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Sign Out',
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String count;
  final String label;
  const _ProfileStat({required this.count, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
        const SizedBox(height: 2),
        Text(label,
            style: TextStyle(
                color: Colors.white.withOpacity(0.7), fontSize: 12)),
      ],
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ProfileSection(
      {required this.title, required this.icon, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }
}
