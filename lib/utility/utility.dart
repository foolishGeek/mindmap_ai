import 'package:flutter_dotenv/flutter_dotenv.dart';

class Utility {
  Utility._();

  static String get openAiKey =>
      dotenv.maybeGet('OPEN_API_KEY') ??
      const String.fromEnvironment('OPEN_API_KEY', defaultValue: '');
}
