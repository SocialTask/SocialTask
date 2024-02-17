import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Constants {
  static const String BaseUrl = '';

  static String baseUrl = BaseUrl;

  static Future<void> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? selectedServer = prefs.getString('selectedServer');
    if (selectedServer != null) {
      baseUrl = selectedServer;
    }
  }
}
