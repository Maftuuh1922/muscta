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

  // Mock chat list data (updated with avatarUrl like in the React sample)
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
      title: const Text(
        'Messages',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryText,
        ),
      ),
      centerTitle: false,
      actions: const [
        // Compose button similar to Edit3
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.edit_rounded, color: AppColors.primaryText),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.searchBarBackground,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: AppColors.mutedText, size: 20),
          const SizedBox(width: 10),
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
          children: [
            const Icon(Icons.textsms_rounded, size: 56, color: AppColors.mutedText),
            const SizedBox(height: 12),
            Text('No messages found', style: TextStyle(color: AppColors.mutedText)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _filteredChats.length,
      itemBuilder: (context, index) {
        return _buildChatItem(_filteredChats[index]);
      },
    );
  }

  Widget _buildChatItem(ChatItem chat) {
    return InkWell(
      onTap: () => _openChat(chat),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.defaultPadding,
          vertical: 10,
        ),
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
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primaryBackground, width: 2),
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
                      Text(
                        chat.displayName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: chat.unreadCount > 0 ? FontWeight.w700 : FontWeight.w500,
                          color: AppColors.primaryText,
                        ),
                      ),
                      Text(
                        chat.timestamp,
                        style: TextStyle(
                          fontSize: 12,
                          color: chat.unreadCount > 0 ? AppColors.primaryPurple : AppColors.mutedText,
                          fontWeight: chat.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (chat.hasSharedMusic) ...[
                        const Icon(Icons.music_note_rounded, size: 14, color: AppColors.primaryPurple),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          chat.hasSharedMusic && chat.sharedMusicTitle != null
                              ? chat.sharedMusicTitle!
                              : chat.lastMessage,
                          style: TextStyle(
                            fontSize: 13,
                            color: chat.unreadCount > 0 ? AppColors.secondaryText : AppColors.mutedText,
                            fontWeight: chat.unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (chat.unreadCount > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryPurple,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            chat.unreadCount.toString(),
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
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
            ? Image.network(chat.avatarUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primaryPurple.withOpacity(0.6),
                child: Center(
                  child: Text(
                    chat.avatar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
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

  // Mock messages (updated to include cover like the React sample)
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
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.chat.displayName,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primaryText),
              ),
              Text(
                widget.chat.isOnline ? 'Online' : 'Offline',
                style: TextStyle(fontSize: 12, color: widget.chat.isOnline ? AppColors.success : AppColors.mutedText),
              ),
            ],
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 8),
          child: Icon(Icons.more_horiz_rounded, color: AppColors.primaryText),
        ),
      ],
    );
  }

  Widget _buildSmallAvatar() {
    return SizedBox(
      width: 32,
      height: 32,
      child: ClipOval(
        child: widget.chat.avatarUrl != null
            ? Image.network(widget.chat.avatarUrl!, fit: BoxFit.cover)
            : Container(
                color: AppColors.primaryPurple.withOpacity(0.6),
                child: Center(
                  child: Text(
                    widget.chat.avatar,
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
    // Tail-like sharp corner similar to rounded-2xl with one small corner
    return BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );
  }

  Widget _buildMessageItem(MessageItem message) {
    final isMe = message.isMe;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (!isMe) ...[
          _buildSmallAvatar(),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isMe ? AppColors.primaryPurple : AppColors.cardBackground,
              border: isMe ? null : Border.all(color: AppColors.borderColor, width: 0.6),
              borderRadius: _bubbleRadius(isMe),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.hasMusic) _buildMusicAttachment(message, isMe),
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
                    fontSize: 10,
                    color: isMe ? Colors.white.withOpacity(0.7) : AppColors.mutedText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMusicAttachment(MessageItem message, bool isMe) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isMe ? Colors.white.withOpacity(0.10) : AppColors.primaryPurple.withOpacity(0.10),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: message.musicCover != null
                ? Image.network(message.musicCover!, width: 40, height: 40, fit: BoxFit.cover)
                : Container(
                    width: 40,
                    height: 40,
                    color: AppColors.primaryPurple.withOpacity(0.2),
                    child: const Icon(Icons.music_note_rounded, color: AppColors.primaryPurple),
                  ),
          ),
          const SizedBox(width: 10),
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
                    color: isMe ? Colors.white.withOpacity(0.8) : AppColors.secondaryText,
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
              color: AppColors.cardBackground,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.borderColor, width: 0.6),
            ),
            child: const Icon(Icons.play_arrow_rounded, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final canSend = _messageController.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        border: Border(top: BorderSide(color: AppColors.borderColor, width: 0.5)),
      ),
      child: Row(
        children: [
          // Text field with suffix actions inside (image/music/emoji)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.searchBarBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      onChanged: (_) => setState(() {}),
                      maxLines: null,
                      style: const TextStyle(color: AppColors.primaryText),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Message...',
                        hintStyle: TextStyle(color: AppColors.mutedText),
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
          const SizedBox(width: 8),
          // Gradient send button
          Opacity(
            opacity: canSend ? 1 : 0.5,
            child: GestureDetector(
              onTap: canSend ? _sendMessage : null,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryPurple, AppColors.secondaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
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
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
  final String avatar; // fallback initial
  final String? avatarUrl; // new: network avatar like in React sample
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
  final String? musicCover; // new: cover image

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
