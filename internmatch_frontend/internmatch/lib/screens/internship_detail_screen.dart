// ============================================================
// INTERNSHIP DETAIL SCREEN — Full-page modal bottom sheet
// Shows description, job role, stipend, requirements + Apply/Save
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/internship.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../theme/app_theme.dart';

/// Shows the internship detail as a draggable modal bottom sheet.
void showInternshipDetail(BuildContext context, Internship internship) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.5),
    builder: (_) => ProviderScope(
      parent: ProviderScope.containerOf(context),
      child: _InternshipDetailSheet(internship: internship),
    ),
  );
}

class _InternshipDetailSheet extends ConsumerStatefulWidget {
  final Internship internship;
  const _InternshipDetailSheet({required this.internship});

  @override
  ConsumerState<_InternshipDetailSheet> createState() =>
      _InternshipDetailSheetState();
}

class _InternshipDetailSheetState
    extends ConsumerState<_InternshipDetailSheet> {
  bool _applied = false;
  bool _applying = false;

  Color get _logoColor {
    try {
      return Color(
          int.parse(widget.internship.logoColor.replaceFirst('#', '0xFF')));
    } catch (_) {
      return AppColors.primary;
    }
  }

  void _handleApply() async {
    if (_applied) return;
    setState(() => _applying = true);
    await Future.delayed(const Duration(milliseconds: 800)); // simulate API
    final notifier = ref.read(userProvider.notifier);
    notifier.addAppliedInternship(AppliedInternship(
      id: widget.internship.id,
      title: widget.internship.title,
      company: widget.internship.company,
      status: 'Applied',
      appliedDate: _todayFormatted(),
    ));
    if (mounted) {
      setState(() {
        _applying = false;
        _applied = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Application submitted!'),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  String _todayFormatted() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);
    final isSaved = user.savedInternships.contains(widget.internship.id);
    final intern = widget.internship;
    final screenH = MediaQuery.of(context).size.height;

    return DraggableScrollableSheet(
      initialChildSize: 0.92,
      minChildSize: 0.5,
      maxChildSize: 0.97,
      builder: (ctx, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // ── Drag handle ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // ── Scrollable body ──────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──────────────────────────────
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Company logo
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: _logoColor,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: Text(
                                intern.companyInitial,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  intern.title,
                                  style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  intern.company,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                          // Close button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: AppColors.border,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.close,
                                  color: AppColors.textSecondary, size: 16),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms),

                      const SizedBox(height: 16),

                      // ── Match score badge ──────────────────
                      if (intern.matchScore > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.accent.withOpacity(0.15),
                                AppColors.accent.withOpacity(0.08),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: AppColors.accent.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome,
                                  color: AppColors.accent, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                '${intern.matchScore}% AI Match Score',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.accent),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 100.ms),

                      const SizedBox(height: 18),

                      // ── Info grid ─────────────────────────
                      const _SectionLabel('Job Details'),
                      const SizedBox(height: 10),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 2.5,
                        children: [
                          _InfoTile(
                              icon: Icons.payments_outlined,
                              label: 'Stipend',
                              value: intern.stipend),
                          _InfoTile(
                              icon: Icons.schedule_outlined,
                              label: 'Duration',
                              value: intern.duration),
                          _InfoTile(
                              icon: Icons.location_on_outlined,
                              label: 'Location',
                              value: intern.location),
                          _InfoTile(
                              icon: intern.locationType == 'Remote'
                                  ? Icons.wifi_outlined
                                  : intern.locationType == 'Hybrid'
                                      ? Icons.device_hub_outlined
                                      : Icons.business_outlined,
                              label: 'Work Type',
                              value: intern.locationType),
                          _InfoTile(
                              icon: Icons.work_outline,
                              label: 'Job Type',
                              value: intern.type),
                          _InfoTile(
                              icon: Icons.category_outlined,
                              label: 'Domain',
                              value: intern.domain),
                        ],
                      ).animate().fadeIn(delay: 150.ms),

                      const SizedBox(height: 20),

                      // ── Stats row ─────────────────────────
                      Row(children: [
                        _StatBadge(
                          icon: Icons.people_outline,
                          label: '${intern.applicants} applicants',
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          icon: Icons.open_in_new_outlined,
                          label: '${intern.openings} openings',
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        _StatBadge(
                          icon: Icons.access_time_outlined,
                          label: '${intern.postedDaysAgo}d ago',
                          color: AppColors.warning,
                        ),
                      ]).animate().fadeIn(delay: 200.ms),

                      const SizedBox(height: 22),

                      // ── Description ───────────────────────
                      const _SectionLabel('About the Role'),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          intern.description,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.6,
                          ),
                        ),
                      ).animate().fadeIn(delay: 250.ms),

                      const SizedBox(height: 22),

                      // ── Responsibilities / Job Role ───────
                      if (intern.responsibilities.isNotEmpty) ...[
                        const _SectionLabel('Responsibilities'),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            children: intern.responsibilities
                                .asMap()
                                .entries
                                .map((e) => Padding(
                                      padding: EdgeInsets.only(
                                          bottom: e.key <
                                                  intern.responsibilities
                                                          .length -
                                                      1
                                              ? 12
                                              : 0),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                top: 5),
                                            width: 7,
                                            height: 7,
                                            decoration: BoxDecoration(
                                              color: _logoColor,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              e.value,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color:
                                                    AppColors.textSecondary,
                                                height: 1.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                        const SizedBox(height: 22),
                      ],

                      // ── Required Skills ───────────────────
                      const _SectionLabel('Required Skills'),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: intern.requiredSkills
                            .map((s) => Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.primary
                                            .withOpacity(0.2)),
                                  ),
                                  child: Text(s,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500)),
                                ))
                            .toList(),
                      ).animate().fadeIn(delay: 350.ms),

                      // ── Tools ─────────────────────────────
                      if (intern.tools.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const _SectionLabel('Tools & Platforms'),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: intern.tools
                              .map((t) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8E24AA)
                                          .withOpacity(0.08),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                      border: Border.all(
                                          color: const Color(0xFF8E24AA)
                                              .withOpacity(0.2)),
                                    ),
                                    child: Text(t,
                                        style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFF8E24AA),
                                            fontWeight: FontWeight.w500)),
                                  ))
                              .toList(),
                        ).animate().fadeIn(delay: 400.ms),
                      ],

                      // Bottom padding for button area
                      const SizedBox(height: 110),
                    ],
                  ),
                ),
              ),

              // ── Sticky bottom action bar ─────────────────────
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  border: const Border(
                      top: BorderSide(color: AppColors.border, width: 1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                padding: EdgeInsets.fromLTRB(
                    20, 14, 20, MediaQuery.of(context).padding.bottom + 14),
                child: Row(
                  children: [
                    // Save button
                    GestureDetector(
                      onTap: () {
                        ref
                            .read(userProvider.notifier)
                            .toggleSaveInternship(intern.id);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isSaved
                              ? AppColors.primary.withOpacity(0.1)
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSaved
                                ? AppColors.primary.withOpacity(0.3)
                                : AppColors.border,
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_outline,
                          color: isSaved
                              ? AppColors.primary
                              : AppColors.textSecondary,
                          size: 22,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Apply button
                    Expanded(
                      child: GestureDetector(
                        onTap: _applied ? null : _handleApply,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: 52,
                          decoration: BoxDecoration(
                            gradient: _applied
                                ? const LinearGradient(colors: [
                                    AppColors.success,
                                    AppColors.success,
                                  ])
                                : AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: (_applied
                                        ? AppColors.success
                                        : AppColors.primary)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: _applying
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _applied
                                            ? Icons.check_circle_outline
                                            : Icons.send_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _applied
                                            ? 'Applied ✓'
                                            : 'Apply Now',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
            ],
          ),
        );
      },
    );
  }
}

// ── Helper widgets ────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500)),
                Text(value,
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _StatBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
