import 'package:modules/base/environment/environment.dart';

class ApiConfig {
  static String get baseUrl => Environment.type == EnvironmentType.dev ? 'https://test-api.luminaai.buzz' : 'https://api.luminaai.buzz';
  static const String path = '/luminaai';
  static String get wsUrl => Environment.type == EnvironmentType.dev ? 'ws://test-ws.luminaai.buzz' : 'ws://ws.luminaai.buzz';
}
