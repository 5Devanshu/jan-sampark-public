import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../../../voter/chats/models/chat_models.dart';
import '../../../voter/chats/repositories/chat_repository.dart'
    show ChatRepository;
import '../models/leader_chat_models.dart';

class LeaderChatRepository extends BaseRepository {
  const LeaderChatRepository(super.dio);

  // ── Create chat thread ──────────────────────

  Future<ApiResponse<ChatModel>> createChat(CreateChatRequest request) async {
    return safeCall(() async {
      final res = await dio.post(
        AppConstants.endpointChats,
        data: request.toJson(),
      );
      return ChatModel.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── Post message ────────────────────────────

  Future<ApiResponse<ChatMessage>> postMessage({
    required String chatId,
    required PostMessageRequest request,
  }) async {
    return safeCall(() async {
      final res = await dio.post(
        '${AppConstants.endpointChats}/$chatId/messages',
        data: request.toJson(),
      );
      return ChatMessage.fromJson(res.data as Map<String, dynamic>);
    });
  }

  // ── Pin message ─────────────────────────────

  Future<ApiResponse<Map<String, dynamic>>> pinMessage({
    required String chatId,
    required String messageId,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointChats}/$chatId/messages/$messageId/pin',
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ── Close / Reopen chat ─────────────────────

  Future<ApiResponse<Map<String, dynamic>>> toggleChatOpen({
    required String chatId,
    required bool isOpen,
  }) async {
    return safeCall(() async {
      final res = await dio.patch(
        '${AppConstants.endpointChats}/$chatId',
        data: {'is_open': isOpen},
      );
      return res.data as Map<String, dynamic>;
    });
  }

  // ── Delegate list + room fetching to voter repository ──

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
}

final leaderChatRepositoryProvider = Provider<LeaderChatRepository>((ref) {
  return LeaderChatRepository(ref.watch(dioProvider));
});
