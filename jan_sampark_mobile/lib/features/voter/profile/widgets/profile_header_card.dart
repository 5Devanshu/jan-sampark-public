// lib/features/voter/profile/widgets/profile_header_card.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../models/voter_profile_models.dart';

/// Top hero card — avatar, name, mobile, ward/area, EPIC badge.
/// Tapping the avatar opens an image picker for photo update.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.profile,
    required this.onPhotoTap,
    this.isUploadingPhoto = false,
  });

  final VoterProfile profile;
  final Future<void> Function(File) onPhotoTap;
  final bool isUploadingPhoto;

  String get _initials =>
      profile.fullName.trim().split(' ').take(2).map((w) => w[0]).join().toUpperCase();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source:      ImageSource.gallery,
      imageQuality: 80,
      maxWidth:    600,
    );
    if (picked != null) {
      await onPhotoTap(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:  Alignment.topLeft,
          end:    Alignment.bottomRight,
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        AppDimensions.pagePaddingH,
        MediaQuery.of(context).padding.top + 16,
        AppDimensions.pagePaddingH,
        28,
      ),
      child: Column(
        children: [
          // ── Avatar ─────────────────────────────
          GestureDetector(
            onTap: _pickImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width:  90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.5),
                      width: 3,
                    ),
                  ),
                  child: ClipOval(
                    child: isUploadingPhoto
                        ? Container(
                            color: AppColors.primaryDark,
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                                strokeWidth: 2.5,
                              ),
                            ),
                          )
                        : (profile.profilePhotoUrl?.isNotEmpty == true
                            ? Image.network(
                                profile.profilePhotoUrl!,
                                fit:          BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    _InitialsBox(initials: _initials),
                              )
                            : _InitialsBox(initials: _initials)),
                  ),
                ),
                // Camera icon overlay
                Positioned(
                  bottom: 0,
                  right:  0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color:  AppColors.white,
                      shape:  BoxShape.circle,
                      border: Border.all(color: AppColors.primaryLight, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size:  14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // ── Name ───────────────────────────────
          Text(
            profile.fullName,
            style: AppTextStyles.heading2.copyWith(
              color:    AppColors.textOnPrimary,
              fontSize: 20,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // ── Mobile ─────────────────────────────
          Text(
            profile.mobile,
            style: AppTextStyles.body.copyWith(
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 12),

          // ── Ward + EPIC badge ───────────────────
          Wrap(
            spacing:    8,
            runSpacing: 6,
            alignment:  WrapAlignment.center,
            children: [
              if (profile.location.wardName != null)
                _Chip(
                  icon:  Icons.location_on_outlined,
                  label: profile.location.wardName!,
                ),
              if (profile.location.areaName != null)
                _Chip(
                  icon:  Icons.map_outlined,
                  label: profile.location.areaName!,
                ),
              _EpicChip(isVerified: profile.epicVerified),
            ],
          ),
        ],
      ),
    );
  }
}

class _InitialsBox extends StatelessWidget {
  const _InitialsBox({required this.initials});
  final String initials;

  @override
  Widget build(BuildContext context) => Container(
        color:     AppColors.primaryDark,
        alignment: Alignment.center,
        child:     Text(
          initials,
          style: AppTextStyles.heading1.copyWith(
            color:    AppColors.textOnPrimary,
            fontSize: 32,
          ),
        ),
      );
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.label});
  final IconData icon;
  final String   label;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        AppColors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: AppColors.textOnPrimary),
            const SizedBox(width: 4),
            Text(label,
                style: AppTextStyles.captionSmall.copyWith(
                  color: AppColors.textOnPrimary,
                )),
          ],
        ),
      );
}

class _EpicChip extends StatelessWidget {
  const _EpicChip({required this.isVerified});
  final bool isVerified;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color:        isVerified
              ? const Color(0xFF065F46).withOpacity(0.6)
              : const Color(0xFF92400E).withOpacity(0.5),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isVerified
                ? AppColors.successBorder.withOpacity(0.7)
                : AppColors.warningBorder.withOpacity(0.7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isVerified ? Icons.verified : Icons.info_outline,
              size:  11,
              color: AppColors.textOnPrimary,
            ),
            const SizedBox(width: 4),
            Text(
              isVerified ? 'EPIC Verified' : 'Not Verified',
              style: AppTextStyles.captionSmall.copyWith(
                color: AppColors.textOnPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}