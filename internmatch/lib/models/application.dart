import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Model ────────────────────────────────────────────────────────────────────

enum ApplicationStatus {
  applied,
  inReview,
  shortlisted,
  rejected,
  offered,
}

extension ApplicationStatusX on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.applied:
        return 'Applied';
      case ApplicationStatus.inReview:
        return 'In Review';
      case ApplicationStatus.shortlisted:
        return 'Shortlisted';
      case ApplicationStatus.rejected:
        return 'Rejected';
      case ApplicationStatus.offered:
        return 'Offered 🎉';
    }
  }

  // Hex color strings used in the UI
  int get colorValue {
    switch (this) {
      case ApplicationStatus.applied:
        return 0xFF7B61FF; // primary
      case ApplicationStatus.inReview:
        return 0xFFF59E0B; // warning
      case ApplicationStatus.shortlisted:
        return 0xFF00D4AA; // secondary
      case ApplicationStatus.rejected:
        return 0xFFEF4444; // error
      case ApplicationStatus.offered:
        return 0xFF22C55E; // success
    }
  }
}

class ApplicationEntry {
  final String id;
  final String internshipId;
  final String internshipTitle;
  final String company;
  final String companyLogo;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime? updatedAt;
  final String? notes;

  const ApplicationEntry({
    required this.id,
    required this.internshipId,
    required this.internshipTitle,
    required this.company,
    required this.companyLogo,
    required this.status,
    required this.appliedAt,
    this.updatedAt,
    this.notes,
  });

  ApplicationEntry copyWith({
    ApplicationStatus? status,
    String? notes,
    DateTime? updatedAt,
  }) {
    return ApplicationEntry(
      id: id,
      internshipId: internshipId,
      internshipTitle: internshipTitle,
      company: company,
      companyLogo: companyLogo,
      status: status ?? this.status,
      appliedAt: appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'internship_id': internshipId,
        'internship_title': internshipTitle,
        'company': company,
        'company_logo': companyLogo,
        'status': status.index,
        'applied_at': appliedAt.toIso8601String(),
        'updated_at': updatedAt?.toIso8601String(),
        'notes': notes,
      };

  factory ApplicationEntry.fromJson(Map<String, dynamic> json) {
    return ApplicationEntry(
      id: json['id'] as String,
      internshipId: json['internship_id'] as String,
      internshipTitle: json['internship_title'] as String,
      company: json['company'] as String,
      companyLogo: json['company_logo'] as String,
      status: ApplicationStatus.values[json['status'] as int],
      appliedAt: DateTime.parse(json['applied_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

class ApplicationsNotifier extends StateNotifier<List<ApplicationEntry>> {
  static const _key = 'applications_json';

  ApplicationsNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      state = list
          .map((e) => ApplicationEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key, jsonEncode(state.map((e) => e.toJson()).toList()));
  }

  Future<void> addApplication(ApplicationEntry entry) async {
    if (state.any((e) => e.internshipId == entry.internshipId)) return;
    state = [entry, ...state];
    await _persist();
  }

  Future<void> updateStatus(String entryId, ApplicationStatus status) async {
    state = state.map((e) {
      if (e.id == entryId) {
        return e.copyWith(status: status, updatedAt: DateTime.now());
      }
      return e;
    }).toList();
    await _persist();
  }

  Future<void> updateNotes(String entryId, String notes) async {
    state = state.map((e) {
      if (e.id == entryId) return e.copyWith(notes: notes);
      return e;
    }).toList();
    await _persist();
  }

  Future<void> removeApplication(String entryId) async {
    state = state.where((e) => e.id != entryId).toList();
    await _persist();
  }

  bool hasApplied(String internshipId) =>
      state.any((e) => e.internshipId == internshipId);

  Map<ApplicationStatus, int> get statusCounts {
    final counts = <ApplicationStatus, int>{};
    for (final s in ApplicationStatus.values) {
      counts[s] = state.where((e) => e.status == s).length;
    }
    return counts;
  }
}

final applicationsProvider =
    StateNotifierProvider<ApplicationsNotifier, List<ApplicationEntry>>(
  (ref) => ApplicationsNotifier(),
);
