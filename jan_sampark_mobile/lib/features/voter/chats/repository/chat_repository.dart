import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/chat_models.dart';

class ChatRepository extends BaseRepository {
  const ChatRepository(super.dio);

  // ─────────────────────────────────────────────
  // Chats
  // ─────────────────────────────────────────────

  Future<ApiResponse<ChatListResponse>> fetchChats({
    int page = 1,
    int pageSize = 20,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        AppConstants.endpointChats,
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return ChatListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  Future<ApiResponse<ChatModel>> fetchChatDetail(String chatId) async {
    return safeCall(() async {
      final res = await dio.get('${AppConstants.endpointChats}/$chatId');
      return ChatModel.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // Messages
  // ─────────────────────────────────────────────

  Future<ApiResponse<MessageListResponse>> fetchMessages({
    required String chatId,
    int page = 1,
    int pageSize = 50,
  }) async {
    return safeCall(() async {
      final res = await dio.get(
        '${AppConstants.endpointChats}/$chatId/messages',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return MessageListResponse.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ─────────────────────────────────────────────
  // React
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> reactToMessage({
    required String chatId,
    required String messageId,
    required ReactRequest request,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        '${AppConstants.endpointChats}/$chatId/messages/$messageId/react',
        data: request.toJson(),
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ─────────────────────────────────────────────
  // Feedback
  // ─────────────────────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> submitFeedback({
    required String chatId,
    required String messageId,
    required FeedbackRequest request,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        '${AppConstants.endpointChats}/$chatId/messages/$messageId/feedback',
        data: request.toJson(),
      );
      return res.data as Map<String, dynamic>;
    });
  }
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(dioProvider));
});
