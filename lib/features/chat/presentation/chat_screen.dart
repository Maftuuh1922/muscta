import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock chat list data
  final List<ChatItem> _chats = [
    ChatItem(
      id: '1',
      username: 'sarah_beats',
      displayName: 'Sarah Johnson',
      lastMessage: 'Just shared an amazing track with you! 🎵',
      timestamp: '2m',
      unreadCount: 2,
      isOnline: true,
      avatar: 'S',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108755-2616b332c6c3?w=100&h=100&fit=crop&crop=face',
      hasSharedMusic: true,
      sharedMusicTitle: 'Midnight City - M83',
    ),
    ChatItem(
      id: '2',
      username: 'rock_lover',
      displayName: 'Mike Rodriguez',
      lastMessage: 'That concert was incredible!',
      timestamp: '1h',
      unreadCount: 0,
      isOnline: false,
      avatar: 'M',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop&crop=face',
    ),
    ChatItem(
      id: '3',
      username: 'jazz_queen',
      displayName: 'Emma Wilson',
      lastMessage: 'Have you heard the new jazz album?',
      timestamp: '3h',
      unreadCount: 1,
      isOnline: true,
      avatar: 'E',
      avatarUrl: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop&crop=face',
    ),
  ];

  List<ChatItem> _filteredChats = [];

  @override
  void initState() {
    super.initState();
    _filteredChats = _chats;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterChats(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChats = _chats;
      } else {
        _filteredChats = _chats.where((chat) {
          return chat.displayName.toLowerCase().contains(query.toLowerCase()) ||
              chat.username.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(child: _buildChatList()),
        ],
      ),
      floatingActionButton: _buildNewChatButton(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Messages',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      centerTitle: false,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.edit_rounded, color: AppColors.primaryText, size: 22),
            onPressed: _startNewChat,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.searchBarBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.mutedText, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _filterChats,
              style: const TextStyle(fontSize: 14, color: AppColors.primaryText),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Search messages...',
                hintStyle: TextStyle(fontSize: 14, color: AppColors.mutedText),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    if (_filteredChats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.textsms_rounded, size: 56, color: AppColors.mutedText),
            SizedBox(height: 12),
            Text('No messages found', style: TextStyle(color: AppColors.mutedText)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) {
        return _buildChatItem(_filteredChats[index]);
      },
    );
  }

  Widget _buildChatItem(ChatItem chat) {
    return InkWell(
      onTap: () => _openChat(chat),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                _buildAvatar(chat, size: 48),
                if (chat.isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBackground, width: 2.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          chat.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ),
                      Text(
                        chat.timestamp,
                        style: TextStyle(
                          fontSize: 13,
                          color: chat.unreadCount > 0 ? AppColors.primaryPurple : AppColors.mutedText,
                          fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (chat.hasSharedMusic) ...[
                        const Icon(Icons.music_note_rounded, size: 16, color: AppColors.primaryPurple),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          chat.hasSharedMusic && chat.sharedMusicTitle != null
                              ? chat.sharedMusicTitle!
                              : chat.lastMessage,
                          style: TextStyle(
                            fontSize: 14,
                            color: chat.unreadCount > 0 ? AppColors.primaryText.withOpacity(0.9) : AppColors.mutedText,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w400 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryPurple,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              chat.unreadCount.toString(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(ChatItem chat, {double size = 48}) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: chat.avatarUrl != null
            ? Image.network(
                chat.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryPurple.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        chat.avatar,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: size * 0.4,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: AppColors.primaryPurple.withOpacity(0.6),
                child: Center(
                  child: Text(
                    chat.avatar,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: size * 0.4,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildNewChatButton() {
    return FloatingActionButton(
      onPressed: _startNewChat,
      backgroundColor: AppColors.primaryPurple,
      child: const Icon(Icons.edit_rounded, color: Colors.white),
    );
  }

  void _openChat(ChatItem chat) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ChatDetailScreen(chat: chat)),
    );
  }

  void _startNewChat() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('New Message', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryText)),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.group_add_rounded, color: AppColors.primaryPurple),
                title: Text('Create Group Chat', style: TextStyle(color: AppColors.primaryText)),
              ),
              ListTile(
                leading: Icon(Icons.person_add_rounded, color: AppColors.primaryPurple),
                title: Text('Message Friends', style: TextStyle(color: AppColors.primaryText)),
              ),
              ListTile(
                leading: Icon(Icons.music_note_rounded, color: AppColors.primaryPurple),
                title: Text('Share Music', style: TextStyle(color: AppColors.primaryText)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// Chat Detail Screen
class ChatDetailScreen extends StatefulWidget {
  final ChatItem chat;

  const ChatDetailScreen({super.key, required this.chat});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Mock messages
  final List<MessageItem> _messages = [
    MessageItem(
      id: '1',
      text: 'Hey! How are you doing?',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    ),
    MessageItem(
      id: '2',
      text: 'Good! Just discovered this amazing new artist',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 28)),
    ),
    MessageItem(
      id: '3',
      text: 'You should check this out! 🎵',
      isMe: false,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 25)),
      hasMusic: true,
      musicTitle: 'Midnight City',
      musicArtist: 'M83',
      musicCover: 'https://images.unsplash.com/photo-1571330735066-03aaa9429d89?w=300&h=300&fit=crop',
    ),
    MessageItem(
      id: '4',
      text: 'Wow, this is exactly my vibe! Thanks for sharing 😍',
      isMe: true,
      timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 22)),
    ),
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      appBar: _buildChatAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildMessagesList()),
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildChatAppBar() {
    return AppBar(
      backgroundColor: AppColors.primaryBackground,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          _buildSmallAvatar(),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chat.displayName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
              ),
              Text(
                widget.chat.isOnline ? 'Online' : 'Offline',
                style: TextStyle(
                  fontSize: 12,
                  color: widget.chat.isOnline ? AppColors.success : AppColors.mutedText,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            icon: const Icon(Icons.more_horiz_rounded, color: AppColors.primaryText),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  Widget _buildSmallAvatar() {
    return SizedBox(
      width: 36,
      height: 36,
      child: ClipOval(
        child: widget.chat.avatarUrl != null
            ? Image.network(
                widget.chat.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryPurple.withOpacity(0.6),
                    child: Center(
                      child: Text(
                        widget.chat.avatar,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              )
            : Container(
                color: AppColors.primaryPurple.withOpacity(0.6),
                child: Center(
                  child: Text(
                    widget.chat.avatar,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        return _buildMessageItem(_messages[index]);
      },
    );
  }

  BorderRadius _bubbleRadius(bool isMe) {
    return BorderRadius.only(
      topLeft: const Radius.circular(18),
      topRight: const Radius.circular(18),
      bottomLeft: Radius.circular(isMe ? 18 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 18),
    );
  }

  Widget _buildMessageItem(MessageItem message) {
    final isMe = message.isMe;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            SizedBox(
              width: 28,
              height: 28,
              child: ClipOval(
                child: widget.chat.avatarUrl != null
                    ? Image.network(
                        widget.chat.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.primaryPurple.withOpacity(0.6),
                            child: Center(
                              child: Text(
                                widget.chat.avatar,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.primaryPurple.withOpacity(0.6),
                        child: Center(
                          child: Text(
                            widget.chat.avatar,
                            style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.primaryPurple : AppColors.cardBackground,
                border: isMe ? null : Border.all(color: AppColors.borderColor, width: 0.6),
                borderRadius: _bubbleRadius(isMe),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.hasMusic) ...[
                    _buildMusicAttachment(message, isMe),
                    if (message.text.isNotEmpty) const SizedBox(height: 8),
                  ],
                  if (message.text.isNotEmpty) ...[
                    Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white : AppColors.primaryText,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe ? Colors.white.withOpacity(0.7) : AppColors.mutedText,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMusicAttachment(MessageItem message, bool isMe) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isMe 
            ? Colors.black.withOpacity(0.2) 
            : AppColors.primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: message.musicCover != null
                ? Image.network(
                    message.musicCover!,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 40,
                        color: AppColors.primaryPurple.withOpacity(0.2),
                        child: const Icon(Icons.music_note_rounded, color: AppColors.primaryPurple, size: 20),
                      );
                    },
                  )
                : Container(
                    width: 40,
                    height: 40,
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    child: const Icon(Icons.music_note_rounded, color: AppColors.primaryPurple, size: 20),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.musicTitle ?? '',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isMe ? Colors.white : AppColors.primaryText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message.musicArtist ?? '',
                  style: TextStyle(
                    fontSize: 11,
                    color: isMe ? Colors.white.withOpacity(0.8) : AppColors.mutedText,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isMe 
                  ? Colors.white.withOpacity(0.15) 
                  : AppColors.primaryPurple,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow_rounded,
              size: 16,
              color: isMe ? Colors.white : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final canSend = _messageController.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.primaryBackground,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.searchBarBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (_) => setState(() {}),
                      maxLines: null,
                      style: const TextStyle(color: AppColors.primaryText, fontSize: 14),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: AppColors.mutedText, fontSize: 14),
                      ),
                    ),
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.photo_rounded, color: AppColors.mutedText, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.music_note_rounded, color: AppColors.mutedText, size: 20),
                    onPressed: () {},
                  ),
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(Icons.emoji_emotions_rounded, color: AppColors.mutedText, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: canSend ? _sendMessage : null,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: canSend 
                    ? const LinearGradient(
                        colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: canSend ? null : AppColors.mutedText.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(
        MessageItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: text,
          isMe: true,
          timestamp: DateTime.now(),
        ),
      );
    });

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final ampm = hour >= 12 ? 'AM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString()}:${minute.toString().padLeft(2, '0')} $ampm';
  }
}

class ChatItem {
  final String id;
  final String username;
  final String displayName;
  final String lastMessage;
  final String timestamp;
  final int unreadCount;
  final bool isOnline;
  final String avatar;
  final String? avatarUrl;
  final bool hasSharedMusic;
  final String? sharedMusicTitle;

  ChatItem({
    required this.id,
    required this.username,
    required this.displayName,
    required this.lastMessage,
    required this.timestamp,
    required this.unreadCount,
    required this.isOnline,
    required this.avatar,
    this.avatarUrl,
    this.hasSharedMusic = false,
    this.sharedMusicTitle,
  });
}

class MessageItem {
  final String id;
  final String text;
  final bool isMe;
  final DateTime timestamp;
  final bool hasMusic;
  final String? musicTitle;
  final String? musicArtist;
  final String? musicCover;

  MessageItem({
    required this.id,
    required this.text,
    required this.isMe,
    required this.timestamp,
    this.hasMusic = false,
    this.musicTitle,
    this.musicArtist,
    this.musicCover,
  });
}