import 'package:frontend/model/journalentry_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class JournalService {
  final String baseUrl;
  final String? authToken;

  JournalService({required this.baseUrl, this.authToken});

  Future<List<JournalEntry>> getEntries(String journalId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/journal/$journalId/entries'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => JournalEntry.fromJson(e)).toList();
    } else {
      throw Exception('failed to load entries');
    }
  }

  // create new entry
  Future<JournalEntry> createEntry(String journalId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/journal/$journalId/entries'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 201) {
      return JournalEntry.fromJson(json.decode(response.body));
    } else {
      throw Exception('failed to create entry');
    }
  }

  // update entry
  Future<JournalEntry> updateEntry(String journalId, String entryId, String content) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/journal/$journalId/entries/$entryId'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
      body: json.encode({'content': content}),
    );

    if (response.statusCode == 200) {
      return JournalEntry.fromJson(json.decode(response.body));
    } else {
      throw Exception('failed to update entry');
    }
  }

  // delete entry
  Future<void> deleteEntry(String journalId, String entryId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/journal/$journalId/entries/$entryId'),
      headers: {
        'Authorization': 'Bearer $authToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('failed to delete entry');
    }
  }
}