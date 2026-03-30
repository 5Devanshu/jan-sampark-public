import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_constants.dart';

/// Result from any file pick or camera capture operation.
class PickedFile {
  const PickedFile({
    required this.path,
    required this.name,
    required this.sizeBytes,
    required this.extension,
  });

  final String path;
  final String name;
  final int    sizeBytes;
  final String extension;

  double get sizeMb => sizeBytes / (1024 * 1024);
  bool   get isTooBig => sizeMb > AppConstants.maxUploadSizeMb;

  File get file => File(path);
}

/// Helper for image and document picking.
///
/// Wraps image_picker and file_picker with size validation
/// and returns a typed [PickedFile] result.
class FilePickerHelper {
  FilePickerHelper._();

  static final _picker = ImagePicker();

  // ─────────────────────────────────────────────
  // Camera
  // ─────────────────────────────────────────────

  /// Capture a photo with the camera.
  /// Returns null if user cancels or permission denied.
  static Future<PickedFile?> pickFromCamera() async {
    try {
      final xFile = await _picker.pickImage(
        source:        ImageSource.camera,
        imageQuality:  85,
        maxWidth:      1920,
        maxHeight:     1920,
      );
      if (xFile == null) return null;
      return _toPickedFile(xFile.path, xFile.name);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Gallery
  // ─────────────────────────────────────────────

  /// Pick a single image from gallery.
  static Future<PickedFile?> pickImageFromGallery() async {
    try {
      final xFile = await _picker.pickImage(
        source:        ImageSource.gallery,
        imageQuality:  85,
        maxWidth:      1920,
        maxHeight:     1920,
      );
      if (xFile == null) return null;
      return _toPickedFile(xFile.path, xFile.name);
    } catch (_) {
      return null;
    }
  }

  /// Pick multiple images from gallery (up to [maxCount]).
  static Future<List<PickedFile>> pickMultipleImages({
    int maxCount = AppConstants.maxComplaintImages,
  }) async {
    try {
      final xFiles = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth:     1920,
        maxHeight:    1920,
        limit:        maxCount,
      );
      return xFiles
          .map((x) => _toPickedFile(x.path, x.name))
          .whereType<PickedFile>()
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // Document — ID cards, UPI screenshots
  // ─────────────────────────────────────────────

  /// Pick a document (image or PDF).
  /// Used for ID document upload and UPI screenshot upload.
  static Future<PickedFile?> pickDocument({
    List<String> allowedExtensions = const ['jpg', 'jpeg', 'png', 'pdf'],
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type:              FileType.custom,
        allowedExtensions: allowedExtensions,
        allowMultiple:     false,
        withData:          false,
        withReadStream:    false,
      );
      if (result == null || result.files.isEmpty) return null;

      final pf = result.files.first;
      if (pf.path == null) return null;
      return _toPickedFile(pf.path!, pf.name);
    } catch (_) {
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Internal helpers
  // ─────────────────────────────────────────────

  static PickedFile? _toPickedFile(String path, String name) {
    try {
      final file = File(path);
      if (!file.existsSync()) return null;
      final sizeBytes = file.lengthSync();
      final ext       = name.contains('.')
          ? name.split('.').last.toLowerCase()
          : '';
      return PickedFile(
        path:       path,
        name:       name,
        sizeBytes:  sizeBytes,
        extension:  ext,
      );
    } catch (_) {
      return null;
    }
  }
}

/// Shows a bottom sheet with Camera / Gallery options.
/// Returns the picked file or null.
///
/// Usage:
///   final file = await showImageSourceSheet(context);
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_dimensions.dart';

Future<PickedFile?> showImageSourceSheet(BuildContext context) async {
  return showModalBottomSheet<PickedFile?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(AppDimensions.bottomSheetRadius),
      ),
    ),
    builder: (_) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color:  AppColors.borderGrey,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined,
                color: AppColors.primary),
            title: Text('Take Photo', style: AppTextStyles.bodyMedium),
            onTap: () async {
              Navigator.pop(context, await FilePickerHelper.pickFromCamera());
            },
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined,
                color: AppColors.primary),
            title: Text('Choose from Gallery', style: AppTextStyles.bodyMedium),
            onTap: () async {
              Navigator.pop(
                context,
                await FilePickerHelper.pickImageFromGallery(),
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}