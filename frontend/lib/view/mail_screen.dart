import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/mail_controller.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/mail_model.dart';
import 'package:frontend/model/pigeon.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/services/user_service.dart';

class MailScreen extends StatefulWidget {
  static const String routeName = '/mailScreen';
  const MailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return MailScreenState();
  }
}

class MailScreenState extends State<MailScreen> {
  late MailController controller;
  late MailModel model;
  bool _bannerCollapsed = false;

  @override
  void initState() {
    super.initState();
    model = MailModel();
    final apiClient = ApiClient();
    final chatroomService = ChatroomService(api: apiClient);
    final userService = UserService(api: apiClient);
    controller = MailController(
      this,
      chatroomService: chatroomService,
      userService: userService,
    );
    controller.loadChatrooms(); // fetch the user's chatrooms on screen load
  }

  void callSetState(fn) => setState(fn);
  int get _totalUnreadMessages {
    if (model.chatroomList == null) return 0;
    return model.chatroomList!.fold(0, (sum, chat) => sum + chat.unreadCount);
  }

  int get _totalPendingQuestions {
    if (model.chatroomList == null) return 0;
    return model.chatroomList!.where((chat) => chat.hasPendingQuestion).length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          //background wood text
          image: AssetImage('images/woodGrainTexture.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body:
              bodyView(), //conditionally render a message if there are no chatrooms
          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.darkBrown,
            onPressed: controller.onPressAddChatButton,
            shape: const CircleBorder(),
            elevation: 2.0,
            child: const Icon(
              Icons.add,
              color: Color(0xFFD1A681), // lighter brown icon
            ),
          ),
        ),
      ),
    );
  }

  Widget bodyView() {
    if (model.chatroomList == null) {
      // still loading
      return const Center(child: CircularProgressIndicator());
    }
    if (model.chatroomList!.isEmpty) {
      //if user does not have any chats yet
      print('chats empty, view reached');
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "No chatrooms. Press '+' to join or create a new chatroom.",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 16.0,
              color: AppColors.darkBrown,
            ),
          ),
        ),
      );
    }
    //filter a list to contain only pinned chats
    List<Chatroom> pinnedChats = model.chatroomList!
        .where((chat) => chat.pinned)
        .toList();
    //filter a list to contain only unpinned chats
    List<Chatroom> unpinnedChats = model.chatroomList!
        .where((chat) => !chat.pinned)
        .toList();
    return SingleChildScrollView(
      child: Column(
        children: [
          if (_totalUnreadMessages > 0 || _totalPendingQuestions > 0)
            _buildSummaryBanner(),
          if (pinnedChats.isNotEmpty) ...[
            Container(
              //pinned
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkBrown, width: 2.5),
                borderRadius: BorderRadius.circular(12.0), //round corners
              ),
              child: ListView.separated(
                //list for pinned chats
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: pinnedChats.length,
                itemBuilder: (context, index) {
                  return buildChatroomTile(pinnedChats[index]);
                },
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
          ],
          if (unpinnedChats.isNotEmpty) ...[
            SizedBox(height: 10.0),
            Container(
              //unpinned
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.darkBrown, width: 2.5),
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ListView.separated(
                //list for unpinned chats
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: unpinnedChats.length,
                itemBuilder: (context, index) {
                  return buildChatroomTile(unpinnedChats[index]);
                },
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.darkBrown,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

Widget _buildSummaryBanner() {
  String bannerText;
  if (_totalUnreadMessages > 0 && _totalPendingQuestions > 0) {
    bannerText = '$_totalUnreadMessages unread message${_totalUnreadMessages == 1 ? '' : 's'} and\n$_totalPendingQuestions unanswered question${_totalPendingQuestions == 1 ? '' : 's'}';
  } else if (_totalUnreadMessages > 0) {
    bannerText = '$_totalUnreadMessages unread message${_totalUnreadMessages == 1 ? '' : 's'}';
  } else {
    bannerText = '$_totalPendingQuestions unanswered question${_totalPendingQuestions == 1 ? '' : 's'}';
  }

  return Container(
    margin: EdgeInsets.only(bottom: 10),
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.lightBrown,
      border: Border.all(color: AppColors.darkBrown, width: 2),
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      onTap: () {
        setState(() {
          _bannerCollapsed = !_bannerCollapsed;
        });
      },
      child: Row(
        children: [
          Expanded(
            child: Text(
              _bannerCollapsed ? "What's new" : bannerText,
              style: AppTextStyles.body.copyWith(
                fontSize: 14,
                fontWeight: _bannerCollapsed ? FontWeight.w600 : null,
                fontStyle: _bannerCollapsed ? null : FontStyle.italic,
                color: AppColors.darkBrown,
              ),
            ),
          ),
          Icon(
            _bannerCollapsed ? Icons.expand_more : Icons.expand_less,
            size: 20,
            color: AppColors.darkBrown,
          ),
        ],
      ),
    ),
  );
}

  //helper to create each chat room's block
  Widget buildChatroomTile(Chatroom chat) {
    //determine image for chat
    late final String chatImage;
    if (chat.participants.isEmpty) {
      final pigeonId = model.currentUser?.pigeonId ?? 0;
      final pigeon = Pigeon.getById(pigeonId);
      chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.webp';
    } else if (chat.participants.length == 1) {
      final pigeonId = chat.participants[0].pigeonId;
      final pigeon = Pigeon.getById(pigeonId);
      chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.webp';
    } else {
      //if there are more than 1 participants
      chatImage = 'images/group.webp';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onLongPress: () => controller.onLongPressChat(context, chat),
        onTap: () => controller.onTapChat(context, chat),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //chat image
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.darkBrown,
                      radius: 20,
                      child: ClipOval(child: Image.asset(chatImage)),
                    ),
                    if (chat.unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          padding: EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Center(
                            child: Text(
                              chat.unreadCount > 99
                                  ? '99+'
                                  : '${chat.unreadCount}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chat.name,
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(fontSize: 14, color: AppColors.darkBrown),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              chat.lastSentMessage,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontSize: 14,
                                    color: AppColors.darkBrown,
                                  ),
                            ),
                          ),
                          SizedBox(width: 5.0),
                          Text(
                            controller.formatChatTimestamp(chat.lastSentTime),
                            style: Theme.of(context).textTheme.bodySmall!
                                .copyWith(
                                  fontSize: 14,
                                  color: AppColors.darkBrown,
                                ),
                          ),
                          if (chat.pinned) SizedBox(width: 10.0),
                        ],
                      ),
                    ],
                  ),
                ),
                if (chat.pinned)
                  Transform.rotate(
                    angle: 45 * math.pi / 180,
                    child: const Icon(
                      Icons.push_pin,
                      color: AppColors.darkBrown,
                      size: 20.0,
                    ),
                  ),
              ],
            ),

            if (chat.hasPendingQuestion)
              Positioned(
                top: 27, 
                right: 70, 
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'New Question!',
                    style: AppTextStyles.label.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

            if (chat.hasPendingQuestion)
              Positioned(
                top: -10,
                right: 90,
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    shape: BoxShape.rectangle,
                  ),
                  child: Image.asset(
                    'images/pigeonSide/pinkNeckedGreenPigeonSide.webp',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  //pin chat dialog box, shows up when user presses and holds on chat
  Future<void> showPinModal(BuildContext context) {
    final chat = model.selectedChatroom;

    return showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFE6C7A8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle decor
              Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 10),
                child: Container(
                  width: 80,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.darkBrown.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // content
              Padding(
                padding: const EdgeInsets.fromLTRB(70, 10, 20, 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      //name of selected chat
                      chat?.name ?? "",
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: AppColors.darkBrown, fontSize: 18),
                    ),
                    const SizedBox(height: 10), //spacer
                    InkWell(
                      //for pin/unpin action
                      onTap: () => controller.onPressPin(
                        context,
                      ), //same function, just reverses value
                      child: Row(
                        children: [
                          Text(
                            //conditionally render "button" label
                            model.selectedChatroom!.pinned
                                ? 'Unpin chat'
                                : 'Pin chat to top',
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  color: AppColors.darkBrown,
                                  fontSize: 16,
                                ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right,
                            size: 30,
                            color: AppColors.darkBrown,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
