import 'package:flutter/material.dart';
import '../constants.dart';
import '../services/api_client.dart';
import '../controller/chat_controller.dart';
import '../model/chat_model.dart';
import '../model/pigeon.dart';
import '../services/user_service.dart';
import '../model/profile_model.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = '/chatPage';

  final String chatId;
  final String chatName;

  const ChatPage({
    Key? key,
    required this.chatId,
    required this.chatName
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _chatController;
  late final UserService _userService;
  final ChatModel _model = ChatModel();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Message> _messages = [];
  ChatGroup? _chatGroup;
  bool _hasMore = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _userService = UserService(api: apiClient);
  
    // fetch current user first
    _loadCurrentUser();
    _setupScrollListener();
  }

  Future<void> _loadCurrentUser() async {
    print('_loadCurrentUser started');
    try {
      final user = await _userService.getProfile();
      _chatController = ChatController(ApiClient(), widget.chatId, user.uid);
      print('chatController initialized, chatId: ${widget.chatId}');
      setState(() {
        _currentUser = user;
      });

      // TEMP: mock data for testing
      //_useMockData();

      // load chat data with the current user
      _loadChatData();
    } catch (e) {
      print('Failed to load current user: $e');
      setState(() {
        _model.loadError = 'Failed to load user info';
      });
    }
  }

  // void _useMockData() {
  //   setState(() {
  //     _chatGroup = ChatGroup(
  //       id: 1,
  //       name: 'Test Group Chat',
  //       memberCount: 3,
  //       memberAvatars: [],
  //     );

  //     _messages = [
  //       Message(
  //         id: 1,
  //         content: 'hey',
  //         senderUsername: 'TestUser1',
  //         senderId: 999,
  //         timestamp: DateTime.now().subtract(Duration(hours: 2)),
  //         isSentByCurrentUser: false,
  //         senderPigeonId: 1,
  //       ),
  //               Message(
  //         id: 2,
  //         content: 'everyone',
  //         senderUsername: 'TestUser1',
  //         senderId: 999,
  //         timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 59)),
  //         isSentByCurrentUser: false,
  //         senderPigeonId: 1,
  //       ),
  //               Message(
  //         id: 3,
  //         content: 'Hey everyone!',
  //         senderUsername: 'TestUser1',
  //         senderId: 999,
  //         timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 58)),
  //         isSentByCurrentUser: false,
  //         senderPigeonId: 1,
  //       ),
  //       Message(
  //         id: 4,
  //         content: 'Hi! How are you?',
  //         senderUsername: 'You',
  //         senderId: widget.currentUserId,
  //         timestamp: DateTime.now().subtract(Duration(hours: 1, minutes: 50)),
  //         isSentByCurrentUser: true,
  //         senderPigeonId: 3,
  //       ),
  //       Message(
  //         id: 5,
  //         content: 'This is a longer message to test how the bubble expands when there is more text. This is a longer message to test how the bubble expands when there is more text.',
  //         senderUsername: 'TestUser2',
  //         senderId: 998,
  //         timestamp: DateTime.now().subtract(Duration(minutes: 30)),
  //         isSentByCurrentUser: false,
  //         senderPigeonId: 5,
  //       ),
  //     ];
  //   });
  // }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      // load more messages when scrolling to top
      if (_scrollController.position.pixels == 0 &&
          _hasMore &&
          !_model.isLoading) {
        _loadMoreMessages();
      }
    });
  }

  Future<void> _loadChatData() async {
    print('_loadChatData started, currentUser: $_currentUser');
    if (_currentUser == null) return;

    setState(() {
      _model.isLoading = true;
      _model.loadError = null;
    });

    // load chat info and messages
    // final infoResult = await _chatController.loadChatInfo();
    final messagesResult = await _chatController.loadMessages();

    //if (infoResult['success'] && messagesResult['success']) {
    if (messagesResult['success']) {
      setState(() {
        // _chatGroup = infoResult['chatGroup'];
        _chatGroup = ChatGroup( // hardcoded for now
          id: 0,
          name: widget.chatName,
          memberCount: 0,
          memberAvatars: [],
        );
        _messages = messagesResult['messages'];
        _hasMore = messagesResult['hasMore'];
        _model.isLoading = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
        // _model.loadError = infoResult['error'] ?? messagesResult['error'];
        _model.loadError = messagesResult['error'];
        _model.isLoading = false;
      });
    }
  }

  Future<void> _loadMoreMessages() async {
    if (_currentUser == null) return;

    final result = await _chatController.loadMessages(
      offset: _messages.length,
      limit: 50,
    );

    if (result['success']) {
      setState(() {
        _messages.insertAll(0, result['messages']);
        _hasMore = result['hasMore'];
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    if (_currentUser == null) return;

    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // clear input field immediately
    _messageController.clear();

    // TEMP: add message directly for mock testing
    // setState(() {
    //   _messages.add(Message(
    //     id: _messages.length + 1,
    //     content: content,
    //     senderUsername: 'You',
    //     senderId: widget.currentUserId,
    //     timestamp: DateTime.now(),
    //     isSentByCurrentUser: true,
    //     senderPigeonId: 3,
    //   ));
    // });
    // _scrollToBottom();

    // comment while using mock data:
    final result = await _chatController.sendMessage(content);
    if (result['success']) {
      setState(() {
        _messages.add(result['message']);
      });
      _scrollToBottom();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: ${result['error']}')),
      );
      _messageController.text = content;
    }
  }

  void _onTypingChanged(String text) {
    if (_currentUser == null) return;
    final isTyping = text.isNotEmpty;
    setState(() {});
    if (isTyping != _model.isTyping) {
      _model.isTyping = isTyping;
    //   _chatController.sendTypingIndicator(isTyping);
    }
  }

  Future<void> _showLeaveConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Chat'),
        content: Text(
          _chatGroup?.memberCount == 1
              ? 'You are the last member. Leaving will delete this chat.'
              : 'Are you sure you want to leave this chat?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Leave', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (result == true) {
      await _leaveChat();
    }
  }

  Future<void> _leaveChat() async {
    if (_currentUser == null) return;

    final result = await _chatController.leaveChat();

    if (result['success']) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Left chat successfully')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to leave chat: ${result['error']}')),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/woodGrainTexture.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _model.isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _model.loadError != null
                    ? _buildErrorView()
                    : _buildMessageList(),
              ),
              _buildInputArea(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _model.showFullGroupName = !_model.showFullGroupName;
                });
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _chatGroup?.name ?? 'Loading...',
                    style: AppTextStyles.heading.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _model.showFullGroupName
                        ? '${_chatGroup?.memberCount ?? 0} members: ${_chatGroup?.memberNames?.join(", ") ?? ""}'
                        : '${_chatGroup?.memberCount ?? 0} members',
                    style: AppTextStyles.label,
                    maxLines: _model.showFullGroupName ? null : 1,
                    overflow: _model.showFullGroupName
                        ? TextOverflow.visible
                        : TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              if (value == 'leave') {
                _showLeaveConfirmation();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'leave', child: Text('Leave Chat')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    if (_messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.all(AppSpacing.md),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];
        final showTimestamp = _shouldShowTimestamp(index);
        final isFirstInGroup = _isFirstInGroup(index);

        return Column(
          children: [
            _buildMessageBubble(message, isFirstInGroup),
            if (showTimestamp) _buildTimestamp(message.timestamp),
            SizedBox(height: AppSpacing.sm),
          ],
        );
      },
    );
  }

  bool _shouldShowTimestamp(int index) {
    if (index == _messages.length - 1) return true;

    final currentMessage = _messages[index];
    final nextMessage = _messages[index + 1];

    final timeDifference = nextMessage.timestamp.difference(
      currentMessage.timestamp,
    );
    return timeDifference.inMinutes >= 1;
  }

  bool _isFirstInGroup(int index) {
    if (index == 0) return true;

    final currentMessage = _messages[index];
    final previousMessage = _messages[index - 1];

    return currentMessage.senderId != previousMessage.senderId;
  }

  Widget _buildMessageBubble(Message message, bool isFirstInGroup) {
    final pigeon = message.senderPigeonId != null
        ? Pigeon.getById(message.senderPigeonId!)
        : null;
    final profileImage =
        pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';

    return Align(
      alignment: message.isSentByCurrentUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isSentByCurrentUser) ...[
            // Show avatar only for first message in group
            isFirstInGroup
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(profileImage),
                    backgroundColor: Colors.transparent,
                  )
                : SizedBox(width: 32), // Placeholder space for alignment
            SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSentByCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Show username only for first message in group
                if (!message.isSentByCurrentUser && isFirstInGroup)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4),
                    child: Text(
                      message.senderUsername,
                      style: AppTextStyles.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: message.isSentByCurrentUser
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: Text(
                    message.content,
                    style: AppTextStyles.body.copyWith(
                      color: message.isSentByCurrentUser
                          ? AppColors.background
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    String timeText;
    if (difference.inDays == 0) {
      timeText =
          '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      timeText =
          'Yesterday ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      timeText =
          '${timestamp.month}/${timestamp.day} ${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    }

    return Center(
      child: Text(timeText, style: AppTextStyles.label.copyWith(fontSize: 12)),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Failed to load chat', style: AppTextStyles.body),
          SizedBox(height: AppSpacing.md),
          ElevatedButton(
            onPressed: _loadChatData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
            ),
            child: Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.9),
        border: Border(top: BorderSide(color: AppColors.border, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              onChanged: _onTypingChanged,
              maxLines: null,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTextStyles.label,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                counterText: '',
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
              ),
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          IconButton(
            icon: Icon(
              Icons.send,
              color: _messageController.text.trim().isEmpty
                  ? AppColors.textSecondary
                  : AppColors.primary,
            ),
            onPressed: _messageController.text.trim().isEmpty
                ? null
                : _sendMessage,
          ),
        ],
      ),
    );
  }
}
