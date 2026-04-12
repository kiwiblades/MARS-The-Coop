import 'package:flutter/material.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/addChat_controller.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/chatroom_service.dart';

class AddChatScreen extends StatefulWidget {
  static const String routeName = '/addChatScreen';
  const AddChatScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return AddChatScreenState();
  }
}

class AddChatScreenState extends State<AddChatScreen> {
  late final AddChatController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //form controllers
  final TextEditingController chatroomCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final chatroomService = ChatroomService(api: ApiClient());
    controller = AddChatController(this, chatroomService: chatroomService);
  }

  @override
  void dispose() {
    chatroomCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFD1A681),
        image: DecorationImage(
          image: AssetImage('images/woodGrainTexture.webp'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Color(0xFFD1A681),
          // title: const Text(''),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Join with code',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 20.0,
                      color: AppColors.darkBrown,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.0),
                  TextFormField(
                    controller: chatroomCodeController,
                    decoration: InputDecoration(
                      labelText: 'code',
                      border: OutlineInputBorder(),
                    ),
                    validator: controller.chatCodeValidator,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: controller.onPressJoin,
                    child: Text(
                      'Join',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 20.0,
                            color: AppColors.darkBrown,
                          ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'or',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 16.0,
                      color: AppColors.darkBrown,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.0),
                  ElevatedButton(
                    onPressed: controller.onPressCreateNew,
                    child: Text(
                      'Create New',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontSize: 20.0,
                            color: AppColors.darkBrown,
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
