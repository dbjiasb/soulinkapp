import 'package:modules/base/crypt/other.dart';
import 'package:flutter/foundation.dart';
import 'package:modules/base/crypt/security.dart';

class Environment {
  static EnvironmentType type = EnvironmentType.prod;

  // 从启动参数初始化
  static void init(List<String> args) {
    type = _parseEnvironment(args);
  }

  static EnvironmentType _parseEnvironment(List<String> args) {
    if (kDebugMode) {
      return EnvironmentType.dev;
    }
    // 优先从编译参数读取
    String env = String.fromEnvironment(Security.security_ENV, defaultValue: '');
    if (env.isNotEmpty) {
      return env == Security.security_dev ? EnvironmentType.dev : EnvironmentType.prod;
    }

    // 其次从命令行参数读取
    final envArg = args.firstWhere((arg) => arg.startsWith(Other.security___env_), orElse: () => Other.security___env_prod).split('=').last;

    return envArg == Security.security_dev ? EnvironmentType.dev : EnvironmentType.prod;
  }
}

enum EnvironmentType { dev, prod }
