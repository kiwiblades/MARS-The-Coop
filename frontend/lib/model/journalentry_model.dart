class JournalEntryModel {
  bool isLoading = false;
  bool isSubmitting = false;
  String? loadError;
}

class JournalEntry {
  final String id;
  final String content;
  final DateTime timestamp;
  final DateTime? editedAt;

  JournalEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    this.editedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'].toString(),
      content: json['content'] ?? '',
      //timestamp: DateTime.parse(json['timestamp']),
      timestamp: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      //editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
      editedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  bool get isEdited => editedAt != null;
}
