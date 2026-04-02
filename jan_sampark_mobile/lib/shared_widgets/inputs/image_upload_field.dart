import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/utils/file_picker_helper.dart';
import '../../core/utils/extensions.dart';

/// Image upload box with preview, remove, and camera/gallery choice.
///
/// Single image mode:
///   ImageUploadField(
///     label:    'Upload ID Document',
///     onPicked: (file) => setState(() => _idDoc = file),
///   )
///
/// Multiple images mode (complaint photos):
///   ImageUploadField.multiple(
///     label:     'Attach Photos',
///     onPickedMultiple: (files) => setState(() => _images = files),
///     maxCount:  3,
///   )
class ImageUploadField extends StatefulWidget {
  const ImageUploadField({
    super.key,
    required this.label,
    this.onPicked,
    this.onPickedMultiple,
    this.initialFile,
    this.maxCount = 1,
    this.helperText,
    this.isRequired = false,
    this.allowDocuments = false,
  });

  const ImageUploadField.multiple({
    super.key,
    required this.label,
    required this.onPickedMultiple,
    this.maxCount = 3,
    this.helperText,
    this.isRequired = false,
  })  : onPicked = null,
        initialFile = null,
        allowDocuments = false;

  final String label;
  final void Function(PickedFile file)? onPicked;
  final void Function(List<PickedFile> files)? onPickedMultiple;
  final PickedFile? initialFile;
  final int maxCount;
  final String? helperText;
  final bool isRequired;
  final bool allowDocuments;

  bool get isMultiple => onPickedMultiple != null;

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  PickedFile? _single;
  final List<PickedFile> _multiple = [];

  @override
  void initState() {
    super.initState();
    _single = widget.initialFile;
  }

  Future<void> _pickSingle() async {
    PickedFile? file;
    if (widget.allowDocuments) {
      file = await FilePickerHelper.pickDocument();
    } else {
      file = await showImageSourceSheet(context);
    }
    if (file == null) return;
    if (file.isTooBig) {
      if (mounted) {
        context.showError('File is too large. Maximum size is 5MB.');
      }
      return;
    }
    setState(() => _single = file);
    widget.onPicked?.call(file!);
  }

  Future<void> _pickMultiple() async {
    if (_multiple.length >= widget.maxCount) {
      context.showInfo('Maximum ${widget.maxCount} images allowed.');
      return;
    }
    final remaining = widget.maxCount - _multiple.length;
    final files = await FilePickerHelper.pickMultipleImages(
      maxCount: remaining,
    );
    if (files.isEmpty) return;
    final valid = files.where((f) => !f.isTooBig).toList();
    if (valid.length < files.length) {
      if (mounted) {
        context.showError('Some files were skipped (too large, max 5MB).');
      }
    }
    setState(() => _multiple.addAll(valid));
    widget.onPickedMultiple?.call(List.from(_multiple));
  }

  void _removeSingle() {
    setState(() => _single = null);
    widget.onPicked?.call(PickedFile(
      path: '', name: '', sizeBytes: 0, extension: '',
    ));
  }

  void _removeMultiple(int index) {
    setState(() => _multiple.removeAt(index));
    widget.onPickedMultiple?.call(List.from(_multiple));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(widget.label, style: AppTextStyles.fieldLabel),
            if (widget.isRequired) ...[
              const SizedBox(width: 4),
              Text('*', style: AppTextStyles.fieldLabel.copyWith(
                color: AppColors.error,
              )),
            ],
          ],
        ),
        const SizedBox(height: 8),

        widget.isMultiple ? _buildMultiple() : _buildSingle(),

        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(widget.helperText!, style: AppTextStyles.fieldHelper),
        ],
      ],
    );
  }

  // ── Single upload ──────────────────────────────

  Widget _buildSingle() {
    if (_single != null && _single!.path.isNotEmpty) {
      return _buildPreviewSingle();
    }
    return _buildUploadBox(onTap: _pickSingle);
  }

  Widget _buildPreviewSingle() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.uploadBoxRadius),
          child: Image.file(
            File(_single!.path),
            height: AppDimensions.uploadBoxHeight,
            width:  double.infinity,
            fit:    BoxFit.cover,
          ),
        ),
        Positioned(
          top: 6, right: 6,
          child: _RemoveButton(onTap: _removeSingle),
        ),
      ],
    );
  }

  // ── Multiple upload ────────────────────────────

  Widget _buildMultiple() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._multiple.asMap().entries.map((entry) =>
          _buildMultiThumb(entry.key, entry.value)),
        if (_multiple.length < widget.maxCount)
          _buildUploadBox(
            onTap:  _pickMultiple,
            width:  100,
            height: 100,
          ),
      ],
    );
  }

  Widget _buildMultiThumb(int index, PickedFile file) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.uploadBoxRadius),
          child: Image.file(
            File(file.path),
            width:  100,
            height: 100,
            fit:    BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4, right: 4,
          child: _RemoveButton(onTap: () => _removeMultiple(index)),
        ),
      ],
    );
  }

  // ── Upload placeholder box ─────────────────────

  Widget _buildUploadBox({
    required VoidCallback onTap,
    double width = double.infinity,
    double height = AppDimensions.uploadBoxHeight,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:  width,
        height: height,
        decoration: BoxDecoration(
          color:        AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(AppDimensions.uploadBoxRadius),
          border: Border.all(
            color: AppColors.inputBorder,
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.upload_outlined,
              color: AppColors.textSecondary,
              size:  28,
            ),
            const SizedBox(height: 6),
            Text(
              widget.allowDocuments
                  ? 'Upload Document'
                  : 'Add Photo',
              style: AppTextStyles.captionMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: const BoxDecoration(
          color:  AppColors.error,
          shape:  BoxShape.circle,
        ),
        child: const Icon(Icons.close, color: Colors.white, size: 12),
      ),
    );
  }
}

