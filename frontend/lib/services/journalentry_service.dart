import 'api_client.dart';

class JournalService {
  final ApiClient api;
  JournalService({required this.api});

  // get all entries from a journal
  // get /journals/:id
  Future<List<dynamic>> getEntriesBySubject(String subjectId) async {
    final data = await api.getJsonList('/journals/$subjectId');
    return data.reversed.toList();
  }

  // get each journal (journal per user)
  // get /journals/subjects
  Future<List<dynamic>> getJournalSubjects() async {
    return await api.getJsonList('/journals/subjects');
  }

  // get users that a journal can be made for
  // get /journals/eligible-subjects
  Future<List<dynamic>> getEligibleSubjects({String? search}) async {
    final path = search != null && search.isNotEmpty
      ? '/journals/eligible-subjects?search=$search'
      : '/journals/eligible-subjects';
    return await api.getJsonList(path);
  }

  // create new journal entry within a journal
  // post /journals
  Future<Map<String, dynamic>> createEntry({
    required String subjectId,
    required String content,
  }) async {
    return await api.postJson('/journals', {
      'subjectId': subjectId,
      'content': content,
    });
  }

  // update entry
  // patch /journals/:id
  Future<void> updateEntry({
    required String entryId,
    required String content,
  }) async {
    await api.patchJson('/journals/$entryId', {'content': content});
  }

  // delete entry
  // delete /journals/:id
  Future<void> deleteEntry(String entryId) async {
    await api.deleteJson('/journals/$entryId', {});
  }
}