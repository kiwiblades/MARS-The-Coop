import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/mail_controller.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/mail_model.dart';

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
    controller = MailController(this);
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
            onPressed: () {},
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
    final isSelected = model.selectedChatroom;
    if (model.chatroomList!.isEmpty) {
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
    List<Chatroom> pinnedChats = model.chatroomList!
        .where((chat) => chat.pinned)
        .toList();
    List<Chatroom> unpinnedChats = model.chatroomList!
        .where((chat) => !chat.pinned)
        .toList();
    return SingleChildScrollView(
      child: Column(
        // mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              // color: Color(0xFFC0936D),
              border: Border.all(color: AppColors.darkBrown, width: 2.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListView.separated(
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
              // color: Color(0xFFC0936D),
              border: Border.all(color: AppColors.darkBrown, width: 2.5),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListView.separated(
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
    late final chatImage;
    if (chat.participants.isEmpty) {
      //TODO
      // final pigeonId = currentUser?.pigeonId ?? 0;
      // final pigeon = Pigeon.getById(pigeonId);
      // final chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';
      chatImage =
          'images/pigeonProfile/defaultPigeonProfile.png'; //can be deleted once TODO is done
    } else if (chat.participants.length == 1) {
      //TODO
      // final pigeonId = chat.participants[0].pigeonId ?? 0;
      // final pigeon = Pigeon.getById(pigeonId);
      // final chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';
      chatImage =
          'images/pigeonProfile/magpiePigeonProfile.png'; //can be deleted once TODO is done
    } else {
      //if there are more than 1 participants
      chatImage = 'images/group.png';
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onLongPress: () => controller.onLongPressChat(context, chat),
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
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            fontSize: 14,
                            color: AppColors.darkBrown,
                          ),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Text(
                        //last message time
                        chat.lastSentTime,
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

  //pin chat dialog box
  Future<void> showPinModal(BuildContext context) {
    final chat = model.selectedChatroom;

    return showModalBottomSheet(
      context: context, 
      backgroundColor: const Color(0xFFE6C7A8),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                chat?.name?? "",
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: AppColors.darkBrown,
                    fontSize: 18,
                  ),
              ),
            ]
            //if selected chat is pinned, ask if user wants to unpin it (show chat name then unpin text button underneath)
            //if selected chat isn't pinned, show chat name and text button to pin chat
          ),
        );
      }
    );
  }
}
