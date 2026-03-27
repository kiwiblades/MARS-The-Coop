import 'package:frontend/model/chatroom.dart';

class ChatDetailModel {
  bool isEditingChatName = false;

  RelationshipType? selectedRelationshipType;
  String? relationshipError;
  bool isEditingRelationshipType = false;

  bool fineGrainControlEdit = false;
  Set<QuestionType> questionTypePreferenceEdits = {};
  Set<QuestionTopic> questionTopicPreferenceEdits = {};
  bool isEditingQuestionPreferences = false;

//TODO: delete test values once actual values are implemented
  bool isOwner = true; //for conditional render test
  bool fineGrainTest = true; 
  Set<QuestionType> questionTypePreferenceTest = {QuestionType.favorite, QuestionType.ifYouCould, QuestionType.memory };
  Set<QuestionTopic> questionTopicPreferenceTest = {QuestionTopic.intimacy, QuestionTopic.politics};
}