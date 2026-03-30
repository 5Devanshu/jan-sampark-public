// lib/features/voter/profile/screens/edit_profile_screen.dart
//
// Tabbed edit screen supporting three sections:
//   basic → name, language
//   location → area + ward (reuses RegistrationStepTwo widgets)
//   demographics → gender, DOB, religion, education, occupation, income, family

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/inputs/app_dropdown.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../features/auth/providers/auth_notifier.dart';
import '../models/voter_profile_models.dart';
import '../providers/voter_profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.initialSection = 'basic'});

  /// 'basic' | 'location' | 'demographics'
  final String initialSection;

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  // ── Basic ─────────────────────────────────────
  final _nameCtrl     = TextEditingController();
  String? _language;

  // ── Location ──────────────────────────────────
  String? _selectedAreaId;
  String? _selectedWardId;

  // ── Demographics ──────────────────────────────
  String? _gender;
  String? _genderSpecify;
  final _genderSpecifyCtrl = TextEditingController();
  final _dobCtrl           = TextEditingController();
  String? _religion;
  String? _education;
  String? _occupation;
  String? _profession;
  String? _income;
  final _adultsCtrl = TextEditingController();
  final _kidsCtrl   = TextEditingController();

  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  // ── Options ───────────────────────────────────
  static const _languages = {
    'english': 'English', 'hindi': 'Hindi', 'marathi': 'Marathi',
  };
  static const _genders = {
    'male': 'Male', 'female': 'Female', 'other': 'Other',
    'prefer_not': 'Prefer not to say',
  };
  static const _religions = {
    'hindu': 'Hindu', 'muslim': 'Muslim', 'christian': 'Christian',
    'sikh': 'Sikh', 'buddhist': 'Buddhist', 'jain': 'Jain',
    'other': 'Other', 'prefer_not': 'Prefer not to say',
  };
  static const _educations = {
    'no_formal': 'No Formal Education', 'primary': 'Primary School',
    'secondary': 'Secondary School',
    'higher_secondary': 'Higher Secondary (12th)',
    'diploma': 'Diploma', 'graduate': 'Graduate',
    'post_graduate': 'Post Graduate', 'doctorate': 'Doctorate',
  };
  static const _occupations = {
    'employed_private': 'Private Sector Employee',
    'employed_govt': 'Government Employee',
    'self_employed': 'Self-Employed / Business',
    'farmer': 'Farmer', 'student': 'Student',
    'homemaker': 'Homemaker', 'retired': 'Retired',
    'unemployed': 'Unemployed', 'other': 'Other',
  };
  static const _incomes = {
    'below_2l':      'Below ₹2 Lakh',
    '2l_to_5l':      '₹2L – ₹5L',
    '5l_to_15l':     '₹5L – ₹15L',
    '15l_to_40l':    '₹15L – ₹40L',
    'above_40l':     'Above ₹40 Lakh',
    'prefer_not':    'Prefer not to say',
  };

  @override
  void initState() {
    super.initState();
    final sections = ['basic', 'location', 'demographics'];
    final initialIdx = sections.indexOf(widget.initialSection).clamp(0, 2);
    _tabs = TabController(length: 3, vsync: this, initialIndex: initialIdx);

    // Prefill from existing profile
    final profile = ref.read(voterProfileProvider).valueOrNull;
    if (profile != null) _prefill(profile);
  }

  void _prefill(VoterProfile p) {
    _nameCtrl.text         = p.fullName;
    _language              = p.language;
    _selectedAreaId        = p.location.areaId;
    _selectedWardId        = p.location.wardId;
    final vp               = p.voterProfile;
    if (vp != null) {
      _gender              = vp.gender;
      _dobCtrl.text        = vp.dateOfBirth ?? '';
      _genderSpecifyCtrl.text = vp.genderSpecify ?? '';
      _religion            = vp.religion;
      _education           = vp.education;
      _occupation          = vp.occupation;
      _profession          = vp.profession;
      _income              = vp.annualIncomeRange;
      _adultsCtrl.text     = vp.familyAdults?.toString() ?? '';
      _kidsCtrl.text       = vp.familyKids?.toString()   ?? '';
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    _nameCtrl.dispose();
    _genderSpecifyCtrl.dispose();
    _dobCtrl.dispose();
    _adultsCtrl.dispose();
    _kidsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? true)) return;
    setState(() => _isSaving = true);

    final req = ProfileUpdateRequest(
      fullName:          _nameCtrl.text.trim().isEmpty ? null : _nameCtrl.text.trim(),
      language:          _language,
      gender:            _gender,
      genderSpecify:     _gender == 'other' ? _genderSpecifyCtrl.text.trim() : null,
      dateOfBirth:       _dobCtrl.text.trim().isEmpty ? null : _dobCtrl.text.trim(),
      religion:          _religion,
      education:         _education,
      occupation:        _occupation,
      annualIncomeRange: _income,
      familyAdults: int.tryParse(_adultsCtrl.text.trim()),
      familyKids:   int.tryParse(_kidsCtrl.text.trim()),
      wardId:  _selectedWardId,
      areaId:  _selectedAreaId,
    );

    final error = await ref
        .read(voterProfileProvider.notifier)
        .updateProfile(req);

    setState(() => _isSaving = false);

    if (!mounted) return;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: AppColors.error),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:         Text('Profile updated successfully'),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceGrey,
      appBar: AppBar(
        title:   const Text('Edit Profile'),
        leading: BackButton(onPressed: () => context.pop()),
        bottom: TabBar(
          controller:    _tabs,
          indicatorColor: AppColors.primary,
          labelColor:    AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Basic'),
            Tab(text: 'Location'),
            Tab(text: 'Demographics'),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: TabBarView(
          controller: _tabs,
          children: [
            _BasicTab(
              nameCtrl: _nameCtrl,
              language: _language,
              onLanguageChanged: (v) => setState(() => _language = v),
            ),
            _LocationTab(
              selectedAreaId: _selectedAreaId,
              selectedWardId: _selectedWardId,
              onAreaChanged: (v) => setState(() {
                _selectedAreaId = v;
                _selectedWardId = null;
              }),
              onWardChanged: (v) => setState(() => _selectedWardId = v),
            ),
            _DemographicsTab(
              gender:             _gender,
              genderSpecifyCtrl:  _genderSpecifyCtrl,
              dobCtrl:            _dobCtrl,
              religion:           _religion,
              education:          _education,
              occupation:         _occupation,
              income:             _income,
              adultsCtrl:         _adultsCtrl,
              kidsCtrl:           _kidsCtrl,
              onGenderChanged:    (v) => setState(() => _gender    = v),
              onReligionChanged:  (v) => setState(() => _religion  = v),
              onEducationChanged: (v) => setState(() => _education = v),
              onOccupationChanged:(v) => setState(() => _occupation= v),
              onIncomeChanged:    (v) => setState(() => _income    = v),
              genders:     _genders,
              religions:   _religions,
              educations:  _educations,
              occupations: _occupations,
              incomes:     _incomes,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: PrimaryButton(
            label:     'Save Changes',
            onPressed: _save,
            isLoading: _isSaving,
          ),
        ),
      ),
    );
  }
}

// ── Basic Tab ─────────────────────────────────

class _BasicTab extends StatelessWidget {
  const _BasicTab({
    required this.nameCtrl,
    required this.language,
    required this.onLanguageChanged,
  });

  final TextEditingController nameCtrl;
  final String?               language;
  final void Function(String?) onLanguageChanged;

  static const _langItems = {
    'english': 'English', 'hindi': 'Hindi', 'marathi': 'Marathi',
  };

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        const SizedBox(height: 12),
        AppTextField(
          controller:  nameCtrl,
          label:       'Full Name',
          hint:        'Enter your full name',
          prefixIcon:  Icons.person_outline,
          validator:   (v) => (v?.trim().isEmpty ?? true)
              ? 'Name is required' : null,
        ),
        const SizedBox(height: 16),
        AppDropdown<String>(
          label:    'Language',
          hint:     'Select preferred language',
          value:    language,
          items:    _langItems.entries.map((e) => DropdownMenuItem(
            value: e.key, child: Text(e.value),
          )).toList(),
          onChanged: onLanguageChanged,
        ),
      ],
    );
  }
}

// ── Location Tab ─────────────────────────────

class _LocationTab extends ConsumerWidget {
  const _LocationTab({
    required this.selectedAreaId,
    required this.selectedWardId,
    required this.onAreaChanged,
    required this.onWardChanged,
  });

  final String?              selectedAreaId;
  final String?              selectedWardId;
  final void Function(String?) onAreaChanged;
  final void Function(String?) onWardChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final areasAsync = ref.watch(areasProvider);
    final wardsAsync = ref.watch(
        wardsForAreaProvider(selectedAreaId ?? ''));

    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        const SizedBox(height: 12),
        Text(
          'Update your registered ward and area.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: 20),

        // ── Area ────────────────────────────────
        areasAsync.when(
          loading: () => const LinearProgressIndicator(),
          error:   (_, __) => Text(
            'Failed to load areas',
            style: AppTextStyles.caption.copyWith(color: AppColors.error),
          ),
          data: (areas) => AppDropdown<String>(
            label:    'Area',
            hint:     'Select your area',
            value:    selectedAreaId,
            items:    areas.map((a) => DropdownMenuItem(
              value: a.id,
              child: Text(a.areaName),
            )).toList(),
            onChanged: (v) {
              onAreaChanged(v);
              onWardChanged(null);
            },
          ),
        ),

        const SizedBox(height: 16),

        // ── Ward ────────────────────────────────
        wardsAsync.when(
          loading: () => const LinearProgressIndicator(),
          error:   (_, __) => const SizedBox.shrink(),
          data: (wards) => AppDropdown<String>(
            label:    'Ward',
            hint:     selectedAreaId == null
                ? 'Select area first'
                : 'Select your ward',
            value:    selectedWardId,
            items:    wards.map((w) => DropdownMenuItem(
              value: w.id,
              child: Text(w.wardName),
            )).toList(),
            onChanged: wards.isEmpty ? null : onWardChanged,
          ),
        ),
      ],
    );
  }
}

// ── Demographics Tab ─────────────────────────

class _DemographicsTab extends StatelessWidget {
  const _DemographicsTab({
    required this.gender,
    required this.genderSpecifyCtrl,
    required this.dobCtrl,
    required this.religion,
    required this.education,
    required this.occupation,
    required this.income,
    required this.adultsCtrl,
    required this.kidsCtrl,
    required this.onGenderChanged,
    required this.onReligionChanged,
    required this.onEducationChanged,
    required this.onOccupationChanged,
    required this.onIncomeChanged,
    required this.genders,
    required this.religions,
    required this.educations,
    required this.occupations,
    required this.incomes,
  });

  final String?               gender;
  final TextEditingController genderSpecifyCtrl;
  final TextEditingController dobCtrl;
  final String?               religion;
  final String?               education;
  final String?               occupation;
  final String?               income;
  final TextEditingController adultsCtrl;
  final TextEditingController kidsCtrl;
  final void Function(String?) onGenderChanged;
  final void Function(String?) onReligionChanged;
  final void Function(String?) onEducationChanged;
  final void Function(String?) onOccupationChanged;
  final void Function(String?) onIncomeChanged;
  final Map<String, String>   genders;
  final Map<String, String>   religions;
  final Map<String, String>   educations;
  final Map<String, String>   occupations;
  final Map<String, String>   incomes;

  DropdownMenuItem<String> _item(String k, String v) =>
      DropdownMenuItem(value: k, child: Text(v));

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppDimensions.pagePaddingH),
      children: [
        const SizedBox(height: 12),

        AppDropdown<String>(
          label: 'Gender', hint: 'Select gender', value: gender,
          items: genders.entries.map((e) => _item(e.key, e.value)).toList(),
          onChanged: onGenderChanged,
        ),

        if (gender == 'other') ...[
          const SizedBox(height: 12),
          AppTextField(
            controller: genderSpecifyCtrl,
            label: 'Please specify', hint: 'Describe your gender',
          ),
        ],

        const SizedBox(height: 12),

        AppTextField(
          controller: dobCtrl,
          label:      'Date of Birth',
          hint:       'YYYY-MM-DD',
          prefixIcon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.datetime,
          validator: (v) {
            if (v == null || v.isEmpty) return null;
            final reg = RegExp(r'^\d{4}-\d{2}-\d{2}$');
            return reg.hasMatch(v) ? null : 'Use format YYYY-MM-DD';
          },
          onTap: () async {
            FocusScope.of(context).requestFocus(FocusNode());
            final now = DateTime.now();
            final picked = await showDatePicker(
              context:          context,
              initialDate:      now.subtract(const Duration(days: 365 * 25)),
              firstDate:        DateTime(1920),
              lastDate:         now.subtract(const Duration(days: 365 * 18)),
              builder: (ctx, child) => Theme(
                data: Theme.of(ctx).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                  ),
                ),
                child: child!,
              ),
            );
            if (picked != null) {
              dobCtrl.text =
                  '${picked.year.toString().padLeft(4, '0')}'
                  '-${picked.month.toString().padLeft(2, '0')}'
                  '-${picked.day.toString().padLeft(2, '0')}';
            }
          },
        ),

        const SizedBox(height: 12),

        AppDropdown<String>(
          label: 'Religion', hint: 'Select religion', value: religion,
          items: religions.entries.map((e) => _item(e.key, e.value)).toList(),
          onChanged: onReligionChanged,
        ),

        const SizedBox(height: 12),

        AppDropdown<String>(
          label: 'Education', hint: 'Select education', value: education,
          items: educations.entries.map((e) => _item(e.key, e.value)).toList(),
          onChanged: onEducationChanged,
        ),

        const SizedBox(height: 12),

        AppDropdown<String>(
          label: 'Occupation', hint: 'Select occupation', value: occupation,
          items: occupations.entries.map((e) => _item(e.key, e.value)).toList(),
          onChanged: onOccupationChanged,
        ),

        const SizedBox(height: 12),

        AppDropdown<String>(
          label: 'Annual Income Range', hint: 'Select income range',
          value: income,
          items: incomes.entries.map((e) => _item(e.key, e.value)).toList(),
          onChanged: onIncomeChanged,
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: adultsCtrl,
                label: 'Family Adults',
                hint:  'e.g. 3',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final n = int.tryParse(v);
                  return (n == null || n < 1 || n > 50)
                      ? '1–50' : null;
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: kidsCtrl,
                label: 'Family Kids',
                hint:  'e.g. 1',
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return null;
                  final n = int.tryParse(v);
                  return (n == null || n < 0 || n > 30)
                      ? '0–30' : null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}