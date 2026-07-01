import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat_entity.dart';

class ChatMessageModel extends ChatMessageEntity {
  const ChatMessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.content,
    super.type,
    required super.sentAt,
    super.isRead,
    super.mediaUrl,
  });

  factory ChatMessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderAvatar: data['senderAvatar'],
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere((e) => e.name == (data['type'] ?? 'text'), orElse: () => MessageType.text),
      sentAt: (data['sentAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
      mediaUrl: data['mediaUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderAvatar': senderAvatar,
      'content': content,
      'type': type.name,
      'sentAt': Timestamp.fromDate(sentAt),
      'isRead': isRead,
      'mediaUrl': mediaUrl,
    };
  }
}

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.participantIds,
    required super.participantNames,
    super.participantAvatars,
    super.lastMessage,
    super.lastMessageAt,
    super.lastSenderId,
    super.unreadCount,
    super.isGroupChat,
    super.groupName,
    super.groupAvatar,
    super.eventId,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      participantIds: List<String>.from(data['participantIds'] ?? []),
      participantNames: List<String>.from(data['participantNames'] ?? []),
      participantAvatars: List<String?>.from(data['participantAvatars'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageAt: data['lastMessageAt'] != null ? (data['lastMessageAt'] as Timestamp).toDate() : null,
      lastSenderId: data['lastSenderId'],
      unreadCount: data['unreadCount'] ?? 0,
      isGroupChat: data['isGroupChat'] ?? false,
      groupName: data['groupName'],
      groupAvatar: data['groupAvatar'],
      eventId: data['eventId'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'participantIds': participantIds,
      'participantNames': participantNames,
      'participantAvatars': participantAvatars,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
      'isGroupChat': isGroupChat,
      'groupName': groupName,
      'groupAvatar': groupAvatar,
      'eventId': eventId,
    };
  }
}
