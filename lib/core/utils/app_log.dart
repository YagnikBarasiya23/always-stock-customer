import 'package:flutter/foundation.dart';

abstract class AppLog {
  
  static const String _reset = '\x1B[0m';
  static const String _cyan = '\x1B[36m'; 
  static const String _green = '\x1B[32m'; 
  static const String _red = '\x1B[31m'; 
  static const String _yellow = '\x1B[33m'; 

  static void requestLog(String subject, String message) => _log('REQUEST', subject, message, _cyan);

  static void responseLog(String subject, String message) => _log('RESPONSE', subject, message, _green);

  static void errorLog(String subject, dynamic e) => _log('ERROR', subject, e.toString(), _red);

  static void infoLog(String subject, String message) => _log('INFO', subject, message, _yellow);

  static void _log(String tag, String subject, String message, String color) {
    if (!kDebugMode) return; 
    final buffer = StringBuffer()
      ..write(color)
      ..write('[$tag] ')
      ..write('[$subject] ')
      ..write(message)
      ..write(_reset);

    
    debugPrint(buffer.toString());
  }
}
