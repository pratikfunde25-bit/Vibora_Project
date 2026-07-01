import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../../data/repositories/chat_repository_impl.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) => ChatRepositoryImpl());

final userChatsProvider = StreamProvider<List<ChatEntity>>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).getChats(user.id);
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessageEntity>, String>((ref, chatId) {
  return ref.watch(chatRepositoryProvider).getMessages(chatId);
});

class ChatController extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repo;
  final Ref _ref;

  ChatController(this._repo, this._ref) : super(const AsyncData(null));

  Future<void> sendMessage(String chatId, String content, {MessageType type = MessageType.text}) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) return;

    final message = ChatMessageEntity(
      id: '', // Firestore will generate
      chatId: chatId,
      senderId: user.id,
      senderName: user.name,
      senderAvatar: user.avatarUrl,
      content: content,
      type: type,
      sentAt: DateTime.now(),
    );

    await _repo.sendMessage(message);
  }

  Future<String> getOrCreateCommunityChat(String eventId, String eventTitle) async {
    final user = _ref.read(currentUserProvider);
    if (user == null) throw 'Not logged in';

    return await _repo.createOrGetChat(
      [user.id], 
      isGroup: true, 
      groupName: '$eventTitle Community',
      eventId: eventId,
    );
  }
}

final chatControllerProvider = StateNotifierProvider<ChatController, AsyncValue<void>>((ref) {
  return ChatController(ref.watch(chatRepositoryProvider), ref);
});
