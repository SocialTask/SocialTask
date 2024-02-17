import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';

class User {
  int? id;
  String? username;
  String? description;
  int? followersCount;
  int? followingCount;
  int? madeTasks;
  int? points;
  String? profilePicUrl;
  int? verified;

  User({
    this.id,
    this.username,
    this.followersCount,
    this.followingCount,
    this.madeTasks,
    this.points,
    this.profilePicUrl,
    this.verified,
    this.description,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
      madeTasks: json['made_tasks'],
      points: json['points'],
      profilePicUrl: json['profile_pic_url'],
      verified: json['verified'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'followers_count': followersCount,
      'following_count': followingCount,
      'made_tasks': madeTasks,
      'points': points,
      'profile_pic_url': profilePicUrl,
      'verified': verified,
      'description': description,
    };
  }
}

class UsersService {
  Future<List<User>> searchUsers(String query) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = '${Constants.baseUrl}/search?query=$query&token=$token';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<User> users = data.map((userData) {
          final user = User();
          user.id = userData['id'];
          user.username = userData['username'];
          user.followersCount = userData['followers_count'];
          user.followingCount = userData['following_count'];
          user.madeTasks = userData['made_tasks'];
          user.points = userData['points'];
          user.profilePicUrl = userData['profile_pic_url'];
          user.verified = userData['verified'];
          return user;
        }).toList();
        return users;
      } else {
        throw Exception(
            'User search failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('User search failed: $e');
    }
  }
// TODO: USE SHARED PREFERENCES TO CACHE USER'S DATA. (as in profile.dart)

  Future<User> fetchUser(String username, {bool fromid = false}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final fromidParam = fromid ? 'true' : 'false'; // Convert boolean to string
    final url =
        '${Constants.baseUrl}/user/$username?token=$token&fromid=$fromidParam';

    final cachedUserData =
        prefs.getString('cachedUserData_$username'); // Retrieve cached data

    if (cachedUserData != null) {
      final Map<String, dynamic> jsonData = json.decode(cachedUserData);
      final User cachedUser = User.fromJson(jsonData['user']);
      final DateTime cachedTime = DateTime.parse(jsonData['timestamp']);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(cachedTime);

      if (difference.inMinutes <= 30) {
        return cachedUser; // Return cached data if it's less than 1 minutes old
      }
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> userData = json.decode(response.body);
        final User user = User.fromJson(userData);

        // Cache the data with timestamp
        final jsonData = {
          'timestamp': DateTime.now().toIso8601String(),
          'user': user.toJson(),
        };
        prefs.setString('cachedUserData_$username', json.encode(jsonData));

        return user;
      } else if (response.statusCode == 401) {
        throw Exception('Token is invalid or expired');
      } else {
        throw Exception(
            'Failed to fetch user with status code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Otras funciones relacionadas con el usuario
}
