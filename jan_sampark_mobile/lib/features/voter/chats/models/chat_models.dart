import '../../../../core/utils/date_formatter.dart';

// ─────────────────────────────────────────────
// Chat Model
// ─────────────────────────────────────────────

class ChatModel {
  const ChatModel({
    required this.id,
    required this.title,
    required this.isOpen,
    required this.createdByName,
    required this.createdByRole,
    required this.createdById,
    required this.messageCount,
    this.description,
    this.lastMessageAt,
    this.isPinned = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String createdByName;
  final String createdByRole;
  final String createdById;
  final bool isOpen;
  final bool isPinned;
  final int messageCount;
  final String? description;
  final DateTime? lastMessageAt;
  final DateTime? createdAt;

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      isOpen: json['is_open'] as bool? ?? true,
      isPinned: json['is_pinned'] as bool? ?? false,
      createdByName: json['created_by_name'] as String? ?? '',
      createdByRole: json['created_by_role'] as String? ?? '',
      createdById: json['created_by_id'] as String? ?? '',
      messageCount: json['message_count'] as int? ?? 0,
      lastMessageAt: DateFormatter.fromApiString(
        json['last_message_at'] as String?,
      ),
      createdAt: DateFormatter.fromApiString(json['created_at'] as String?),
    );
  }
}

// ─────────────────────────────────────────────
// Chat List Response
// ─────────────────────────────────────────────

class ChatListResponse {
  const ChatListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<ChatModel> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory ChatListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => ChatModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ChatListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 20,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Reaction
// ─────────────────────────────────────────────

class ReactionSummary {
  const ReactionSummary({
    required this.emoji,
    required this.count,
    required this.reacted,
  });

  final String emoji;
  final int count;
  final bool reacted;

  factory ReactionSummary.fromJson(Map<String, dynamic> json) {
    return ReactionSummary(
      emoji: json['emoji'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      reacted: json['reacted'] as bool? ?? false,
    );
  }
}

// ─────────────────────────────────────────────
// Message
// ─────────────────────────────────────────────

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.chatId,
    required this.senderName,
    required this.senderRole,
    required this.senderId,
    required this.messageType,
    required this.content,
    required this.createdAt,
    this.reactions = const [],
    this.reactionCount = 0,
    this.feedbackCount = 0,
    this.isPinned = false,
    this.referenceId,
  });

  final String id;
  final String chatId;
  final String senderName;
  final String senderRole;
  final String senderId;
  final String messageType;
  final String content;
  final DateTime createdAt;
  final List<ReactionSummary> reactions;
  final int reactionCount;
  final int feedbackCount;
  final bool isPinned;
  final String? referenceId;

  /// Returns the emoji the current viewer reacted with, or null.
  String? get myReaction {
    final r = reactions.where((r) => r.reacted).firstOrNull;
    return r?.emoji;
  }

  /// Returns a copy with updated reactions list.
  ChatMessage copyWithReactions(List<ReactionSummary> reactions) {
    return ChatMessage(
      id: id,
      chatId: chatId,
      senderName: senderName,
      senderRole: senderRole,
      senderId: senderId,
      messageType: messageType,
      content: content,
      createdAt: createdAt,
      reactions: reactions,
      reactionCount: reactions.fold(0, (sum, r) => sum + r.count),
      feedbackCount: feedbackCount,
      isPinned: isPinned,
      referenceId: referenceId,
    );
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final reactionList = (json['reactions'] as List<dynamic>? ?? [])
        .map((e) => ReactionSummary.fromJson(e as Map<String, dynamic>))
        .toList();
    return ChatMessage(
      id: json['id'] as String? ?? '',
      chatId: json['chat_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? '',
      senderRole: json['sender_role'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      content: json['content'] as String? ?? '',
      reactions: reactionList,
      reactionCount: json['reaction_count'] as int? ?? 0,
      feedbackCount: json['feedback_count'] as int? ?? 0,
      isPinned: json['is_pinned'] as bool? ?? false,
      referenceId: json['reference_id'] as String?,
      createdAt:
          DateFormatter.fromApiString(json['created_at'] as String?) ??
          DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────
// Message List Response
// ─────────────────────────────────────────────

class MessageListResponse {
  const MessageListResponse({
    required this.data,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  final List<ChatMessage> data;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;

  bool get hasMore => page < totalPages;

  factory MessageListResponse.fromJson(Map<String, dynamic> json) {
    final list = (json['data'] as List<dynamic>? ?? [])
        .map((e) => ChatMessage.fromJson(e as Map<String, dynamic>))
        .toList();
    return MessageListResponse(
      data: list,
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      pageSize: json['page_size'] as int? ?? 50,
      totalPages: json['total_pages'] as int? ?? 1,
    );
  }
}

// ─────────────────────────────────────────────
// Reaction Request
// ─────────────────────────────────────────────

class ReactRequest {
  const ReactRequest({required this.emoji});
  final String emoji;
  Map<String, dynamic> toJson() => {'emoji': emoji};
}

// ─────────────────────────────────────────────
// Feedback Request
// ─────────────────────────────────────────────

class FeedbackRequest {
  const FeedbackRequest({required this.text});
  final String text;
  Map<String, dynamic> toJson() => {'text': text};
}
