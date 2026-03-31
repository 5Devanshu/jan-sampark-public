import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/file_picker_helper.dart';

/// UPI screenshot capture and preview widget.
///
/// Allows the voter to either take a photo of their
/// UPI payment confirmation or select from gallery.
/// Shows the preview with a remove option.
class UpiScreenshotUploader extends StatelessWidget {
  const UpiScreenshotUploader({
    super.key,
    required this.pickedFile,
    required this.onPicked,
    required this.onRemove,
    this.hasError = false,
  });

  final PickedFile? pickedFile;
  final void Function(PickedFile) onPicked;
  final VoidCallback onRemove;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('UPI Payment Screenshot', style: AppTextStyles.fieldLabel),
            const SizedBox(width: 4),
            Text(
              '*',
              style: AppTextStyles.fieldLabel.copyWith(color: AppColors.error),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Upload the payment confirmation screenshot from your UPI app.',
          style: AppTextStyles.fieldHelper,
        ),
        const SizedBox(height: 10),

        pickedFile != null ? _buildPreview(context) : _buildUploadBox(context),

        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            'Please upload your UPI payment screenshot.',
            style: AppTextStyles.fieldError,
          ),
        ],
      ],
    );
  }

  // ── Preview ────────────────────────────────────

  Widget _buildPreview(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          child: Image.file(
            File(pickedFile!.path),
            width: double.infinity,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),

        // Overlay with file info
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.7), Colors.transparent],
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(AppDimensions.cardRadius),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    pickedFile!.name,
                    style: AppTextStyles.caption.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${pickedFile!.sizeMb.toStringAsFixed(1)} MB',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Remove button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),

        // Change button
        Positioned(
          top: 8,
          left: 8,
          child: GestureDetector(
            onTap: () async {
              final f = await showImageSourceSheet(context);
              if (f != null) onPicked(f);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.9),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 12,
                  ),
                  const SizedBox(width: 4),
                  Text('Change', style: AppTextStyles.labelSmallWhite),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Upload box ─────────────────────────────────

  Widget _buildUploadBox(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final f = await showImageSourceSheet(context);
        if (f != null) onPicked(f);
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: hasError ? AppColors.errorLight : AppColors.surfaceGrey,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(
            color: hasError ? AppColors.error : AppColors.inputBorder,
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: hasError ? AppColors.errorLight : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.upload_rounded,
                color: hasError ? AppColors.error : AppColors.primary,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Tap to upload screenshot',
              style: AppTextStyles.bodyMedium.copyWith(
                color: hasError ? AppColors.error : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text('Camera or Gallery · Max 5MB', style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
