import 'dart:convert';

import 'package:encrypt/encrypt.dart' as Encrypt;
import 'package:modules/base/crypt/security.dart';

String cryptTag = Security.security_spokjfns;
String cryptKey = Security.security_luminakjsnfl1234;

//加密器
class Encryptor {
  static String encryptMap(Map data, {String? secretKey}) {
    return encrypt(const JsonEncoder().convert(data), secretKey: secretKey);
  }

  static String encrypt(String str, {String? secretKey}) {
    final key = Encrypt.Key.fromUtf8(secretKey ?? cryptKey);
    final encryptor = Encrypt.Encrypter(Encrypt.AES(key, mode: Encrypt.AESMode.ecb, padding: Security.security_PKCS7));
    Encrypt.Encrypted encrypted = encryptor.encrypt(str);
    return encrypted.base64;
  }
}

//解密器
class Decryptor {
  static String decrypt(String str, {String? secretKey}) {
    final key = Encrypt.Key.fromUtf8(secretKey ?? cryptKey);
    final encryptor = Encrypt.Encrypter(Encrypt.AES(key, mode: Encrypt.AESMode.ecb, padding: Security.security_PKCS7));
    return encryptor.decrypt64(str);
  }
}
