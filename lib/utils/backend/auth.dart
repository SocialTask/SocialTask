import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:socialtask/screens/auth/login.dart';
import 'package:socialtask/utils/logger.dart';
import 'package:socialtask/screens/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socialtask/utils/backend/profile.dart';

import 'constants.dart';

class AuthService {
  Future<bool> loginUser(
      BuildContext context, String email, String password) async {
    const url = '${Constants.baseUrl}/login';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        customLogger.logInfo('Login successful');
        customLogger.logInfo("$token");
        ProfileService().fetchProfile(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
        return true;
      } else if (response.statusCode == 401) {
        customLogger.logInfo('Incorrect email or password. Please try again.');
        return false;
      } else {
        customLogger
            .logInfo('Login failed with status code: ${response.statusCode}');
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        final errorMessage = errorResponse['error'];
        customLogger.logInfo('Error message: $errorMessage');
        return false;
      }
    } catch (e) {
      customLogger.logError('Login failed: $e');
      return false;
    }
  }

  Future<void> registerUser(BuildContext context, String username, String email,
      String password) async {
    const url = '${Constants.baseUrl}/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final token = json.decode(response.body)['token'];
        final prefs = await SharedPreferences.getInstance();
        prefs.setString('token', token);
        customLogger.logInfo('User registered successfully');
        customLogger.logInfo("$token");
        ProfileService().fetchProfile(context);
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const MainPage(),
          ),
        );
      } else {
        if (response.statusCode == 409) {
          customLogger.logInfo(
              'Email is already registered. Please use a different email.');
        } else {
          customLogger.logInfo(
              'Registration failed with status code: ${response.statusCode}');
          final Map<String, dynamic> errorResponse = json.decode(response.body);
          final errorMessage = errorResponse['error'];
          customLogger.logInfo('Error message: $errorMessage');
        }
      }
    } catch (e) {
      customLogger.logError('Registration failed: $e');
    }
  }

  Future<void> logoutUser(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token'); // Elimina el token almacenado
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              const LoginPage(), // Reemplaza LoginPage con tu pantalla de inicio de sesión
        ),
      );
    } catch (e) {
      customLogger.logError('Error al cerrar sesión: $e');
    }
  }
}
