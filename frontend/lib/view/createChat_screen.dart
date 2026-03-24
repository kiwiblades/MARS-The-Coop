import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/createChat_controller.dart';
import 'package:frontend/model/chatroom.dart';
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

//helper function to take the relationship type enum and make it a string for labels
String formatRelationship(RelationshipType type) {
  switch (type) {
    case RelationshipType.acquaintance:
      return "Acquaintance";
    case RelationshipType.family:
      return "Family";
    case RelationshipType.friends:
      return "Friends";
    case RelationshipType.romantic:
      return "Romantic";
  }
}

class CreateChatScreenState extends State<CreateChatScreen> {
  late final CreateChatController controller;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  //form controllers
  final TextEditingController chatroomNameController = TextEditingController();
  RelationshipType? selectedRelationship; //selected relationship
  String? relationshipError;

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
                  Text(
                    'Relationship Type',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 20.0,
                      color: AppColors.darkBrown,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(height: 10.0),
                  DropdownMenu<RelationshipType>(
                    width: MediaQuery.of(context).size.width - 40, // make width of dropdown and input equal
                    initialSelection: selectedRelationship,
                    errorText: relationshipError,
                    onSelected: (value) {
                      setState(() {
                        selectedRelationship = value;
                      });
                    },
                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.darkBrown,
                      fontSize: 16,
                    ),
                    menuStyle: MenuStyle(
                      backgroundColor: WidgetStateProperty.all(AppColors.background),
                      elevation: WidgetStateProperty.all(1),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    dropdownMenuEntries: RelationshipType.values.map((type) {
                      return DropdownMenuEntry(
                        value: type,
                        label: formatRelationship(type),
                        style: ButtonStyle(
                          textStyle: WidgetStateProperty.all(
                            const TextStyle(fontSize: 16),
                          ),
                          foregroundColor: WidgetStateProperty.all(
                            AppColors.darkBrown,
                          ),
                        ),
                      );
                    }).toList(),
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

void showCodePopup(BuildContext context, String code) {
  //helper function to show code banner
  showDialog(
    context: context,
    builder: (context) {
      return CodeBannerPopup(code: code);
    },
  );
}

class CodeBannerPopup extends StatelessWidget {
  //code banner element
  final String code;

  const CodeBannerPopup({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero, // removes side margins
      child: Stack(
        clipBehavior: Clip.none, //keeps from overflow error
        alignment: Alignment.center,
        children: [
          Image.asset(
            'images/codeBanner.png',
            width: screenWidth,
            fit: BoxFit.fitWidth,
          ),

          //code: + <code>
          Positioned.fill(
            left: screenWidth * 0.16,

            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "code: $code", //code text
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontSize: 17.0,
                      color: AppColors.darkBrown,
                    ),
                  ),
                  IconButton(
                    //copy button
                    icon: const Icon(
                      Icons.copy,
                      size: 20,
                      color: AppColors.darkBrown,
                    ),
                    onPressed: () {
                      //show that the code has been copied
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Code copied!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
