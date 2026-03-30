import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Full-screen loading overlay with message.
///
/// Show:
///   LoadingDialog.show(context, message: 'Submitting...');
///
/// Hide:
///   LoadingDialog.hide(context);
class LoadingDialog {
  LoadingDialog._();

  static void show(BuildContext context, {String message = 'Please wait...'}) {
    showDialog(
      context:              context,
      barrierDismissible:   false,
      barrierColor:         AppColors.overlay,
      builder:              (_) => _LoadingDialogContent(message: message),
    );
  }

  static void hide(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }
}

class _LoadingDialogContent extends StatelessWidget {
  const _LoadingDialogContent({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spaceXXL,
            vertical:   AppDimensions.spaceXL,
          ),
          decoration: BoxDecoration(
            color:        AppColors.white,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width:  44,
                height: 44,
                child:  CircularProgressIndicator(
                  strokeWidth: 3,
                  color:       AppColors.primary,
                ),
              ),
              const SizedBox(height: AppDimensions.spaceMD),
              Text(message,
                  style:     AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}