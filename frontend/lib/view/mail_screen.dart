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

  @override
  void initState() {
    super.initState();
    model = MailModel();
    final apiClient = ApiClient();
    final chatroomService = ChatroomService(api: apiClient);
    final userService = UserService(api: apiClient);
    controller = MailController(this, chatroomService: chatroomService, userService: userService);
    controller.loadChatrooms(); // fetch the user's chatrooms on screen load
  }

  void callSetState(fn) => setState(fn);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          //background wood text
          image: AssetImage('images/woodGrainTexture.png'),
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
    if (model.chatroomList == null) { // still loading
      return const Center(child: CircularProgressIndicator());
    }
    if (model.chatroomList!.isEmpty) { //if user does not have any chats yet
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
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkBrown, width: 2.5),
              borderRadius: BorderRadius.circular(12.0), //round corners
            ),
            child: ListView.separated( //list for pinned chats
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
          SizedBox(height: 10.0),
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.darkBrown, width: 2.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListView.separated( //list for unpinned chats
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
      chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';
    } else if (chat.participants.length == 1) {
      final pigeonId = chat.participants[0].pigeonId;
      final pigeon = Pigeon.getById(pigeonId);
      chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';
    } else {
      //if there are more than 1 participants
      chatImage = 'images/group.png';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onLongPress: () => controller.onLongPressChat(context, chat),
        onTap: () => controller.onTapChat(context,chat),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start, //makes pinned icon in top right
          children: [
            //chat image
            CircleAvatar(
              backgroundColor: AppColors.darkBrown,
              radius: 20,
              child: ClipOval(child: Image.asset(chatImage)),
            ),
            const SizedBox(width: 10), //spacer
            Expanded(
              //text info
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    //chat name/title
                    chat.name,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontSize: 14,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  Row(
                    //most recent message info
                    children: [
                      Expanded(
                        child: Text(
                          //last message text
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
                        //last message time
                        controller.formatChatTimestamp(chat.lastSentTime),
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
            if (chat.pinned) //pinned icon
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
                    Text( //name of selected chat
                      chat?.name ?? "",
                      style: Theme.of(context).textTheme.headlineSmall!
                          .copyWith(color: AppColors.darkBrown, fontSize: 18),
                    ),
                    const SizedBox(height: 10), //spacer
                    InkWell( //for pin/unpin action
                      onTap: () => controller.onPressPin(context), //same function, just reverses value
                      child: Row(
                        children: [
                          Text( //conditionally render "button" label
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
