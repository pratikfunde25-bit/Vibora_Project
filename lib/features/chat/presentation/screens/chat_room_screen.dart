import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../controllers/chat_controller.dart';
import '../../domain/entities/chat_entity.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String recipientName;
  final String recipientAvatar;

  const ChatRoomScreen({
    super.key,
    required this.chatId,
    required this.recipientName,
    required this.recipientAvatar,
  });

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    ref.read(chatControllerProvider.notifier).sendMessage(widget.chatId, text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white10,
              child: Text(widget.recipientName[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.recipientName, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
                  Text('Community Discussion', style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 10, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                if (messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline_rounded, color: Colors.white.withOpacity(0.1), size: 64),
                        const SizedBox(height: 16),
                        Text('Start the conversation!', style: TextStyle(color: Colors.white.withOpacity(0.2), fontWeight: FontWeight.w600)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding: const EdgeInsets.all(20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isMe = msg.senderId == currentUser?.id;
                    return _MessageBubble(message: msg, isMe: isMe);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
              error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: MediaQuery.of(context).padding.bottom + 16, top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: TextField(
                controller: _messageController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessageEntity message;
  final bool isMe;
  const _MessageBubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isMe ? 20 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(message.senderName, style: const TextStyle(color: AppColors.primary, fontSize: 10, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
            ],
            Text(message.content, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('HH:mm').format(message.sentAt),
                style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
