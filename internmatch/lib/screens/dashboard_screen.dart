import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import 'internship_detail_screen.dart';
import 'applications_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final recommendations = ref.watch(recommendationProvider);

    final name = profile.name.isNotEmpty ? profile.name.split(' ').first : 'there';
    final topMatches = recommendations.internships
        .where((i) => i.matchScore >= 80)
        .length;
    final bookmarks = ref.watch(bookmarksProvider).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverToBoxAdapter(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $name 👋',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          "Here's your internship dashboard",
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<String>(
                      color: AppColors.surfaceElevated,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.border),
                      ),
                      onSelected: (value) {
                        if (value == 'profile') {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        } else if (value == 'applications') {
                          Navigator.push(context,
                            MaterialPageRoute(builder: (_) => const ApplicationsScreen()));
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(children: [
                            Icon(Icons.person_outline, color: AppColors.textSecondary, size: 16),
                            SizedBox(width: 10),
                            Text('Edit Profile', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'applications',
                          child: Row(children: [
                            Icon(Icons.inbox_outlined, color: AppColors.textSecondary, size: 16),
                            SizedBox(width: 10),
                            Text('My Applications', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                          ]),
                        ),
                      ],
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(duration: 400.ms),
              ),
            ),
          ),

          // Stats row
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: StatTile(
                      label: 'High Matches',
                      value: recommendations.isLoading ? '...' : '$topMatches',
                      icon: Icons.auto_awesome,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: 'Bookmarked',
                      value: '$bookmarks',
                      icon: Icons.bookmark,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: StatTile(
                      label: 'Skills',
                      value: '${profile.skills.length}',
                      icon: Icons.code,
                      color: AppColors.tertiary,
                    ),
                  ),
                ],
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, delay: 150.ms),
            ),
          ),

          // Profile completeness
          if (profile.skills.isEmpty || profile.interests.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _ProfileBanner(),
              ),
            ),

          // Top recommendations preview
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: SectionHeader(
                title: 'Top Picks',
                subtitle: 'Based on your profile',
                trailing: TextButton(
                  onPressed: () {},
                  child: const Text(
                    'See all',
                    style: TextStyle(color: AppColors.primary, fontSize: 13),
                  ),
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms, duration: 300.ms),
            ),
          ),

          // Internship list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            sliver: recommendations.isLoading
                ? SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => const ShimmerCard(),
                      childCount: 3,
                    ),
                  )
                : recommendations.internships.isEmpty
                    ? SliverToBoxAdapter(
                        child: _EmptyState(
                          onTap: () => ref
                              .read(recommendationProvider.notifier)
                              .fetchRecommendations(
                                ref.read(profileProvider),
                              ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final item =
                                recommendations.internships.take(3).toList()[index];
                            return InternshipCard(
                              internship: item,
                              animationIndex: index,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InternshipDetailScreen(internship: item),
                                ),
                              ),
                              onBookmark: () => ref
                                  .read(recommendationProvider.notifier)
                                  .toggleBookmark(item.id),
                            );
                          },
                          childCount:
                              recommendations.internships.take(3).length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.15),
            AppColors.secondary.withOpacity(0.08),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Complete your profile to get better ML recommendations',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 200.ms)
        .shimmer(delay: 600.ms, duration: 1200.ms, color: AppColors.primary.withOpacity(0.08));
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onTap;

  const _EmptyState({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.auto_awesome, color: AppColors.textMuted, size: 42),
          const SizedBox(height: 14),
          const Text(
            'No recommendations yet',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          const Text(
            'Complete your profile and fetch your first matches',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GradientButton(
            label: 'Get Recommendations',
            onPressed: onTap,
            width: 220,
          ),
        ],
      ),
    );
  }
}
