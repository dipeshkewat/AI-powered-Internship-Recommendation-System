import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';

/// Drop-in widget for the profile screen.
/// Handles file picking UI and upload state display.
/// Wire [onFileSelected] to your actual upload logic.
class ResumeUploadWidget extends StatefulWidget {
  final String? existingResumeUrl;
  final void Function(File file) onFileSelected;

  const ResumeUploadWidget({
    super.key,
    this.existingResumeUrl,
    required this.onFileSelected,
  });

  @override
  State<ResumeUploadWidget> createState() => _ResumeUploadWidgetState();
}

class _ResumeUploadWidgetState extends State<ResumeUploadWidget> {
  _UploadState _state = _UploadState.idle;
  String? _fileName;
  double _progress = 0;

  bool get _hasResume =>
      widget.existingResumeUrl != null || _state == _UploadState.done;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );
      
      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        setState(() {
          _fileName = result.files.single.name;
          _state = _UploadState.uploading;
          _progress = 0;
        });
        
        widget.onFileSelected(file);
        await _simulateUpload();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking file: $e')),
      );
    }
  }

  Future<void> _simulateUpload() async {
    for (int i = 1; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _progress = i / 10);
    }
    setState(() => _state = _UploadState.done);
  }

  void _removeResume() {
    setState(() {
      _state = _UploadState.idle;
      _fileName = null;
      _progress = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: _state == _UploadState.uploading
          ? _UploadingView(
              fileName: _fileName ?? '',
              progress: _progress,
            )
          : _hasResume
              ? _DoneView(
                  fileName: _fileName ??
                      widget.existingResumeUrl?.split('/').last ??
                      'Resume',
                  onRemove: _removeResume,
                  onReplace: _pickFile,
                )
              : _IdleView(onTap: _pickFile),
    );
  }
}

// ─── Idle: pick file prompt ───────────────────────────────────────────────────

class _IdleView extends StatelessWidget {
  final VoidCallback onTap;

  const _IdleView({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.upload_file_outlined,
                color: AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Upload Resume',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'PDF, DOC, or DOCX · Max 5 MB',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms);
  }
}

// ─── Uploading: progress bar ──────────────────────────────────────────────────

class _UploadingView extends StatelessWidget {
  final String fileName;
  final double progress;

  const _UploadingView({required this.fileName, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.description_outlined,
                color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(progress * 100).toInt()}% uploaded',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
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

// ─── Done: resume attached ────────────────────────────────────────────────────

class _DoneView extends StatelessWidget {
  final String fileName;
  final VoidCallback onRemove;
  final VoidCallback onReplace;

  const _DoneView({
    required this.fileName,
    required this.onRemove,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.check_circle_outline,
                color: AppColors.success, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Resume uploaded ✓',
                  style: TextStyle(color: AppColors.success, fontSize: 11),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            onSelected: (v) => v == 'replace' ? onReplace() : onRemove(),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'replace',
                child: Row(children: [
                  Icon(Icons.swap_horiz, color: AppColors.textSecondary, size: 16),
                  SizedBox(width: 8),
                  Text('Replace', style: TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                ]),
              ),
              const PopupMenuItem(
                value: 'remove',
                child: Row(children: [
                  Icon(Icons.delete_outline, color: AppColors.error, size: 16),
                  SizedBox(width: 8),
                  Text('Remove', style: TextStyle(color: AppColors.error, fontSize: 13)),
                ]),
              ),
            ],
            icon: const Icon(Icons.more_vert,
                color: AppColors.textMuted, size: 18),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .scale(
          begin: const Offset(0.97, 0.97),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
        );
  }
}

enum _UploadState { idle, uploading, done }
