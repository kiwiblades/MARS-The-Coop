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
                                    currentChat?.name ??
                                        '<Relationship Type>', //TODO: replace with currentChat?.relationshipType
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          fontSize: 20.0,
                                          color: AppColors.darkBrown,
                                        ),
                                  ),
                                  const SizedBox(width: 5),
                                  IconButton(
                                    //relationship type edit button
                                    onPressed: controller
                                        .onPressedEditRelationshipType,
                                    icon: const Icon(
                                      Icons.edit,
                                      color: AppColors.darkBrown,
                                    ),
                                  ),
                                ],
                        ),
                      )
                    : Column(
                        //if current user is not an owner they cannot edit relationship type
                        children: [
                          const SizedBox(height: 6), //spacer
                          Text(
                            //relationship type
                            currentChat?.name ??
                                '<Relationship Type>', //TODO: replace with currentChat?.relationshipType
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  fontSize: 20.0,
                                  color: AppColors.darkBrown,
                                ),
                          ),
                          const SizedBox(height: 15), //spacer
                        ],
                      ),
                //FINE GRAIN CONTROL
                Row(
                  children: [
                    if (!model
                        .isEditingQuestionPreferences) //just label is not editing
                      Text(
                        /*currentChat.fineGrainControl*/ model
                                .fineGrainTest //TODO: link actual value
                            ? "Fine-grain Question Control: On"
                            : "Fine-grain Question Control: Off", //label
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 16.0,
                          color: AppColors.darkBrown,
                        ),
                        textAlign: TextAlign.left,
                      ),

                    if (model.isOwner &&
                        !model
                            .isEditingQuestionPreferences) //if owner, edit button
                      IconButton(
                        //fine grain control edit button
                        onPressed: controller.onPressedEditFineGrainControl,
                        icon: const Icon(
                          Icons.edit,
                          color: AppColors.darkBrown,
                        ),
                      ),

                    if (model.isEditingQuestionPreferences) //if editing
                      Text(
                        "Fine-grain Question Control", //without on/off
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 16.0,
                          color: AppColors.darkBrown,
                        ),
                        textAlign: TextAlign.left,
                      ),

                    if (model.isEditingQuestionPreferences) //if editing, toggle
                      Transform.scale(
                        scale: 0.60,
                        child: Switch(
                          value: model.fineGrainControlEdit,
                          inactiveThumbColor: AppColors.darkBrown,
                          inactiveTrackColor: AppColors.background,
                          activeThumbColor: AppColors.darkBrown,
                          trackOutlineColor: WidgetStateProperty.resolveWith((
                            states,
                          ) {
                            if (states.contains(WidgetState.selected)) {
                              return Colors.transparent; // active outline
                            }
                            return AppColors.darkBrown; // inactive outline
                          }),
                          trackOutlineWidth: WidgetStateProperty.all(2.0),
                          onChanged: controller.onToggleFineGrainControl,
                        ),
                      ),
                  ],
                ),
                //bullet pointed list if not editing
                if (!model.isEditingQuestionPreferences)
                  Column(
                    children: [
                      if (!model.isOwner)
                        SizedBox(
                          height: 15,
                        ), //TODO: replace isOwner with role info
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.darkBrown,
                              width: 1.5,
                            ),
                            bottom: BorderSide(
                              color: AppColors.darkBrown,
                              width: 1.5,
                            ),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Question Types
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question Type',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: 18.0,
                                          color: AppColors.darkBrown,
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  // ...?currentChat?.questionTypePreferences.map((type) { //TODO
                                  ...model.questionTypePreferenceTest.map((
                                    type,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: Text(
                                        "• ${formatEnumName(type.name)}",
                                        style: TextStyle(
                                          color: AppColors.darkBrown,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Question Topics
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Question Topic',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: 18.0,
                                          color: AppColors.darkBrown,
                                        ),
                                  ),
                                  const SizedBox(height: 5),
                                  // ...?currentChat?.questionTopicPreferences.map((topic) { //TODO
                                  ...model.questionTopicPreferenceTest.map((
                                    topic,
                                  ) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 2.0,
                                      ),
                                      child: Text(
                                        "• ${formatEnumName(topic.name)}",
                                        style: TextStyle(
                                          color: AppColors.darkBrown,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                if (model.isEditingQuestionPreferences &&
                    model.fineGrainControlEdit)
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            top: BorderSide(
                              color: AppColors.darkBrown,
                              width: 1.5,
                            ),
                            bottom: BorderSide(
                              color: AppColors.darkBrown,
                              width: 1.5,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsetsGeometry.fromLTRB(
                            0.0,
                            5.0,
                            0.0,
                            5.0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                //first column: question Type
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Question Type',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontSize: 20.0,
                                            color: AppColors.darkBrown,
                                          ),
                                    ),

                                    ...QuestionType.values.map((type) {
                                      return SizedBox(
                                        height: 20.0,
                                        child: Row(
                                          // mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                formatEnumName(type.name),
                                                style: TextStyle(
                                                  color: AppColors.darkBrown,
                                                ),
                                              ),
                                            ),
                                            Checkbox(
                                              value: model
                                                  .questionTypePreferenceEdits
                                                  .contains(type),

                                              fillColor:
                                                  WidgetStateProperty.resolveWith(
                                                    (states) {
                                                      if (states.contains(
                                                        WidgetState.selected,
                                                      )) {
                                                        return AppColors
                                                            .darkBrown;
                                                      }
                                                      return AppColors
                                                          .background;
                                                    },
                                                  ),

                                              side: BorderSide(
                                                color: AppColors.darkBrown,
                                                width: 1.5,
                                              ),

                                              onChanged: (value) => controller
                                                  .onToggleQuestionType(
                                                    type,
                                                    value,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10.0),
                              Expanded(
                                //2nd column: question topic
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Question Topic',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            fontSize: 20.0,
                                            color: AppColors.darkBrown,
                                          ),
                                    ),

                                    ...QuestionTopic.values.map((topic) {
                                      return SizedBox(
                                        height: 20.0,
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                formatEnumName(topic.name),
                                                style: TextStyle(
                                                  color: AppColors.darkBrown,
                                                ),
                                              ),
                                            ),
                                            Checkbox(
                                              value: model
                                                  .questionTopicPreferenceEdits
                                                  .contains(topic),

                                              fillColor:
                                                  WidgetStateProperty.resolveWith(
                                                    (states) {
                                                      if (states.contains(
                                                        WidgetState.selected,
                                                      )) {
                                                        return AppColors
                                                            .darkBrown;
                                                      }
                                                      return AppColors
                                                          .background;
                                                    },
                                                  ),

                                              side: BorderSide(
                                                color: AppColors.darkBrown,
                                                width: 1.5,
                                              ),

                                              onChanged: (value) => controller
                                                  .onToggleQuestionTopic(
                                                    topic,
                                                    value,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            //relationship type edit save
                            onPressed:
                                controller.onPressedEditFineGrainControlSave,
                            icon: const Icon(
                              Icons.check,
                              color: AppColors.darkBrown,
                            ),
                          ),
                          IconButton(
                            //relationship type cancel
                            onPressed:
                                controller.onPressedEditFineGrainControlCancel,
                            icon: const Icon(
                              Icons.close,
                              color: AppColors.darkBrown,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                SizedBox(height: 10),
                //LEAVE For non-owner
                if (!model
                    .isOwner) //TODO: replace with actual value for conditional rendering
                  InkWell(
                    onTap: controller.onPressedLeaveChat,
                    child: Row(
                      children: [
                        Text(
                          'Leave Chat',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 20.0,
                                color: AppColors.darkBrown,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.logout,
                          size: 20,
                          color: AppColors.darkBrown,
                        ),
                      ],
                    ),
                  ),
                //DELETE only for owner
                if (model
                    .isOwner) //TODO: replace with actual value for conditional rendering
                  InkWell(
                    onTap: controller.onPressedDeleteChat,
                    child: Row(
                      children: [
                        Text(
                          'Delete Chat',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                fontSize: 20.0,
                                color: AppColors.darkBrown,
                              ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.delete,
                          size: 20,
                          color: AppColors.darkBrown,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//DELETE Confirmation
Future<bool?> showDeleteConfirmationPopUp(
    BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return DeleteConfirmationPopUp(
      );
    },
  );
}
class DeleteConfirmationPopUp extends StatelessWidget {
  const DeleteConfirmationPopUp({super.key,});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Chat'),
      content: Text(
        'Are you sure you want to delete this chat? You will be deleting it for all members.'
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Delete', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}


//LEAVE Confirmation
Future<bool?> showLeaveConfirmationPopUp(
    BuildContext context, int numberOfParticipants) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return LeaveConfirmationPopUp(
        numberOfParticipants: numberOfParticipants,
      );
    },
  );
}
class LeaveConfirmationPopUp extends StatelessWidget {
  final numberOfParticipants;
  const LeaveConfirmationPopUp({super.key, required this.numberOfParticipants});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Leave Chat'),
      content: Text(
        numberOfParticipants == 1
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
    );
  }
}
