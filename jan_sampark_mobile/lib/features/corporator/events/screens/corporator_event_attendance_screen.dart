import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../voter/events/providers/event_provider.dart';
import '../providers/corporator_event_provider.dart';

/// Screen for recording actual attendance after an event.
class CorporatorEventAttendanceScreen extends ConsumerStatefulWidget {
  const CorporatorEventAttendanceScreen({
    super.key,
    required this.eventId,
  });
  final String eventId;

  @override
  ConsumerState<CorporatorEventAttendanceScreen> createState() =>
      _CorporatorEventAttendanceScreenState();
}

class _CorporatorEventAttendanceScreenState
    extends ConsumerState<CorporatorEventAttendanceScreen> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    final count = int.tryParse(_ctrl.text.trim());
    if (count == null || count < 0) {
      context.showError(
          'Please enter a valid attendance count.');
      return;
    }

    final success = await ref
        .read(attendanceProvider.notifier)
        .markAttendance(
          eventId: widget.eventId,
          count:   count,
        );

    if (!mounted) return;
    if (success) {
      context.showSuccess(
          'Attendance recorded: $count attendees.');
      ref.invalidate(eventDetailProvider(widget.eventId));
      ref.read(eventListProvider.notifier).load();
      context.pop();
    } else {
      context.showError(
          ref.read(attendanceProvider).errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventAsync =
        ref.watch(eventDetailProvider(widget.eventId));
    final state = ref.watch(attendanceProvider);

    return AppScaffold(
      title:       'Mark Attendance',
      isBlueAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppDimensions.spaceXL),

            // Event info
            eventAsync.maybeWhen(
              data: (event) => Container(
                padding: const EdgeInsets.all(
                    AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color:        AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(
                      AppDimensions.radiusMD),
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(event.title,
                        style: AppTextStyles.heading3),
                    const SizedBox(
                        height: AppDimensions.spaceSM),
                    Text(
                      '${event.totalRegistered} registered',
                      style: AppTextStyles.bodySecondary,
                    ),
                  ],
                ),
              ),
              orElse: () => const SizedBox.shrink(),
            ),

            const SizedBox(height: AppDimensions.spaceXXL),

            Text('Actual Attendees',
                style: AppTextStyles.heading3),
            const SizedBox(height: AppDimensions.spaceSM),
            Text(
              'Enter the actual number of people who '
              'attended the event.',
              style: AppTextStyles.bodySecondary,
            ),
            const SizedBox(height: AppDimensions.spaceMD),

            AppTextField(
              label:          'Number of Attendees',
              hint:           'e.g. 245',
              controller:     _ctrl,
              keyboardType:   TextInputType.number,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              prefixIcon: const Icon(Icons.people_outline,
                  size: AppDimensions.iconMD),
            ),

            const SizedBox(height: AppDimensions.spaceXXL),

            PrimaryButton(
              label:     'Save Attendance',
              icon:      Icons.how_to_reg_outlined,
              isLoading: state.isLoading,
              onPressed: _onSubmit,
            ),
          ],
        ),
      ),
    );
  }
}