import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/file_picker_helper.dart';
import '../../../../core/router/route_names.dart';
import '../../../../shared_widgets/layout/app_scaffold.dart';
import '../../../../shared_widgets/inputs/app_text_field.dart';
import '../../../../shared_widgets/buttons/primary_button.dart';
import '../../../../shared_widgets/dialogs/loading_dialog.dart';
import '../providers/campaign_provider.dart';
import '../models/campaign_models.dart';
import '../widgets/upi_screenshot_uploader.dart';

/// Donation submission screen.
///
/// Voter enters:
///   1. Amount in INR
///   2. UPI transaction ID
///   3. UPI payment screenshot
///
/// On submit:
///   - Multipart POST to /donations
///   - Fraud check runs in background (not visible to voter)
///   - Navigates to donation status screen on success
class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key, required this.campaignId});
  final String campaignId;

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _txnIdCtrl = TextEditingController();
  PickedFile? _screenshot;
  bool _screenshotError = false;

  static const _quickAmounts = [100, 250, 500, 1000, 2500, 5000];

  @override
  void dispose() {
    _amountCtrl.dispose();
    _txnIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    context.hideKeyboard();

    // Validate form fields
    final formValid = _formKey.currentState!.validate();

    // Validate screenshot separately
    setState(() => _screenshotError = _screenshot == null);

    if (!formValid || _screenshot == null) return;

    // Show loading
    LoadingDialog.show(context, message: 'Submitting donation...');

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;

    final success = await ref
        .read(donateProvider.notifier)
        .submit(
          request: DonateRequest(
            campaignId: widget.campaignId,
            amountClaimed: amount,
            upiTransactionId: _txnIdCtrl.text.trim(),
          ),
          screenshot: _screenshot!,
        );

    if (!mounted) return;
    LoadingDialog.hide(context);

    if (success) {
      final donation = ref.read(donateProvider).donation;
      if (donation != null) {
        context.goNamed(
          RouteNames.donationStatus,
          pathParameters: {'id': donation.id},
          extra: donation,
        );
      }
    } else {
      final error = ref.read(donateProvider).errorMessage;
      if (error.isNotEmpty) context.showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Make a Donation',
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.pagePaddingH,
            vertical: AppDimensions.pagePaddingTop,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── How to donate banner ──────────
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.primary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How to Donate',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.primaryDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ...[
                            '1. Pay via any UPI app to the campaign UPI ID.',
                            '2. Enter the exact amount paid below.',
                            '3. Copy your UPI transaction ID.',
                            '4. Upload the payment confirmation screenshot.',
                          ].map(
                            (s) => Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                s,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ── Amount ─────────────────────────
              Text('Step 1 — Enter Amount', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceMD),

              AppTextField(
                label: 'Donation Amount (₹)',
                hint: 'Enter amount in rupees',
                controller: _amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.next,
                validator: Validators.donationAmount,
                prefixIcon: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14),
                  child: Text('₹', style: AppTextStyles.heading3),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                ],
              ),

              const SizedBox(height: AppDimensions.spaceMD),

              // Quick amount chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amt) {
                  return GestureDetector(
                    onTap: () {
                      _amountCtrl.text = amt.toString();
                      _formKey.currentState?.validate();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(
                          AppDimensions.radiusFull,
                        ),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Text(
                        '₹$amt',
                        style: AppTextStyles.captionMedium.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ── UPI Transaction ID ─────────────
              Text(
                'Step 2 — UPI Transaction ID',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: AppDimensions.spaceMD),

              AppTextField(
                label: 'UPI Transaction ID',
                hint: 'e.g. YBLP123456789012',
                controller: _txnIdCtrl,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                validator: Validators.upiTransactionId,
                helperText: 'Find this in your UPI app under payment history.',
                prefixIcon: const Icon(
                  Icons.receipt_outlined,
                  size: AppDimensions.iconMD,
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ── Screenshot ─────────────────────
              Text('Step 3 — Upload Screenshot', style: AppTextStyles.heading3),
              const SizedBox(height: AppDimensions.spaceMD),

              UpiScreenshotUploader(
                pickedFile: _screenshot,
                hasError: _screenshotError,
                onPicked: (f) => setState(() {
                  _screenshot = f;
                  _screenshotError = false;
                }),
                onRemove: () => setState(() {
                  _screenshot = null;
                  _screenshotError = false;
                }),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ── Disclaimer ─────────────────────
              Container(
                padding: const EdgeInsets.all(AppDimensions.spaceMD),
                decoration: BoxDecoration(
                  color: AppColors.surfaceGrey,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
                  border: Border.all(color: AppColors.borderGrey),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.verified_user_outlined,
                      color: AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your donation will be reviewed and verified '
                        'by the Corporator. You will receive a '
                        'receipt once accepted.',
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppDimensions.spaceXXL),

              // ── Submit button ──────────────────
              PrimaryButton(
                label: 'Submit Donation',
                icon: Icons.volunteer_activism_outlined,
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
