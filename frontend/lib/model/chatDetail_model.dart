import 'chatroom.dart';

class ChatDetailModel {
  // The actual data object from the backend
  Chatroom? currentChatroom;

  bool isEditingChatName = false;

  RelationshipType? selectedRelationshipType;
  String? relationshipError;
  bool isEditingRelationshipType = false;

  bool fineGrainControlEdit = false;
  // Set for preventing duplicates
  Set<QuestionType> questionTypePreferenceEdits = {};
  Set<QuestionTopic> questionTopicPreferenceEdits = {};
  bool isEditingQuestionPreferences = false;

  // bool isOwner = true; //for conditional render test
  bool get isOwner => currentChatroom?.membership == 'owner';

  // HELPER: Getters to safely access current values from the chatroom object
  String get chatName => currentChatroom?.name ?? '';
  String get chatId => currentChatroom?.id ?? '';

  bool fineGrainTest = true;
  Set<QuestionType> questionTypePreferenceTest = {
    QuestionType.favorite,
    QuestionType.ifYouCould,
    QuestionType.memory,
  };
  Set<QuestionTopic> questionTopicPreferenceTest = {
    QuestionTopic.intimacy,
    QuestionTopic.politics,
  };
}