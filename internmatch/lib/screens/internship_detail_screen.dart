import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/internship.dart';
import '../models/application.dart';
import '../providers/app_providers.dart';
import '../widgets/shared_widgets.dart';
import 'applications_screen.dart';

class InternshipDetailScreen extends ConsumerStatefulWidget {
  final Internship internship;

  const InternshipDetailScreen({super.key, required this.internship});

  @override
  ConsumerState<InternshipDetailScreen> createState() =>
      _InternshipDetailScreenState();
}

class _InternshipDetailScreenState
    extends ConsumerState<InternshipDetailScreen> {
  late Internship _internship;

  @override
  void initState() {
    super.initState();
    _internship = widget.internship;
  }

  Color get _matchColor {
    if (_internship.matchScore >= 85) return AppColors.success;
    if (_internship.matchScore >= 70) return AppColors.warning;
    return AppColors.error;
  }

  String get _matchLabel {
    if (_internship.matchScore >= 85) return 'Excellent Match';
    if (_internship.matchScore >= 70) return 'Good Match';
    return 'Partial Match';
  }

  int _daysLeft() {
    if (_internship.deadline == null) return -1;
    return _internship.deadline!.difference(DateTime.now()).inDays;
  }

  Future<void> _applyNow() async {
    // 1. Log in tracker
    final entry = ApplicationEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      internshipId: _internship.id,
      internshipTitle: _internship.title,
      company: _internship.company,
      companyLogo: _internship.companyLogo,
      status: ApplicationStatus.applied,
      appliedAt: DateTime.now(),
    );
    await ref.read(applicationsProvider.notifier).addApplication(entry);

    // 2. Mark card as applied
    setState(() {
      _internship = _internship.copyWith(hasApplied: true);
    });

    // 3. Launch external link
    if (_internship.applyUrl != null) {
      final uri = Uri.parse(_internship.applyUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }

    if (!mounted) return;

    // 4. Show confirmation snackbar with tracker shortcut
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Application tracked! ✓'),
        action: SnackBarAction(
          label: 'View Tracker',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApplicationsScreen()),
            );
          },
        ),
        backgroundColor: AppColors.surfaceElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _toggleBookmark() {
    setState(() {
      _internship = _internship.copyWith(
        isBookmarked: !_internship.isBookmarked,
      );
    });
    ref.read(bookmarksProvider.notifier).toggle(_internship);
    ref.read(recommendationProvider.notifier).toggleBookmark(_internship.id);
  }

  @override
  Widget build(BuildContext context) {
    final daysLeft = _daysLeft();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated.withOpacity(0.8),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    size: 16, color: AppColors.textPrimary),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: _toggleBookmark,
                child: Container(
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _internship.isBookmarked
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        key: ValueKey(_internship.isBookmarked),
                        color: _internship.isBookmarked
                            ? AppColors.primary
                            : AppColors.textSecondary,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(
                      text: _internship.applyUrl ??
                          'internmatch://internship/${_internship.id}',
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Link copied!')),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 12, top: 10, bottom: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.share_outlined,
                        color: AppColors.textSecondary, size: 18),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.25),
                      AppColors.background,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.fromLTRB(20, 60, 20, 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            // Company logo
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceHighlight,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Image.network(
                                  _internship.companyLogo,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Center(
                                    child: Text(
                                      _internship.company[0],
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _internship.company,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    _internship.title,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Quick meta chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoChip(
                      icon: Icons.location_on_outlined,
                      label: _internship.location,
                    ),
                    _InfoChip(
                      icon: Icons.work_outline,
                      label: _internship.type,
                    ),
                    _InfoChip(
                      icon: Icons.access_time,
                      label: _internship.duration,
                    ),
                    _InfoChip(
                      icon: Icons.category_outlined,
                      label: _internship.domain,
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 300.ms),

                const SizedBox(height: 20),

                // Match score card
                _MatchScoreCard(
                  score: _internship.matchScore,
                  label: _matchLabel,
                  color: _matchColor,
                  skills: _internship.skills,
                )
                    .animate()
                    .fadeIn(delay: 150.ms, duration: 300.ms)
                    .slideY(begin: 0.05, end: 0, delay: 150.ms),

                const SizedBox(height: 16),

                // Deadline + stipend row
                Row(
                  children: [
                    Expanded(
                      child: _DetailTile(
                        icon: Icons.payments_outlined,
                        label: 'Stipend',
                        value: _internship.stipend,
                        valueColor: AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DetailTile(
                        icon: Icons.event_outlined,
                        label: 'Deadline',
                        value: daysLeft < 0
                            ? 'Open'
                            : daysLeft == 0
                                ? 'Today!'
                                : '$daysLeft days left',
                        valueColor: (daysLeft >= 0 && daysLeft <= 5)
                            ? AppColors.warning
                            : AppColors.textPrimary,
                      ),
                    ),
                  ],
                )
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 300.ms),

                const SizedBox(height: 20),

                // Description
                if (_internship.description != null) ...[
                  const _SectionLabel(label: 'About This Role'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      _internship.description!,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 250.ms, duration: 300.ms),
                  const SizedBox(height: 20),
                ],

                // Required skills
                const _SectionLabel(label: 'Required Skills'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _internship.skills.map((s) {
                    final userSkills =
                        ref.read(profileProvider).skills;
                    final hasSkill = userSkills
                        .any((us) => us.toLowerCase() == s.toLowerCase());
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: hasSkill
                            ? AppColors.success.withOpacity(0.12)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: hasSkill
                              ? AppColors.success.withOpacity(0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (hasSkill) ...[
                            const Icon(Icons.check_circle,
                                color: AppColors.success, size: 12),
                            const SizedBox(width: 5),
                          ],
                          Text(
                            s,
                            style: TextStyle(
                              color: hasSkill
                                  ? AppColors.success
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                )
                    .animate()
                    .fadeIn(delay: 300.ms, duration: 300.ms),

                const SizedBox(height: 20),

                // Company info placeholder
                const _SectionLabel(label: 'About the Company'),
                const SizedBox(height: 8),
                Container(
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
                          color: AppColors.surfaceHighlight,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            _internship.companyLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                _internship.company[0],
                                style: const TextStyle(
                                  color: AppColors.primary,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
                              _internship.company,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'View company profile →',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(delay: 350.ms, duration: 300.ms),
              ]),
            ),
          ),
        ],
      ),

      // ── Bottom Apply Bar ───────────────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        decoration: BoxDecoration(
          color: AppColors.background,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Match badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _matchColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _matchColor.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_internship.matchScore}%',
                    style: TextStyle(
                      color: _matchColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'match',
                    style: TextStyle(
                      color: _matchColor.withOpacity(0.8),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GradientButton(
                label: _internship.hasApplied ? '✓ Applied' : 'Apply Now',
                onPressed: _internship.hasApplied ? null : _applyNow,
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: 400.ms, duration: 300.ms)
          .slideY(begin: 0.2, end: 0, delay: 400.ms),
    );
  }
}

// ── Match Score Card ──────────────────────────────────────────────────────────

class _MatchScoreCard extends StatelessWidget {
  final int score;
  final String label;
  final Color color;
  final List<String> skills;

  const _MatchScoreCard({
    required this.score,
    required this.label,
    required this.color,
    required this.skills,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.12),
            AppColors.surface,
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 36,
            lineWidth: 6,
            percent: score / 100,
            center: Text(
              '$score%',
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            progressColor: color,
            backgroundColor: color.withOpacity(0.15),
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Based on your skills, CGPA, and interests',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    height: 1.4,
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

// ── Info Chip ─────────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textMuted),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Detail Tile ───────────────────────────────────────────────────────────────

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Section Label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 15,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
