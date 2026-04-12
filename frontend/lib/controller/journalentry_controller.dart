import '../model/journalentry_model.dart';
import '../services/api_client.dart';

class JournalController {
  final String journalId;
  final String subjectId; // ID of the 'bird' (the person the journal is about)
  final ApiClient api = ApiClient();

  JournalController(this.journalId, this.subjectId);

  // load journal entries from backend
  Future<Map<String, dynamic>> loadEntries({
    int offset = 0,
    int limit = 50,
  }) async {
    try {
      // The backend route is /api/journals/:subjectId
      final List<dynamic> response = await api.getJsonList(
        '/api/journals/$subjectId',
      );

      final entries = response
          .map((data) => JournalEntry.fromJson(data))
          .toList();

      // mock data for now
      //await Future.delayed(Duration(milliseconds: 500));
      return {
        'success': true,
        'entries': entries, // real entries from backend
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
      final data = await api.postJson('/journals', {
        'subjectId': subjectId,
        'content': content,
      });

      // Map the backend response back to a JournalEntry object
      final newEntry = JournalEntry.fromJson(data);

      //await Future.delayed(Duration(milliseconds: 300));
      // final newEntry = JournalEntry(
      //   id: DateTime.now().millisecondsSinceEpoch.toString(),
      //   content: content,
      //   timestamp: DateTime.now(),
      // );

      return {'success': true, 'entry': newEntry};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // update existing entry
  Future<Map<String, dynamic>> updateEntry(
    String entryId,
    String content,
  ) async {
    try {
      await api.patchJson('/journals/entry/$entryId', {'content': content});

      //await Future.delayed(Duration(milliseconds: 300));
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // delete entry
  Future<Map<String, dynamic>> deleteEntry(String entryId) async {
    try {
      await api.deleteJson('/journals/entry/$entryId', {});

      //await Future.delayed(Duration(milliseconds: 300));
      return {'success': true};
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }
}
