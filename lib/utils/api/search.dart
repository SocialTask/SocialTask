import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socialtask/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import 'package:socialtask/utils/api/users.dart';

class SearchService {
  Future<List<User>> searchUsers(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null || token.isEmpty) {
      throw Exception('Token is missing or empty');
    }

    final url = '${Constants.baseUrl}/search?query=$query&token=$token';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<User> users =
            data.map((userMap) => User.fromJson(userMap)).toList();
        return users;
      } else {
        customLogger.logInfo(
            'User search failed with status code: ${response.statusCode}');
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['error'];
        customLogger.logInfo('Error message: $errorMessage');
        throw Exception('User search failed');
      }
    } catch (e) {
      customLogger.logError('User search failed: $e');
      throw Exception('User search failed');
    }
  }
}
