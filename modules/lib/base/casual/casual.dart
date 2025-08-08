import 'dart:math';

import 'package:uuid/uuid.dart';

class Casual {
  //给定一个字符串长度，随机生成一个字符串
  // static String randomString(int length) {}

  //给定一个范围，生成一个随机数字
  static int randomInRange(int min, int max) {
    if (min >= max) {
      throw ArgumentError('min must be less than max');
    }
    final random = Random.secure();
    return min + random.nextInt(max - min + 1);
  }

  //给定一个正数，生成0到该数减1范围内的随机数字
  static int randomWithin(int max) {
    if (max <= 0) {
      throw ArgumentError('max must be a positive number');
    }
    return randomInRange(0, max - 1);
  }

  //生成一个随机的UUID
  static String randomUUID() {
    return const Uuid().v4().replaceAll('-', '');
  }

  //随机生成一个ip
  static String randomIP() {
    return '${randomWithin(255)}.${randomWithin(255)}.${randomWithin(255)}.${randomWithin(255)}';
  }

  //随机生成一个时区
  static String randomTimeZone() {
    return 'UTC+${randomWithin(12)}';
  }
}
