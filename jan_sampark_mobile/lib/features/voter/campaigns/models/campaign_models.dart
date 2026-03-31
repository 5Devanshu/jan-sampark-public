import '../../../../core/utils/date_formatter.dart';

// ─────────────────────────────────────────────
// Campaign
// ─────────────────────────────────────────────

class CampaignModel {
  const CampaignModel({
    required this.id,
    required this.title,
    required this.description,
    required this.campaignType,
    required this.targetAmount,
    required this.amountCollected,
    required this.donationCount,
    required this.progressPct,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.createdByName,
    this.coverImageUrl,
    this.wardId,
    this.areaId,
    this.wardName,
    this.areaName,
    this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String campaignType;
  final double targetAmount;
  final double amountCollected;
  final int donationCount;
  final double progressPct;
  final String status;
  final String startDate;
  final String endDate;
  final String createdByName;
  final String? coverImageUrl;
  final String? wardId;
  final String? areaId;
  final String? wardName;
  final String? areaName;
  final DateTime? createdAt;

  bool get isActive => status == 'active';

  int get daysRemaining => DateFormatter.daysRemaining(endDate);

  factory CampaignModel.fromJson(Map<String, dynamic> json) {
    return CampaignModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      campaignType: json['campaign_type'] as String? ?? '',
      targetAmount: _toDouble(json['target_amount']),
      amountCollected: _toDouble(json['amount_collected']),
      donationCount: json['donation_count'] as int? ?? 0,
      progressPct: _toDouble(json['progress_pct']),
      status: json['status'] as String? ?? '',
      startDate: json['start_date'] as String? ?? '',
      endDate: json['end_date'] as String? ?? '',
      createdByName: json['created_by_name'] as String? ?? '',
      coverImageUrl: json['cover_image_url'] as String?,
      wardId: json['ward_id'] as String?,
      areaId: json['area_id'] as String?,
      wardName: json['ward_name'] as String?,
      areaName: json['area_name'] as String?,
      createdAt: DateFormatter.fromApiString(json['created_at'] as String?),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }
}

// ─────────────────────────────────────────────
// Paginated Campaign List Response
// ─────────────────────────────────────────────

class CampaignListResponse {
  const CampaignListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<CampaignModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory CampaignListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => CampaignModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return CampaignListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Donation
// ─────────────────────────────────────────────

class DonationModel {
  const DonationModel({
    required this.id,
    required this.campaignId,
    required this.campaignTitle,
    required this.voterId,
    required this.amountClaimed,
    required this.upiTransactionId,
    required this.screenshotUrl,
    required this.status,
    this.voterName,
    this.fraudFlags = const [],
    this.ocrExtractedAmount,
    this.verificationNote,
    this.receiptPdfUrl,
    this.verifiedAt,
    this.createdAt,
  });

  final String id;
  final String campaignId;
  final String campaignTitle;
  final String voterId;
  final double amountClaimed;
  final String upiTransactionId;
  final String screenshotUrl;
  final String status;
  final String? voterName;
  final List<FraudFlagModel> fraudFlags;
  final double? ocrExtractedAmount;
  final String? verificationNote;
  final String? receiptPdfUrl;
  final DateTime? verifiedAt;
  final DateTime? createdAt;

  bool get isPending => status == 'pending';
  bool get isPendingReview => status == 'pending_review';
  bool get isAccepted => status == 'accepted';
  bool get isRejected => status == 'rejected';
  bool get hasReceipt => receiptPdfUrl != null && receiptPdfUrl!.isNotEmpty;
  bool get hasFraudFlags => fraudFlags.isNotEmpty;

  factory DonationModel.fromJson(Map<String, dynamic> json) {
    final flags = (json['fraud_flags'] as List<dynamic>? ?? [])
        .map((e) => FraudFlagModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return DonationModel(
      id: json['id'] as String? ?? '',
      campaignId: json['campaign_id'] as String? ?? '',
      campaignTitle: json['campaign_title'] as String? ?? '',
      voterId: json['voter_id'] as String? ?? '',
      amountClaimed: CampaignModel._toDouble(json['amount_claimed']),
      upiTransactionId: json['upi_transaction_id'] as String? ?? '',
      screenshotUrl: json['screenshot_url'] as String? ?? '',
      status: json['status'] as String? ?? '',
      voterName: json['voter_name'] as String?,
      fraudFlags: flags,
      ocrExtractedAmount: json['ocr_extracted_amount'] != null
          ? CampaignModel._toDouble(json['ocr_extracted_amount'])
          : null,
      verificationNote: json['corporator_verification_note'] as String?,
      receiptPdfUrl: json['receipt_pdf_url'] as String?,
      verifiedAt: DateFormatter.fromApiString(json['verified_at'] as String?),
      createdAt: DateFormatter.fromApiString(json['created_at'] as String?),
    );
  }
}

class FraudFlagModel {
  const FraudFlagModel({required this.flag, required this.detail});

  final String flag;
  final String detail;

  factory FraudFlagModel.fromJson(Map<String, dynamic> json) {
    return FraudFlagModel(
      flag: json['flag'] as String? ?? '',
      detail: json['detail'] as String? ?? '',
    );
  }
}

// ─────────────────────────────────────────────
// Donate Request
// ─────────────────────────────────────────────

class DonateRequest {
  const DonateRequest({
    required this.campaignId,
    required this.amountClaimed,
    required this.upiTransactionId,
  });

  final String campaignId;
  final double amountClaimed;
  final String upiTransactionId;

  Map<String, String> toFormFields() => {
    'campaign_id': campaignId,
    'amount_claimed': amountClaimed.toStringAsFixed(2),
    'upi_transaction_id': upiTransactionId,
  };
}

// ─────────────────────────────────────────────
// Donation List Response
// ─────────────────────────────────────────────

class DonationListResponse {
  const DonationListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<DonationModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory DonationListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => DonationModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return DonationListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}
