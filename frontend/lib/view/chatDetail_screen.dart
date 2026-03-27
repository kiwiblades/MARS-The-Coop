import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/chatDetail_controller.dart';
import 'package:frontend/model/chatDetail_model.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/profile_model.dart';

class ChatDetailScreen extends StatefulWidget {
  static const String routeName = '/chatDetailScreen';
  const ChatDetailScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return ChatDetailScreenState();
  }
}

String formatEnumName(String name) {
  return name
      .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
      .replaceFirst(name[0], name[0].toUpperCase());
}

class ChatDetailScreenState extends State<ChatDetailScreen> {
  late final ChatDetailController controller;
  late ChatDetailModel model;

  User? currentUser; //TODO: current user for role and conditional rendering
  Chatroom? currentChat; //TODO: current chatroom to grab details from
  final GlobalKey<FormState> formKeyChatName = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyRelationshipType = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    controller = ChatDetailController(this);
    model = ChatDetailModel();
  }

  void callSetState(fn) => setState(fn);

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
            'Chat Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 20.0,
              color: AppColors.darkBrown,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //CODE
                Text(
                  "Code", //label
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 16.0,
                    color: AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5), //spacer
                Row(
                  children: [
                    Text(
                      //code
                      currentChat?.inviteCode ?? '<CODE>',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 20.0,
                        color: AppColors.darkBrown,
                      ),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                      //code copy button
                      onPressed: () {
                        //show that the code has been copied
                        Clipboard.setData(
                          ClipboardData(text: currentChat!.inviteCode),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 20,
                        color: AppColors.darkBrown,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10), //spacer
                //CHAT NAME
                Text(
                  "Name", //label
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 16.0,
                    color: AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5), //spacer
                Form(
                  key: formKeyChatName,
                  child: Row(
                    children: model.isEditingChatName
                        ? [
                            //if chat name is being edited
                            Expanded(
                              child: TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Chat Name',
                                  border: OutlineInputBorder(),
                                ),
                                initialValue: currentChat?.name ?? '',
                                validator: controller.chatNameValidator,
                                onSaved: controller.onSaveChatName,
                              ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              //chat name edit save
                              onPressed: controller.onPressedEditChatNameSave,
                              icon: const Icon(
                                Icons.check,
                                color: AppColors.darkBrown,
                              ),
                            ),
                            IconButton(
                              //chat name cancel
                              onPressed: controller.onPressedEditChatNameCancel,
                              icon: const Icon(
                                Icons.close,
                                color: AppColors.darkBrown,
                              ),
                            ),
                          ]
                        : [
                            Text(
                              //chat name
                              currentChat?.name ?? '<Chat Name>',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    fontSize: 20.0,
                                    color: AppColors.darkBrown,
                                  ),
                            ),
                            const SizedBox(width: 5),
                            IconButton(
                              //chat name edit button
                              onPressed: controller.onPressedEditChatName,
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.darkBrown,
                              ),
                            ),
                          ],
                  ),
                ),
                const SizedBox(height: 10), //spacer
                //ROLE
                Text(
                  "Role", //label
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 16.0,
                    color: AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10), //spacer
                Text(
                  //role
                  currentChat?.name ??
                      '<Participant Role>', //TODO: i do not know not user role will be grabbed but currentChat?.name will need to be switched out for whatever returns the current user's chat role
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 20.0,
                    color: AppColors.darkBrown,
                  ),
                ),
                const SizedBox(height: 20),

                //RELATIONSHIP TYPE
                Text(
                  "Relationship Type", //label
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 16.0,
                    color: AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 5), //spacer
                //TODO: conditional statement for rendering i.e. if(current user is the owner), again i do not know how role will be accesible
                model.isOwner
                    ? //test value TODO: replace with correct conditional
                      Form(
                        key: formKeyRelationshipType,
                        child: Row(
                          children: model.isEditingRelationshipType
                              ? [
                                  //if relationship type is being edited
                                  Expanded(
                                    child: LayoutBuilder(
                                      //necessary for dropdown to be correct width
                                      builder: (context, constraints) {
                                        final width = constraints.maxWidth;

                                        return DropdownMenu<RelationshipType>(
                                          width: width,
                                          menuStyle: MenuStyle(
                                            backgroundColor:
                                                WidgetStateProperty.all(
                                                  AppColors.background,
                                                ),
                                            elevation: WidgetStateProperty.all(
                                              1,
                                            ),
                                            shape: WidgetStateProperty.all(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            maximumSize:
                                                WidgetStateProperty.all(
                                                  Size(width, 250),
                                                ),
                                          ),
                                          textStyle: Theme.of(context)
                                              .textTheme
                                              .bodyLarge
                                              ?.copyWith(
                                                color: AppColors.darkBrown,
                                                fontSize: 16,
                                              ),
                                          initialSelection:
                                              model.selectedRelationshipType,
                                          errorText: model.relationshipError,
                                          onSelected: controller
                                              .onSelectRelationshipType,
                                          dropdownMenuEntries: RelationshipType
                                              .values
                                              .map((type) {
                                                return DropdownMenuEntry(
                                                  value: type,
                                                  label: formatEnumName(
                                                    type.name,
                                                  ),
                                                  style: ButtonStyle(
                                                    textStyle:
                                                        WidgetStateProperty.all(
                                                          const TextStyle(
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                    foregroundColor:
                                                        WidgetStateProperty.all(
                                                          AppColors.darkBrown,
                                                        ),
                                                  ),
                                                );
                                              })
                                              .toList(),
                                        );
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  IconButton(
                                    //relationship type edit save
                                    onPressed: controller
                                        .onPressedEditRelationshipTypeSave,
                                    icon: const Icon(
                                      Icons.check,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                  IconButton(
                                    //relationship type cancel
                                    onPressed: controller
                                        .onPressedEditRelationshipTypeCancel,
                                    icon: const Icon(
                                      Icons.close,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ]
                              : [
                                  Text(
                                    //relationship type
                                    currentChat?.name ?? '<Relationship Type>', //TODO: replace with currentChat?.relationshipType
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 20.0,
                                          color: AppColors.darkBrown,
                                        ),
                                  ),
                                  const SizedBox(width: 5),
                                  IconButton(
                                    //relationship type edit button
                                    onPressed: controller.onPressedEditRelationshipType,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ],
                        ),
                      )
                    : Column( //if current user is not an owner they cannot edit relationship type
                        children: [
                          const SizedBox(height: 6), //spacer
                          Text(
                            //relationship type
                            currentChat?.name ??'<Relationship Type>', //TODO: replace with currentChat?.relationshipType
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 20.0,
                                  color: AppColors.darkBrown,
                                ),
                          ),
                        ],
                      ),
                const SizedBox(height: 10), //spacer
              ],
            ),
          ),
        ),
      ),
    );
  }
}
