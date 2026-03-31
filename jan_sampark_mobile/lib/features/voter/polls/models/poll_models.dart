import '../../../../core/utils/date_formatter.dart';

class PollOption {
  const PollOption({required this.optionId, required this.optionText});
  final String optionId;
  final String optionText;

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      optionId: json['option_id'] as String? ?? '',
      optionText: json['option_text'] as String? ?? '',
    );
  }
}

class PollModel {
  const PollModel({
    required this.id,
    required this.question,
    required this.pollType,
    required this.isAnonymous,
    required this.showResults,
    required this.status,
    required this.totalResponses,
    required this.createdByName,
    required this.hasVoted,
    this.options = const [],
    this.closesAt,
    this.publishedAt,
    this.createdAt,
  });

  final String id;
  final String question;
  final String pollType;
  final bool isAnonymous;
  final bool showResults;
  final String status;
  final int totalResponses;
  final String createdByName;
  final bool hasVoted;
  final List<PollOption> options;
  final String? closesAt;
  final DateTime? publishedAt;
  final DateTime? createdAt;

  bool get isMultipleChoice => pollType == 'multiple_choice';
  bool get isYesNo => pollType == 'yes_no';
  bool get isRating => pollType == 'rating';
  bool get isOpenEnded => pollType == 'open_ended';

  bool get isOpen =>
      status == 'published' &&
      (closesAt == null ||
          closesAt!.compareTo(
                DateTime.now().toIso8601String().substring(0, 10),
              ) >=
              0);

  factory PollModel.fromJson(Map<String, dynamic> json) {
    final opts = (json['options'] as List<dynamic>? ?? [])
        .map((e) => PollOption.fromJson(e as Map<String, dynamic>))
        .toList();
    return PollModel(
      id: json['id'] as String? ?? '',
      question: json['question'] as String? ?? '',
      pollType: json['poll_type'] as String? ?? '',
      isAnonymous: json['is_anonymous'] as bool? ?? true,
      showResults: json['show_results'] as bool? ?? true,
      status: json['status'] as String? ?? '',
      totalResponses: json['total_responses'] as int? ?? 0,
      createdByName: json['created_by_name'] as String? ?? '',
      hasVoted: json['has_voted'] as bool? ?? false,
      options: opts,
      closesAt: json['closes_at'] as String?,
      publishedAt: DateFormatter.fromApiString(json['published_at'] as String?),
      createdAt: DateFormatter.fromApiString(json['created_at'] as String?),
    );
  }
}

class PollListResponse {
  const PollListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<PollModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory PollListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => PollModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return PollListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Results
// ─────────────────────────────────────────────

class OptionResult {
  const OptionResult({
    required this.optionId,
    required this.optionText,
    required this.voteCount,
    required this.percentage,
  });
  final String optionId;
  final String optionText;
  final int voteCount;
  final double percentage;

  factory OptionResult.fromJson(Map<String, dynamic> json) {
    return OptionResult(
      optionId: json['option_id'] as String? ?? '',
      optionText: json['option_text'] as String? ?? '',
      voteCount: json['vote_count'] as int? ?? 0,
      percentage: _toDouble(json['percentage']),
    );
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return 0.0;
  }
}

class PollResults {
  const PollResults({
    required this.pollId,
    required this.pollType,
    required this.totalResponses,
    required this.hasVoted,
    this.optionResults = const [],
    this.averageRating,
    this.ratingDistribution = const {},
    this.openResponses = const [],
    this.callerResponse,
  });

  final String pollId;
  final String pollType;
  final int totalResponses;
  final bool hasVoted;
  final List<OptionResult> optionResults;
  final double? averageRating;
  final Map<String, int> ratingDistribution;
  final List<String> openResponses;
  final dynamic callerResponse;

  factory PollResults.fromJson(Map<String, dynamic> json) {
    final opts = (json['option_results'] as List<dynamic>? ?? [])
        .map((e) => OptionResult.fromJson(e as Map<String, dynamic>))
        .toList();
    final ratingMap = <String, int>{};
    final rawRating = json['rating_distribution'];
    if (rawRating is Map) {
      rawRating.forEach((k, v) {
        ratingMap[k.toString()] = (v as int?) ?? 0;
      });
    }
    return PollResults(
      pollId: json['poll_id'] as String? ?? '',
      pollType: json['poll_type'] as String? ?? '',
      totalResponses: json['total_responses'] as int? ?? 0,
      hasVoted: json['has_voted'] as bool? ?? false,
      optionResults: opts,
      averageRating: OptionResult._toDouble(json['average_rating']),
      ratingDistribution: ratingMap,
      openResponses: (json['open_responses'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      callerResponse: json['caller_response'],
    );
  }
}

// ─────────────────────────────────────────────
// Vote Request
// ─────────────────────────────────────────────

class VoteRequest {
  const VoteRequest({this.optionId, this.rating, this.openResponse});

  final String? optionId;
  final int? rating;
  final String? openResponse;

  Map<String, dynamic> toJson() => {
    if (optionId != null) 'option_id': optionId,
    if (rating != null) 'rating': rating,
    if (openResponse != null) 'open_response': openResponse,
  };
}
