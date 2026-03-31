import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/file_picker_helper.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/image_upload_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/loading_dialog.dart';
import '../providers/leader_event_provider.dart';

class LeaderCreateEventScreen extends ConsumerStatefulWidget {
  const LeaderCreateEventScreen({super.key});

  @override
  ConsumerState<LeaderCreateEventScreen> createState() =>
      _LeaderCreateEventScreenState();
}

class _LeaderCreateEventScreenState
    extends ConsumerState<LeaderCreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();
  final _timeCtrl = TextEditingController();
  final _venueCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  final _deadlineCtrl = TextEditingController();
  PickedFile? _coverImage;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _dateCtrl.dispose();
    _timeCtrl.dispose();
    _venueCtrl.dispose();
    _addressCtrl.dispose();
    _capacityCtrl.dispose();
    _deadlineCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    context.hideKeyboard();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      ctrl.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _pickTime() async {
    context.hideKeyboard();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.primary),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      _timeCtrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();
    if (!_formKey.currentState!.validate()) return;

    LoadingDialog.show(context, message: 'Creating event...');

    final success = await ref
        .read(createEventProvider.notifier)
        .create(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          eventDate: _dateCtrl.text.trim(),
          eventTime: _timeCtrl.text.trim(),
          venueName: _venueCtrl.text.trim(),
          venueAddress: _addressCtrl.text.trim(),
          maxCapacity: _capacityCtrl.text.trim().isNotEmpty
              ? int.tryParse(_capacityCtrl.text.trim())
              : null,
          registrationDeadline: _deadlineCtrl.text.trim().isNotEmpty
              ? _deadlineCtrl.text.trim()
              : null,
          coverImagePath: _coverImage?.path,
        );

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (success) {
      context.showSuccess('Event created successfully.');
      context.pop();
    } else {
      final error = ref.read(createEventProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(createEventProvider);

    return AppScaffold(
      title: 'Create Event',
      isBlueAppBar: true,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimensions.spaceXL),

              // Title
              AppTextField(
                label: 'Event Title',
                hint: 'e.g. Ward Development Meeting',
                controller: _titleCtrl,
                textInputAction: TextInputAction.next,
                validator: Validators.required('Title'),
                prefixIcon: const Icon(
                  Icons.title_rounded,
                  size: AppDimensions.iconMD,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Description
              AppTextField(
                label: 'Description',
                hint: 'Describe the event, agenda, what to bring...',
                controller: _descCtrl,
                maxLines: 4,
                maxLength: 2000,
                textInputAction: TextInputAction.next,
                validator: Validators.minLength('Description', 10),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Date + Time row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Event Date',
                      hint: 'YYYY-MM-DD',
                      controller: _dateCtrl,
                      isReadOnly: true,
                      validator: Validators.required('Date'),
                      prefixIcon: const Icon(
                        Icons.calendar_today_outlined,
                        size: AppDimensions.iconMD,
                      ),
                      onTap: () => _pickDate(_dateCtrl),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: AppTextField(
                      label: 'Start Time',
                      hint: 'HH:MM',
                      controller: _timeCtrl,
                      isReadOnly: true,
                      validator: Validators.required('Time'),
                      prefixIcon: const Icon(
                        Icons.access_time_rounded,
                        size: AppDimensions.iconMD,
                      ),
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Venue
              AppTextField(
                label: 'Venue Name',
                hint: 'e.g. Ward Community Hall',
                controller: _venueCtrl,
                textInputAction: TextInputAction.next,
                validator: Validators.required('Venue'),
                prefixIcon: const Icon(
                  Icons.place_outlined,
                  size: AppDimensions.iconMD,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Address
              AppTextField(
                label: 'Venue Address',
                hint: 'Full address with landmark',
                controller: _addressCtrl,
                maxLines: 2,
                textInputAction: TextInputAction.next,
                validator: Validators.required('Address'),
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Capacity + Deadline row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Max Capacity',
                      hint: 'Unlimited',
                      controller: _capacityCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      prefixIcon: const Icon(
                        Icons.people_outline,
                        size: AppDimensions.iconMD,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.spaceMD),
                  Expanded(
                    child: AppTextField(
                      label: 'Reg. Deadline',
                      hint: 'YYYY-MM-DD',
                      controller: _deadlineCtrl,
                      isReadOnly: true,
                      prefixIcon: const Icon(
                        Icons.timer_outlined,
                        size: AppDimensions.iconMD,
                      ),
                      onTap: () => _pickDate(_deadlineCtrl),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceXL),

              // Cover image
              ImageUploadField(
                label: 'Cover Image',
                onPicked: (f) => setState(() => _coverImage = f),
                helperText: 'Optional — shown on the event card.',
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              PrimaryButton(
                label: 'Create Event',
                icon: Icons.event_available_outlined,
                isLoading: state.isLoading,
                onPressed: _onSubmit,
              ),

              const SizedBox(height: AppDimensions.spaceXXL),
            ],
          ),
        ),
      ),
    );
  }
}
