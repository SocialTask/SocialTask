import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';
import 'package:socialtask/utils/logger.dart';

class Task {
  int? taskId;
  String? name;
  String? description;
  String? category;
  String? explanation;
  String? feature1;
  String? feature2;
  String? feature3;
}

class TaskService {
  Future<Task> fetchTask(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = '${Constants.baseUrl}/task?token=$token';
    final task = Task();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> taskData = json.decode(response.body);
        task.taskId = taskData['TaskID'];
        task.name = taskData['Name'];
        task.description = taskData['Description'];
        task.category = taskData['Category'];
        task.explanation = taskData['Explanation'];
        task.feature1 = taskData['Feature1'];
        task.feature2 = taskData['Feature2'];
        task.feature3 = taskData['Feature3'];

        customLogger.logInfo('Fetched task data');
        return task;
      } else if (response.statusCode == 401) {
        customLogger.logInfo('Token is invalid or expired');
        throw Exception('Token is invalid or expired');
      } else {
        customLogger.logInfo(
            'Failed to fetch task with status code: ${response.statusCode}');
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['error'];
        customLogger.logInfo('Error message: $errorMessage');
        throw Exception('Failed to fetch task');
      }
    } catch (e) {
      customLogger.logError('Failed to fetch task: $e');
      throw Exception('Failed to fetch task');
    }
  }

  // Other task-related functions
}
