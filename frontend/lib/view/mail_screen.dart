import 'package:flutter/material.dart';
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
  //controller
  late MailModel model;

  @override
  void initState() {
    super.initState();
    model = MailModel();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: const BoxDecoration(
          //background wood text
          image: DecorationImage(
            image: AssetImage('images/woodGrainTexture.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body:
              bodyView(), //conditionally render a message if there are no chatrooms
          floatingActionButton: FloatingActionButton(
            onPressed: () {},
            child: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget bodyView() {
    if (model.chatroomList!.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            "No chatrooms. Press '+' to join or create a new chatroom.",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 16.0,
              color: Color(0xFF93633A),
            ),
          ),
        ),
      );
    }
    List<Chatroom> pinnedChats = model.chatroomList!.where((chat) => chat.pinned).toList();
    List<Chatroom> unpinnedChats = model.chatroomList!.where((chat) => !chat.pinned).toList();
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: pinnedChats.length,
            itemBuilder: (context,index) {
              return buildChatroomTile(pinnedChats[index]);
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: unpinnedChats.length,
            itemBuilder: (context,index) {
              return buildChatroomTile(unpinnedChats[index]);
            },
          ),
        ),
      ],
      //build tile:
      //leading is the pfp 3 options, empty chat = user's pfp, 1 participant = that participants pfp, group = group pfp
      //chat name: all chat's must have name, font dela one
      //end: pinned icon if pinned, otherwise nothing
    );
  }

  Widget buildChatroomTile(Chatroom chat) {
    //determine image for chat
    late final chatImage;
    if(chat.participants.isEmpty) {
      //TODO
      // final pigeonId = currentUser?.pigeonId ?? 0;
      // final pigeon = Pigeon.getById(pigeonId);
      // final chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';
      chatImage = 'images/pigeonProfile/defaultPigeonProfile.png'; //can be deleted once TODO is done 
    } else if (chat.participants.length == 1) {
      // final pigeonId = chat.participants[0].pigeonId ?? 0;
      // final pigeon = Pigeon.getById(pigeonId);
      // final chatImage = pigeon?.profile ?? 'images/pigeonProfile/defaultPigeonProfile.png';
      chatImage = 'images/pigeonProfile/magpiePigeonProfile.png'; //can be deleted once TODO is done 
    } else { //if there are more than 1 participants
      chatImage = 'images/group.png';
    }
    return ListTile(
      title: Text(
        chat.name,
        style: Theme.of(context).textTheme.headlineSmall!.copyWith(fontSize: 14),
      ),
      leading: ClipOval(
        child: Image.asset(chatImage),
        ),
      trailing: chat.pinned? const Icon(Icons.push_pin) : null,
    );
  }

  //helper function to render a chatroom
}
