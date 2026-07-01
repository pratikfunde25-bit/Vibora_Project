import 'package:equatable/equatable.dart';

enum MessageType { text, image, file, event }

class ChatMessageEntity extends Equatable {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime sentAt;
  final bool isRead;
  final String? mediaUrl;

  const ChatMessageEntity({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    required this.content,
    this.type = MessageType.text,
    required this.sentAt,
    this.isRead = false,
    this.mediaUrl,
  });

  @override
  List<Object?> get props => [id, chatId, senderId, sentAt];
}

class ChatEntity extends Equatable {
  final String id;
  final List<String> participantIds;
  final List<String> participantNames;
  final List<String?> participantAvatars;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastSenderId;
  final int unreadCount;
  final bool isGroupChat;
  final String? groupName;
  final String? groupAvatar;
  final String? eventId; // if event group chat

  const ChatEntity({
    required this.id,
    required this.participantIds,
    required this.participantNames,
    this.participantAvatars = const [],
    this.lastMessage,
    this.lastMessageAt,
    this.lastSenderId,
    this.unreadCount = 0,
    this.isGroupChat = false,
    this.groupName,
    this.groupAvatar,
    this.eventId,
  });

  @override
  List<Object?> get props => [id];
}
