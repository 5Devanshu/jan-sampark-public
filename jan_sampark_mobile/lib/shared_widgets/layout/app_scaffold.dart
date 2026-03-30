import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Standard scaffold wrapper used by all screens.
///
/// Provides:
///   - Consistent app bar (white or blue variant)
///   - Safe area handling
///   - Optional FAB slot
///   - Optional bottom action bar slot
///
/// Usage:
///   AppScaffold(
///     title:   'My Complaints',
///     actions: [NotificationBell()],
///     body:    ComplaintListView(),
///   )
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.actions,
    this.leading,
    this.showBackButton  = true,
    this.isBlueAppBar    = false,
    this.floatingActionButton,
    this.bottomBar,
    this.backgroundColor,
    this.resizeToAvoidBottomInset = true,
    this.onBackPressed,
    this.padding,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool isBlueAppBar;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final Color? backgroundColor;
  final bool resizeToAvoidBottomInset;
  final VoidCallback? onBackPressed;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final canPop      = Navigator.canPop(context);
    final bgColor     = isBlueAppBar ? AppColors.appBarBlue  : AppColors.appBarWhite;
    final fgColor     = isBlueAppBar ? AppColors.appBarBlueText : AppColors.appBarWhiteText;
    final overlayStyle = isBlueAppBar ? systemOverlayBlue : systemOverlayWhite;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: backgroundColor ?? AppColors.surfaceGrey,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        appBar: AppBar(
          backgroundColor:  bgColor,
          foregroundColor:  fgColor,
          elevation:        0,
          scrolledUnderElevation: 0,
          centerTitle:      false,
          leading: showBackButton && canPop
              ? IconButton(
                  icon:  Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: fgColor,
                    size:  20,
                  ),
                  onPressed: onBackPressed ??
                      () => Navigator.of(context).pop(),
                )
              : leading,
          title: titleWidget ??
              (title != null
                  ? Text(
                      title!,
                      style: isBlueAppBar
                          ? AppTextStyles.appBarTitleWhite
                          : AppTextStyles.appBarTitle,
                    )
                  : null),
          actions: actions,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              thickness: 1,
              color: isBlueAppBar
                  ? AppColors.primaryDark
                  : AppColors.borderGrey,
            ),
          ),
        ),
        body: padding != null
            ? Padding(padding: padding!, child: body)
            : body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar:  bottomBar,
      ),
    );
  }
}

import '../../core/theme/app_theme.dart';