import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/chatDetail_controller.dart';
import 'package:frontend/model/chatDetail_model.dart';
import 'package:frontend/model/chatroom.dart';
import 'package:frontend/model/profile_model.dart';
import 'package:frontend/services/api_client.dart';
import 'package:frontend/services/chatroom_service.dart';
import 'package:frontend/services/user_service.dart';

class ChatDetailScreen extends StatefulWidget {
  static const String routeName = '/chatDetailScreen';
  final Chatroom chatroom;
  final void Function(Chatroom)? onSettingsChanged;
  const ChatDetailScreen({
    super.key,
    required this.chatroom,
    this.onSettingsChanged,
  });

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
  late final UserService userService;
  late ChatDetailModel model;

  User? currentUser;
  Chatroom? currentChatroom;
  final GlobalKey<FormState> formKeyChatName = GlobalKey<FormState>();
  final GlobalKey<FormState> formKeyRelationshipType = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    final chatroomService = ChatroomService(api: apiClient);
    userService = UserService(api: apiClient);
    model = ChatDetailModel();
    controller = ChatDetailController(
      this,
      chatroomService: chatroomService,
      userService: userService,
    );
    controller.init(widget.chatroom);
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await userService.getProfile();

    if (mounted) {
      setState(() {
        currentUser = user;
      });
    }
  }

  void callSetState(fn) => setState(fn);

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
                      model.currentChatroom?.inviteCode ?? '<CODE>',
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
                          ClipboardData(
                            text: model.currentChatroom?.inviteCode ?? '',
                          ),
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
                                initialValue: model.currentChatroom?.name ?? '',
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
                              model.currentChatroom?.name ?? '<Chat Name>',
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
                  model.currentChatroom?.membership ?? '<Participant Role>',
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
                model.isOwner
                    ? Form(
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
                                    formatEnumName(
                                      model
                                              .currentChatroom
                                              ?.relationshipType
                                              .name ??
                                          '<Relationship Type>',
                                    ),
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
                            formatEnumName(
                              model.currentChatroom?.relationshipType.name ??
                                  '<Relationship Type>',
                            ),
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
                                .fineGrainControlEdit
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
                    //if editing and toggle is off
                    if (model.isEditingQuestionPreferences &&
                        !model.fineGrainControlEdit) //if editing, toggle
                      IconButton(
                        //relationship type edit save
                        onPressed: controller.onPressedEditFineGrainControlSave,
                        icon: const Icon(
                          Icons.check,
                          color: AppColors.darkBrown,
                        ),
                      ),
                    if (model.isEditingQuestionPreferences &&
                        !model.fineGrainControlEdit) //if editing, toggle
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
                //bullet pointed list if not editing
                if (!model.isEditingQuestionPreferences &&
                    model.fineGrainControlEdit)
                  Column(
                    children: [
                      if (model.currentChatroom?.membership != 'owner')
                        SizedBox(height: 15),
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
                                  ...(model.currentChatroom?.allowedTypes ?? {})
                                      .map((type) {
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
                                      })
                                      .toList(),
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
                                  ...(model.currentChatroom?.allowedTopics ??
                                          {})
                                      .map((topic) {
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
                                      })
                                      .toList(),
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
                      if (model.fineGrainControlEdit)
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                //MEMBER LIST: For all
                Text(
                  "Members", //label
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 16.0,
                    color: AppColors.darkBrown,
                  ),
                  textAlign: TextAlign.left,
                ),
                const SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    //Top and bottom border of member list
                    border: Border(
                      top: BorderSide(color: AppColors.darkBrown, width: 1.5),
                      bottom: BorderSide(
                        color: AppColors.darkBrown,
                        width: 1.5,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...?model.currentChatroom?.participants.map((user) {
                        final isOwner =
                            model.currentChatroom?.owner.username ==
                            user.username;

                        return SizedBox(
                          height: 34, //control row height
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                flex: 2,
                                child: Row(
                                  children: [
                                    if (isOwner) //special mark if the listed member is the owner
                                      const Icon(
                                        Icons.star_rounded,
                                        size: 16,
                                        color: AppColors.darkBrown,
                                      ),

                                    Text(
                                      user.username,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontSize: 20.0,
                                            color: AppColors.darkBrown,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              //If the current user is the owner, they should see the "more" buttons
                              if (model.currentChatroom?.owner.username == currentUser?.username &&
                                  user.username != model.currentChatroom?.owner.username)
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Builder(
                                      builder: (context) {
                                        return IconButton(
                                          onPressed: () async {
                                            final RenderBox button =
                                                context.findRenderObject()
                                                    as RenderBox;
                                            final RenderBox overlay =
                                                Overlay.of(
                                                      context,
                                                    ).context.findRenderObject()
                                                    as RenderBox;

                                            final position =
                                                RelativeRect.fromRect(
                                                  Rect.fromPoints(
                                                    button.localToGlobal(
                                                      Offset.zero,
                                                      ancestor: overlay,
                                                    ),
                                                    button.localToGlobal(
                                                      button.size.bottomRight(
                                                        Offset.zero,
                                                      ),
                                                      ancestor: overlay,
                                                    ),
                                                  ),
                                                  Offset.zero & overlay.size,
                                                );

                                            final selected =
                                                await showMenu<String>(
                                                  context: context,
                                                  position: position,
                                                  color: AppColors.background,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          10,
                                                        ),
                                                  ),
                                                  items: [
                                                    PopupMenuItem(
                                                      value: 'promote',
                                                      child: Text(
                                                        'Promote to Owner',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              fontSize: 16.0,
                                                              color: AppColors
                                                                  .darkBrown,
                                                            ),
                                                      ),
                                                    ),
                                                    PopupMenuItem(
                                                      value: 'ban',
                                                      child: Text(
                                                        'Ban User',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodySmall
                                                            ?.copyWith(
                                                              fontSize: 16.0,
                                                              color: AppColors
                                                                  .darkBrown,
                                                            ),
                                                      ),
                                                    ),
                                                  ],
                                                );

                                            if (selected != null) {
                                              controller.onMemberMoreActions(
                                                //Controller listener connection
                                                selected,
                                                user,
                                              );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.more_vert,
                                            size: 20,
                                            color: AppColors.darkBrown,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                //BANNED LIST: For owner
                if (model.currentChatroom?.owner.username ==
                    currentUser?.username)
                  Text(
                    "Banned Users", //label
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 16.0,
                      color: AppColors.darkBrown,
                    ),
                    textAlign: TextAlign.left,
                  ),
                if (model.currentChatroom?.owner.username ==
                    currentUser?.username)
                  const SizedBox(height: 10),
                if (model.currentChatroom?.owner.username ==
                    currentUser?.username)
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: AppColors.darkBrown, width: 1.5),
                        bottom: BorderSide(
                          color: AppColors.darkBrown,
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //if (model.currentChatroom?.bannedUsers?.isEmpty)
                        if (model.currentChatroom?.bannedUsers.isEmpty ?? true)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "No one is currently banned from this chat.",
                                style: Theme.of(context).textTheme.headlineLarge
                                    ?.copyWith(
                                      fontSize: 16.0,
                                      color: AppColors.darkBrown,
                                    ),
                              ),
                            ),
                          ),
                        ...?model.currentChatroom?.bannedUsers.map((user) {
                          return SizedBox(
                            height: 34, //control row height
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    children: [
                                      Text(
                                        user.username,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              fontSize: 20.0,
                                              color: AppColors.darkBrown,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Builder(
                                      builder: (context) {
                                        return IconButton(
                                          onPressed: () async {
                                            final confirmed =
                                                await showDialog<bool>(
                                                  context: context,
                                                  builder: (context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                        "Unban User",
                                                      ),
                                                      content: Text(
                                                        "Unban ${user.username}?",
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                false,
                                                              ),
                                                          child: const Text(
                                                            "Cancel",
                                                          ),
                                                        ),
                                                        TextButton(
                                                          onPressed: () =>
                                                              Navigator.pop(
                                                                context,
                                                                true,
                                                              ),
                                                          child: const Text(
                                                            "Unban",
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );

                                            if (confirmed == true) {
                                              controller
                                                  .onBannedUserMoreActions(
                                                    'unban',
                                                    user,
                                                  );
                                            }
                                          },
                                          icon: const Icon(
                                            Icons.more_vert,
                                            size: 20,
                                            color: AppColors.darkBrown,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                SizedBox(height: 10),
                //LEAVE For non-owner
                if (model.currentChatroom?.membership != null &&
                    model.currentChatroom?.membership != 'owner')
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
                if (model.currentChatroom?.membership == 'owner')
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

//PROMOTE TO OWNER confimation
Future<bool?> showPromoteConfirmationPopUp(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return PromoteConfirmationPopUp();
    },
  );
}

class PromoteConfirmationPopUp extends StatelessWidget {
  const PromoteConfirmationPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Promote to Owner'),
      content: Text(
        'Are you sure you want to promote the selected user to owner? In doing so you relinquish the title and all subsequence privileges.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Promote', style: TextStyle(color: AppColors.error)),
        ),
      ],
    );
  }
}

//DELETE Confirmation
Future<bool?> showDeleteConfirmationPopUp(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return DeleteConfirmationPopUp();
    },
  );
}

class DeleteConfirmationPopUp extends StatelessWidget {
  const DeleteConfirmationPopUp({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Chat'),
      content: Text(
        'Are you sure you want to delete this chat? You will be deleting it for all members.',
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
  BuildContext context,
  int numberOfParticipants,
) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return LeaveConfirmationPopUp(numberOfParticipants: numberOfParticipants);
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
