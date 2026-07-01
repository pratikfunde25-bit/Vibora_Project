import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';
import '../../domain/repositories/chat_repository.dart';
import '../models/chat_model.dart';

class ChatRepositoryImpl implements ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<ChatEntity>> getChats(String userId) {
    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: userId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatModel.fromFirestore(doc)).toList());
  }

  @override
  Stream<List<ChatMessageEntity>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ChatMessageModel.fromFirestore(doc)).toList());
  }

  @override
  Future<void> sendMessage(ChatMessageEntity message) async {
    final msgModel = ChatMessageModel(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      senderName: message.senderName,
      senderAvatar: message.senderAvatar,
      content: message.content,
      type: message.type,
      sentAt: message.sentAt,
      isRead: message.isRead,
      mediaUrl: message.mediaUrl,
    );

    final batch = _firestore.batch();
    
    // Add message
    final msgDoc = _firestore.collection('chats').doc(message.chatId).collection('messages').doc();
    batch.set(msgDoc, msgModel.toFirestore());

    // Update last message in chat
    batch.update(_firestore.collection('chats').doc(message.chatId), {
      'lastMessage': message.content,
      'lastMessageAt': Timestamp.fromDate(message.sentAt),
      'lastSenderId': message.senderId,
    });

    await batch.commit();
  }

  @override
  Future<String> createOrGetChat(List<String> participantIds, {bool isGroup = false, String? groupName, String? eventId}) async {
    // For 1-on-1 chats, check if already exists
    if (!isGroup && participantIds.length == 2) {
      participantIds.sort();
      final existing = await _firestore
          .collection('chats')
          .where('participantIds', isEqualTo: participantIds)
          .where('isGroupChat', isEqualTo: false)
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    // For Community Chat (eventId), check if already exists
    if (eventId != null) {
      final existing = await _firestore
          .collection('chats')
          .where('eventId', isEqualTo: eventId)
          .limit(1)
          .get();
      
      if (existing.docs.isNotEmpty) {
        return existing.docs.first.id;
      }
    }

    // Create new chat
    final newDoc = _firestore.collection('chats').doc();
    final chatModel = ChatModel(
      id: newDoc.id,
      participantIds: participantIds,
      participantNames: const [], // Will be filled lazily or by UI
      isGroupChat: isGroup || eventId != null,
      groupName: groupName,
      eventId: eventId,
      lastMessageAt: DateTime.now(),
    );

    await newDoc.set(chatModel.toFirestore());
    return newDoc.id;
  }

  @override
  Future<void> markAsRead(String chatId, String userId) async {
    // Simplified: in a real app, you'd track unread counts per user
    await _firestore.collection('chats').doc(chatId).update({'unreadCount': 0});
  }
}
