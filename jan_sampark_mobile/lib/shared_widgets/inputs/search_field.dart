import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_dimensions.dart';

/// Search bar with leading search icon and trailing clear button.
///
/// Usage:
///   SearchField(
///     hint:      'Search complaints...',
///     onChanged: (q) => ref.read(searchProvider.notifier).update(q),
///   )
class SearchField extends StatefulWidget {
  const SearchField({
    super.key,
    this.hint          = 'Search...',
    this.onChanged,
    this.onSubmitted,
    this.controller,
    this.autofocus     = false,
    this.backgroundColor,
  });

  final String hint;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextEditingController? controller;
  final bool autofocus;
  final Color? backgroundColor;

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  late final TextEditingController _ctrl;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _ctrl = widget.controller ?? TextEditingController();
    _ctrl.addListener(() {
      final has = _ctrl.text.isNotEmpty;
      if (has != _hasText) setState(() => _hasText = has);
    });
  }

  @override
  void dispose() {
    if (widget.controller == null) _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppColors.surfaceGrey,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLG),
        border: Border.all(color: AppColors.borderGrey),
      ),
      child: TextField(
        controller:      _ctrl,
        autofocus:       widget.autofocus,
        textInputAction: TextInputAction.search,
        style:           AppTextStyles.body,
        onChanged:       widget.onChanged,
        onSubmitted:     widget.onSubmitted,
        decoration: InputDecoration(
          hintText:    widget.hint,
          hintStyle:   AppTextStyles.body.copyWith(color: AppColors.textHint),
          prefixIcon:  const Icon(
            Icons.search_rounded,
            color: AppColors.textSecondary,
            size:  AppDimensions.iconMD,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(
                    Icons.close_rounded,
                    color: AppColors.textSecondary,
                    size:  AppDimensions.iconMD,
                  ),
                  onPressed: () {
                    _ctrl.clear();
                    widget.onChanged?.call('');
                  },
                )
              : null,
          border:          InputBorder.none,
          enabledBorder:   InputBorder.none,
          focusedBorder:   InputBorder.none,
          contentPadding:  const EdgeInsets.symmetric(vertical: 10),
          isDense:         true,
        ),
      ),
    );
  }
}