/*
  Central place to read env style config for the Flutter app.
  Values here come from frontend/.env and are loaded in main().

  NOTE: Do NOT put secrets in frontend/.env. Anything in a Flutter app can be extracted from a build.
*/

import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiBaseUrl =>
    dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:5000';
}