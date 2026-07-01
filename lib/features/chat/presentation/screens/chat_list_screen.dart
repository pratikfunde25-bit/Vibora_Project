import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_widgets.dart';
import '../controllers/chat_controller.dart';
import '../../domain/entities/chat_entity.dart';

class ChatListScreen extends ConsumerWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(userChatsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text('Messages', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded, color: Colors.white), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_comment_rounded, color: Colors.white),
        onPressed: () {
          // In a real app, show a search/contacts screen
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Search for people to start chatting!')));
        },
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return const AppEmptyState(
              title: 'No Messages Yet',
              subtitle: 'Join an event community or start a private chat!',
              icon: Icons.chat_bubble_outline_rounded,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListItem(chat: chat);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.white)),
        error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: Colors.red))),
      ),
    );
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatEntity chat;
  const _ChatListItem({required this.chat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(chat.isGroupChat ? Icons.groups_rounded : Icons.person_rounded, color: AppColors.primary),
        ),
        title: Text(
          chat.isGroupChat ? (chat.groupName ?? 'Community') : (chat.participantNames.firstOrNull ?? 'User'),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            chat.lastMessage ?? 'Start chatting...',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat.lastMessageAt != null)
              Text(
                DateFormat('HH:mm').format(chat.lastMessageAt!),
                style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10),
              ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          context.push('/chat/${chat.id}', extra: {
            'name': chat.isGroupChat ? (chat.groupName ?? 'Community') : (chat.participantNames.firstOrNull ?? 'User'),
          });
        },
      ),
    );
  }
}
