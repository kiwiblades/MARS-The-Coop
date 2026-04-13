import 'package:frontend/services/journalentry_service.dart';
import '../model/journalentry_model.dart';

class JournalController {
  final String subjectId; // ID of the 'bird' (the person the journal is about)
  final JournalService journalService;

  JournalController(this.subjectId, {required this.journalService});

  // load journal entries from backend
  Future<Map<String, dynamic>> loadEntries({
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      final response = await journalService.getEntriesBySubject(subjectId);
      final entries = response
        .map((data) => JournalEntry.fromJson(data))
        .toList();
      return {
        'success': true,
        'entries': entries,
        'hasMore': false,
      };
    } catch (e) {
      print("FATAL JOURNAL LOAD ERROR: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // create new journal entry
  Future<Map<String, dynamic>> createEntry(String content) async {
    try {
      final data = await journalService.createEntry(
        subjectId: subjectId,
        content: content,
      );
      final newEntry = JournalEntry.fromJson(data);
      return {'success': true, 'entry': newEntry};
    } catch(e) {
      print("CREATE ENTRY ERROR: $e");
      return {'success': false, 'error': e.toString()};
    }
  }

  // update existing entry
  Future<Map<String, dynamic>> updateEntry(String entryId, String content) async {
    try {
      await journalService.updateEntry(entryId: entryId, content: content);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // delete entry
  Future<Map<String, dynamic>> deleteEntry(String entryId) async {
    try {
      await journalService.deleteEntry(entryId);
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
