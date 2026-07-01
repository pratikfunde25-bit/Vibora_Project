import '../../domain/entities/chat_entity.dart';

abstract class ChatRepository {
  Stream<List<ChatEntity>> getChats(String userId);
  Stream<List<ChatMessageEntity>> getMessages(String chatId);
  Future<void> sendMessage(ChatMessageEntity message);
  Future<String> createOrGetChat(List<String> participantIds, {bool isGroup = false, String? groupName, String? eventId});
  Future<void> markAsRead(String chatId, String userId);
}
