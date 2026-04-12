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
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      editedAt: json['editedAt'] != null ? DateTime.parse(json['editedAt']) : null,
    );
  }

  bool get isEdited => editedAt != null;
}