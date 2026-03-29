import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/services/daily_question_service.dart';
import 'package:frontend/services/message_service.dart';
import 'package:frontend/services/socket_client.dart';
import 'package:frontend/view/prompt_modal.dart';
import 'package:frontend/view/prompt_response.dart';
import '../constants.dart';
import '../controller/chat_controller.dart';
import '../model/chat_model.dart';
import '../model/pigeon.dart';
import '../services/user_service.dart';
import '../model/profile_model.dart';

class ChatPage extends StatefulWidget {
  static const String routeName = '/chatPage';

  final String chatId;
  final String chatName;
  final List<User> participants;
  final String membership;
  final ChatroomService chatroomService;

  const ChatPage({
    Key? key,
    required this.chatId,
    required this.chatName,
    required this.participants,
    required this.membership,
    required this.chatroomService,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _chatController;
  late final UserService _userService;
  late final DailyQuestionService _dqService;
  final ChatModel _model = ChatModel();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  StreamSubscription<Message>? _messageSubscription;
  // StreamSubscription? _dqSubscription;
  // StreamSubscription? _dqPushSubscription;
  StreamSubscription? _messageErrorSubscription;
  bool _dqServiceReady = false;

  // prompt state
  // final TextEditingController _promptAnswerController = TextEditingController();
  // bool _showPromptModal = false;
  bool _hasAnsweredToday = true;
  // String? _todaysPromptQuestion;
  // bool _canSubmitPrompt = false;
  // bool _isSubmittingPrompt = false;
  // String? _dailyQuestionId;

  List<Message> _messages = [];
  bool _hasMore = true;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    _userService = UserService(api: apiClient);

    _loadCurrentUser();
    _setupScrollListener();
  }

  Future<void> _loadCurrentUser() async {
    print('_loadCurrentUser started');
    try {
      final user = await _userService.getProfile();
      final messageService = MessageService(socket: SocketClient.instance, api: ApiClient(), currentUserId: user.uid);
      _chatController = ChatController(
        messageService, 
        widget.chatId, 
        user.uid, 
        chatroomService: widget.chatroomService);
      print('chatController initialized, chatId: ${widget.chatId}');

      _dqService = DailyQuestionService(socket: SocketClient.instance, api: ApiClient());
      setState(() { _dqServiceReady = true; });
      // // listen for answer accepted to unlock chat
      // _dqSubscription = _dqService.onAnswerAccepted().listen((data) {
      //   setState(() {
      //     _showPromptModal = false;
      //     _hasAnsweredToday = true;
      //     _isSubmittingPrompt = false;
      //   });
      //   _promptAnswerController.clear();
      // });

      // listen for live daily question push if the user has chat open when it runs
      // _dqPushSubscription = _dqService.onDailyQuestion().listen((dq) {
      //   if (!_hasAnsweredToday) {
      //     setState(() {
      //       _todaysPromptQuestion = dq.question;
      //       _dailyQuestionId = dq.dailyQuestionId;
      //       _showPromptModal = true;
      //     });
      //   }
      // });

      setState(() { _currentUser = user; });

      // join socket room to receive live messages
      await _chatController.joinRoom();

      // subscribe to incoming msg stream
      _messageSubscription = _chatController.onReceiveMessage().listen((message) {
        setState(() { _messages.add(message); });
        _scrollToBottom();
      });

      // check if user needs to answer today's prompt
      final alreadyAnswered = await _dqService.getTodaysQuestion(widget.chatId);
      setState(() {
        _hasAnsweredToday = alreadyAnswered == null || alreadyAnswered.hasAnswered;
      });
      // error listener
      _messageErrorSubscription = _chatController.onMessageError().listen((e) {
        if (!mounted) return; // if widget was disposed
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      });

      // load chat data
      _loadChatData();
    } catch (e) {
      print('Failed to load current user: $e');
      setState(() {
        _model.loadError = 'Failed to load user info';
      });
    }
  }

  // Future<void> _checkTodaysPrompt() async {
  //   try {
  //     final result = await _dqService.getTodaysQuestion(widget.chatId);
  //     setState(() {
  //       if (result == null) {
  //         // no question dispatched yet today
  //         _showPromptModal = false;
  //         _hasAnsweredToday = true; // if no question, don't block chat
  //       } else {
  //         _todaysPromptQuestion = result.question;
  //         _hasAnsweredToday = result.hasAnswered;
  //         _showPromptModal = !result.hasAnswered;
  //         _dailyQuestionId = result.dailyQuestionId; // store for submit
  //       }
  //     });
  //   } catch (e) {
  //     print('Failed to check prompt: $e');
  //     _showPromptModal = false; // don't block chat on error
  //   }
  // }

  // Future<void> _submitPromptAnswer() async {
  //   final answerText = _promptAnswerController.text.trim();
  //   if (answerText.isEmpty || _dailyQuestionId == null || _currentUser == null) return;

  //   setState(() {
  //     _isSubmittingPrompt = true;
  //   });

  //   try {
  //     // submit via socket
  //     _dqService.submitAnswer(
  //       dailyQuestionId: _dailyQuestionId!,
  //       userId: _currentUser!.uid,
  //       answerText: answerText,
  //       chatId: widget.chatId,
  //     );
  //     // result comes back via onAnswerAccepted stream
  //     // handled in subscription set up in _loadCurrentUser()

  //     // setState(() {
  //     //   _showPromptModal = false;
  //     //   _hasAnsweredToday = true;
  //     //   _isSubmittingPrompt = false;
  //     // });

  //     // _promptAnswerController.clear();
  //   } catch (e) {
  //     setState(() {
  //       _isSubmittingPrompt = false;
  //     });

  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(SnackBar(content: Text('Failed to submit answer: $e')));
  //   }
  // }

  void _setupScrollListener() {
    _scrollController.addListener(() {
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

    final messagesResult = await _chatController.loadMessages();

    if (messagesResult['success']) {
      setState(() {
        _messages = messagesResult['messages'];
        _hasMore = messagesResult['hasMore'];
        _model.isLoading = false;
      });
      _scrollToBottom();
    } else {
      setState(() {
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

    _messageController.clear();

    // send message, no need to await. server broadcasts back to the room
    _chatController.sendMessage(content);
  }

  void _onTypingChanged(String text) {
    if (_currentUser == null) return;
    final isTyping = text.isNotEmpty;
    setState(() {});
    if (isTyping != _model.isTyping) {
      _model.isTyping = isTyping;
    }
  }

  Future<void> _showLeaveConfirmation() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Leave Chat'),
        content: Text(
          widget.participants.length+1 == 1
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
    _messageSubscription?.cancel(); // stop listening for new msgs
    // _dqSubscription?.cancel(); // stop listening for dq
    // _dqPushSubscription?.cancel();
    _messageErrorSubscription?.cancel();
    _chatController.leaveRoom(); // leave socket room
    _messageController.dispose();
    _scrollController.dispose();
    // _promptAnswerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // main chat content
          Container(
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
                        : _buildChatContent(),
                  ),
                  _buildInputArea(),
                ],
              ),
            ),
          ),

          // prompt modal overlay
          // if (_showPromptModal) _buildPromptModal(),
          if (_currentUser != null && !_hasAnsweredToday)
            DailyPromptModal(
              chatId: widget.chatId,
              currentUserId: _currentUser!.uid,
              dqService: _dqService,
              onAnswerSubmitted: () {
                setState(() { _hasAnsweredToday = true; });
              },
            ),
        ],
      ),
    );
  }

  // Widget _buildPromptModal() {
  //   return Stack(
  //     children: [
  //       // blurred background
  //       BackdropFilter(
  //         filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
  //         child: Container(color: Colors.black.withOpacity(0.3)),
  //       ),

  //       // prompt card
  //       Align(
  //         alignment: Alignment.bottomCenter,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             // Tab sticking out above the card
  //             Padding(
  //               padding: EdgeInsets.only(left: AppSpacing.sm),
  //               child: Container(
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: AppSpacing.md,
  //                   vertical: AppSpacing.sm,
  //                 ),
  //                 decoration: BoxDecoration(
  //                   color: AppColors.background,
  //                   borderRadius: BorderRadius.only(
  //                     topLeft: Radius.circular(AppBorderRadius.md),
  //                     topRight: Radius.circular(AppBorderRadius.md),
  //                   ),
  //                   border: Border(
  //                     left: BorderSide(color: AppColors.border, width: 1),
  //                     top: BorderSide(color: AppColors.border, width: 1),
  //                     right: BorderSide(color: AppColors.border, width: 1),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'Daily Question',
  //                   style: Theme.of(
  //                     context,
  //                   ).textTheme.headlineMedium?.copyWith(fontSize: 16),
  //                 ),
  //               ),
  //             ),

  //             // main card
  //             Container(
  //               width: double.infinity,
  //               padding: EdgeInsets.only(
  //                 left: AppSpacing.md,
  //                 right: AppSpacing.md,
  //                 bottom: AppSpacing.md,
  //                 top: AppSpacing.md,
  //               ),
  //               decoration: BoxDecoration(
  //                 color: AppColors.background,
  //               ),
  //                 child: Column(
  //                   mainAxisSize: MainAxisSize.min,
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // question text
  //                     Text(
  //                       _todaysPromptQuestion ?? 'Loading question...',
  //                       style: Theme.of(
  //                         context,
  //                       ).textTheme.bodyLarge?.copyWith(fontSize: 20),
  //                     ),
  //                     SizedBox(height: AppSpacing.md),

  //                     // input row
  //                     Row(
  //                       children: [
  //                         Expanded(
  //                           child: TextField(
  //                             controller: _promptAnswerController,
  //                             autofocus: true,
  //                             maxLength: 500,
  //                             decoration: InputDecoration(
  //                               hintText: 'Type your answer here...',
  //                               hintStyle: Theme.of(context).textTheme.bodySmall
  //                                   ?.copyWith(fontStyle: FontStyle.italic),
  //                               border: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(
  //                                   AppBorderRadius.lg,
  //                                 ),
  //                                 borderSide: BorderSide(
  //                                   color: AppColors.border,
  //                                 ),
  //                               ),
  //                               enabledBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(
  //                                   AppBorderRadius.lg,
  //                                 ),
  //                                 borderSide: BorderSide(
  //                                   color: AppColors.border,
  //                                 ),
  //                               ),
  //                               focusedBorder: OutlineInputBorder(
  //                                 borderRadius: BorderRadius.circular(
  //                                   AppBorderRadius.lg,
  //                                 ),
  //                                 borderSide: BorderSide(
  //                                   color: AppColors.primary,
  //                                   width: 2,
  //                                 ),
  //                               ),
  //                               counterText: '',
  //                               contentPadding: EdgeInsets.symmetric(
  //                                 horizontal: AppSpacing.md,
  //                                 vertical: AppSpacing.sm,
  //                               ),
  //                             ),
  //                           ),
  //                         ),
  //                         SizedBox(width: AppSpacing.sm),

  //                         // send button
  //                         IconButton(
  //                           icon: _isSubmittingPrompt
  //                               ? SizedBox(
  //                                   height: 20,
  //                                   width: 20,
  //                                   child: CircularProgressIndicator(
  //                                     color: AppColors.primary,
  //                                     strokeWidth: 2,
  //                                   ),
  //                                 )
  //                               : Icon(Icons.send),
  //                           color: _canSubmitPrompt
  //                               ? AppColors.primary
  //                               : AppColors.textSecondary,
  //                           onPressed: _canSubmitPrompt && !_isSubmittingPrompt
  //                               ? _submitPromptAnswer
  //                               : null,
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
                
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
                    widget.chatName,
                    style: AppTextStyles.heading.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    _model.showFullGroupName
                        ? '${widget.participants.length+1} members: ${widget.participants.map((p) => p.username).join(", ")}'
                        : '${widget.participants.length+1} members',
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

  Widget _buildChatContent() {
    return Column(
      children: [
        Expanded(child: _buildMessageList()),
        if (_hasAnsweredToday && _currentUser != null && _dqServiceReady)
          SizedBox(
            height: 300,
            child: PromptResponseFeed(
              chatId: widget.chatId, 
              currentUserId: _currentUser!.uid, 
              dqService: _dqService
            ),
          ),
      ],
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
            isFirstInGroup
                ? CircleAvatar(
                    radius: 16,
                    backgroundImage: AssetImage(profileImage),
                    backgroundColor: Colors.transparent,
                  )
                : SizedBox(width: 32),
            SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isSentByCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
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
