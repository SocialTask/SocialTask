import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../constants.dart';
import 'dart:io';

class Profile {
  int? userId;
  String? email;
  int? followersCount;
  int? followingCount;
  int? madeTasks;
  int? points;
  String? privacySetting;
  String? profilePicUrl;
  String? username;
  bool? verified;
  String? description;
  String? coverPhotoUrl;

  // Constructor
  Profile({
    this.userId,
    this.email,
    this.followersCount,
    this.followingCount,
    this.madeTasks,
    this.points,
    this.privacySetting,
    this.profilePicUrl,
    this.username,
    this.verified,
    this.description,
    this.coverPhotoUrl,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      userId: json['id'],
      email: json['email'],
      followersCount: json['followers_count'],
      followingCount: json['following_count'],
      madeTasks: json['made_tasks'],
      points: json['points'],
      privacySetting: json['privacy_setting'],
      profilePicUrl: json['profile_pic_url'],
      username: json['username'],
      verified: json['verified'] == 1 ? true : null, // Handle nullability
      description: json['description'],
      coverPhotoUrl: json['cover_photo_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': userId,
      'email': email,
      'followers_count': followersCount,
      'following_count': followingCount,
      'made_tasks': madeTasks,
      'points': points,
      'privacy_setting': privacySetting,
      'profile_pic_url': profilePicUrl,
      'username': username,
      'verified': verified == true ? 1 : 0, // Convert to 1 or 0
      'description': description,
      'cover_photo_url': coverPhotoUrl,
    };
  }
}

class ProfileService {
  // Add a variable to hold the last fetch time
  DateTime? _lastFetchTime;

  // Function to check if the cache is expired
  bool _isCacheExpired() {
    if (_lastFetchTime == null) {
      return true; // Cache is expired if it has never been fetched
    }
    // Check if the difference between current time and last fetch time is more than 1 minute
    return DateTime.now().difference(_lastFetchTime!) >
        const Duration(minutes: 1);
  }

  // Function to save profile data in SharedPreferences
  Future<void> saveProfileData(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileData', json.encode(profile.toJson()));
  }

  // Function to fetch profile data from SharedPreferences
  Future<Profile?> getProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    final profileDataString = prefs.getString('profileData');
    if (profileDataString != null) {
      final profileData = json.decode(profileDataString);
      return Profile.fromJson(profileData);
    }
    return null;
  }

  Future<Profile> fetchProfile(BuildContext context) async {
    // Check if cache is expired
    if (!_isCacheExpired()) {
      // If cache is not expired, retrieve profile data from SharedPreferences
      final profileFromCache = await getProfileData();
      if (profileFromCache != null) {
        return profileFromCache;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = '${Constants.baseUrl}/profile?token=$token';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> profileData = json.decode(response.body);
        final profile = Profile.fromJson(profileData);
        // Update last fetch time
        _lastFetchTime = DateTime.now();
        saveProfileData(profile);
        return profile;
      } else {
        // Handle server errors
        final errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Unknown error';
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Server Error'),
              content: Text('Failed to fetch user profile: $errorMessage'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
        throw Exception('Server Error: $errorMessage');
      }
    } catch (e) {
      // Handle network errors
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Network Error'),
            content: const Text(
                'Failed to fetch user profile. Please check your network connection.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
      throw Exception('Network Error: Failed to fetch user profile');
    }
  }

  Future<String> uploadPicture(File imageFile) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url =
        '${Constants.baseUrl}/upload-picture?token=$token&file_type?profile_picture';

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url))
        ..files.add(http.MultipartFile(
            'file', imageFile.readAsBytes().asStream(), imageFile.lengthSync(),
            filename: imageFile.path.split("/").last))
        ..fields['file_type'] = 'profile_picture'; // or 'cover_photo' as needed

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseJson = json.decode(await response.stream.bytesToString());
        final profilePicUrl = responseJson['file_url'];
        return profilePicUrl;
      } else if (response.statusCode == 401) {
        throw Exception('Token is invalid or expired');
      } else {
        final Map<String, dynamic> errorResponse =
            json.decode(await response.stream.bytesToString());
        final errorMessage = errorResponse['error'];
        throw Exception(errorMessage);
      }
    } catch (e) {
      throw Exception('Failed to upload profile picture: $e');
    }
  }

  // Add functions for user preferences, badges, and other profile-related operations
}
