import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_theme.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import 'internship_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchCtrl = TextEditingController();
  bool _showFilters = false;
  String? _activeType;
  String? _activeDomain;

  final List<String> _typeOptions = ['Remote', 'Hybrid', 'On-site'];
  final List<String> _domainOptions = ['AI/ML', 'App Dev', 'Web', 'Data Science', 'Cloud'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Explore',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Search bar
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: TextField(
                            controller: _searchCtrl,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                            onChanged: (q) => ref.read(searchProvider.notifier).search(q),
                            decoration: const InputDecoration(
                              hintText: 'Search role, company, skill...',
                              prefixIcon: Icon(Icons.search, color: AppColors.textMuted, size: 18),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setState(() => _showFilters = !_showFilters),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: _showFilters
                                ? AppColors.primary.withOpacity(0.15)
                                : AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _showFilters ? AppColors.primary : AppColors.border,
                            ),
                          ),
                          child: Icon(
                            Icons.tune,
                            color: _showFilters ? AppColors.primary : AppColors.textMuted,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Filters
                  if (_showFilters) ...[
                    const SizedBox(height: 12),
                    _FilterSection(
                      title: 'Type',
                      options: _typeOptions,
                      selected: _activeType,
                      onSelect: (v) {
                        setState(() => _activeType = _activeType == v ? null : v);
                        ref.read(searchProvider.notifier).applyFilter(
                          domain: _activeDomain,
                          type: _activeType,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _FilterSection(
                      title: 'Domain',
                      options: _domainOptions,
                      selected: _activeDomain,
                      onSelect: (v) {
                        setState(() => _activeDomain = _activeDomain == v ? null : v);
                        ref.read(searchProvider.notifier).applyFilter(
                          domain: _activeDomain,
                          type: _activeType,
                        );
                      },
                    ),
                  ],
                ],
              )
                  .animate()
                  .fadeIn(duration: 300.ms),
            ),

            const SizedBox(height: 12),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(
                    '${state.results.length} internships',
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  if (_activeType != null || _activeDomain != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _activeType = null;
                          _activeDomain = null;
                        });
                        ref.read(searchProvider.notifier).applyFilter();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Clear filters',
                          style: TextStyle(color: AppColors.error, fontSize: 11),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Results
            Expanded(
              child: state.isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: 4,
                      itemBuilder: (_, __) => const ShimmerCard(),
                    )
                  : state.results.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, color: AppColors.textMuted, size: 40),
                              const SizedBox(height: 12),
                              Text(
                                'No results for "${_searchCtrl.text}"',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                          itemCount: state.results.length,
                          itemBuilder: (context, index) {
                            final item = state.results[index];
                            return InternshipCard(
                              internship: item,
                              animationIndex: index,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => InternshipDetailScreen(internship: item),
                                ),
                              ),
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

class _FilterSection extends StatelessWidget {
  final String title;
  final List<String> options;
  final String? selected;
  final void Function(String) onSelect;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: options.map((o) {
            final active = selected == o;
            return GestureDetector(
              onTap: () => onSelect(o),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: active ? AppColors.primary.withOpacity(0.15) : AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: active ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  o,
                  style: TextStyle(
                    color: active ? AppColors.primaryLight : AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
