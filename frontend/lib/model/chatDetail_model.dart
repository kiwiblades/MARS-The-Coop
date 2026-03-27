import 'package:frontend/model/chatroom.dart';

class ChatDetailModel {
  bool isEditingChatName = false;
  RelationshipType? selectedRelationshipType;
  String? relationshipError;
  bool isEditingRelationshipType = false;

  bool isOwner = true; //for conditional render test
}