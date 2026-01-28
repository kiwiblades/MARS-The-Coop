/*
  Example service to validate API connectivity.
  Calls GET /health. You can check this endpoint in your web browser, too.
*/

import 'api_client.dart';

class HealthService {
  final ApiClient api;
  HealthService(this.api);

  Future<Map<String, dynamic>> fetchHealth() => api.getJson('/health');
}