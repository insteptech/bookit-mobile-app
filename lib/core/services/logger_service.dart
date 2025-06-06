import 'package:flutter/material.dart';

class LoggerService {
  void log(String message) {
    debugPrint('[LOG] $message');
  }

  void error(String message, [dynamic error]) {
    debugPrint('[ERROR] $message\n$error');
  }
}
