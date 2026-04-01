import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import 'internship_detail_screen.dart';

class RecommendationScreen extends ConsumerStatefulWidget {
  const RecommendationScreen({super.key});

  @override
  ConsumerState<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends ConsumerState<RecommendationScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'AI/ML', 'App Dev', 'Web', 'Data Science'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(recommendationProvider);
      if (!state.hasFetched) {
        ref
            .read(recommendationProvider.notifier)
            .fetchRecommendations(ref.read(profileProvider));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationProvider);

    final filtered = _selectedFilter == 'All'
        ? state.internships
        : state.internships
            .where((i) => i.domain == _selectedFilter)
            .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'For You ✨',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${state.internships.length} matches found',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  // Refresh
                  GestureDetector(
                    onTap: () => ref
                        .read(recommendationProvider.notifier)
                        .fetchRecommendations(ref.read(profileProvider)),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 18),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 300.ms),
            ),

            const SizedBox(height: 16),

            // Domain filters
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final f = _filters[index];
                  final active = _selectedFilter == f;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? AppColors.primary : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? AppColors.primary : AppColors.border,
                        ),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          color: active ? Colors.white : AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // List
            Expanded(
              child: state.isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 5,
                      itemBuilder: (_, __) => const ShimmerCard(),
                    )
                  : state.error != null
                      ? _ErrorState(
                          onRetry: () => ref
                              .read(recommendationProvider.notifier)
                              .fetchRecommendations(ref.read(profileProvider)),
                        )
                      : filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No results in this category',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return InternshipCard(
                                  internship: item,
                                  animationIndex: index,
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InternshipDetailScreen(internship: item),
                                    ),
                                  ),
                                  onBookmark: () {
                                    ref
                                        .read(recommendationProvider.notifier)
                                        .toggleBookmark(item.id);
                                    ref.read(bookmarksProvider.notifier).toggle(item);
                                  },
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off_outlined, color: AppColors.textMuted, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Could not load recommendations',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check your connection or backend server',
            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
