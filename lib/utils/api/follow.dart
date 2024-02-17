import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'package:socialtask/utils/logger.dart';

class Follow {
  int? profileId;
  int? userId;
  String? action;
}

class FollowService {
  Future<void> followUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = '${Constants.baseUrl}/follow/$userId?token=$token';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        customLogger.logInfo('Successfully followed user $userId');
        // Handle successful follow, e.g., show a success message
      } else if (response.statusCode == 400) {
        customLogger.logInfo('Failed to follow user $userId');
        // Handle errors accordingly
      } else {
        customLogger.logInfo(
            'Failed to follow user $userId with status code: ${response.statusCode}');
        // Handle errors accordingly
      }
    } catch (e) {
      customLogger.logError('Failed to follow user $userId: $e');
      // Handle network or other exceptions here
    }
  }

  Future<void> unfollowUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = '${Constants.baseUrl}/unfollow/$userId?token=$token';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        customLogger.logInfo('Successfully unfollowed user $userId');
        // Handle successful unfollow, e.g., show a success message
      } else if (response.statusCode == 400) {
        customLogger.logInfo('Failed to unfollow user $userId');
        // Handle errors accordingly
      } else {
        customLogger.logInfo(
            'Failed to unfollow user $userId with status code: ${response.statusCode}');
        // Handle errors accordingly
      }
    } catch (e) {
      customLogger.logError('Failed to unfollow user $userId: $e');
      // Handle network or other exceptions here
    }
  }

  Future<bool> fetchFollowStatus(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = '${Constants.baseUrl}/followStatus/$userId?token=$token';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final bool isFollowing = json.decode(response.body)['isFollowing'];
        customLogger.logInfo('Fetched follow status for user $userId');
        return isFollowing;
      } else {
        customLogger.logInfo(
            'Failed to fetch follow status for user $userId with status code: ${response.statusCode}');
        throw Exception('Failed to fetch follow status');
      }
    } catch (e) {
      customLogger
          .logError('Failed to fetch follow status for user $userId: $e');
      throw Exception('Failed to fetch follow status: $e');
    }
  }

  // Otras funciones relacionadas con el seguimiento
}
