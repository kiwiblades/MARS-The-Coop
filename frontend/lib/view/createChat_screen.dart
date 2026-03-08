import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/createChat_controller.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/chatroom_service.dart';

class CreateChatScreen extends StatefulWidget {
  static const String routeName = '/createChatScreen';
  const CreateChatScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return CreateChatScreenState();
  }
}

class CreateChatScreenState extends State<CreateChatScreen> {
  late final CreateChatController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //form controllers
  final TextEditingController chatroomNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final chatroomService = ChatroomService(api: ApiClient());
    controller = CreateChatController(this, chatroomService: chatroomService);
  }

  @override
  void dispose() {
    chatroomNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFD1A681),
        image: DecorationImage(
          image: AssetImage('images/woodGrainTexture.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color(0xFFD1A681),
          title: Text(
            'New Chat',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20.0,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chat Name',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 20.0,
                      color: AppColors.darkBrown,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: chatroomNameController,
                    decoration: InputDecoration(
                      labelText: 'chat name',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.chatNameValidator,
                  ),
                  SizedBox(height: 10.0),
                  Center(
                    child: ElevatedButton(
                      onPressed: controller.onPressCreate,
                      child: Text(
                        'create',
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              fontSize: 20.0,
                              color: AppColors.darkBrown,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
