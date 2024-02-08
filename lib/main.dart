import 'package:flutter/material.dart';
import 'screens/welcome.dart';
import 'package:socialtask/screens/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'widgets/background.dart';

Future<bool> isUserAuthenticated() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  // Check if the token is present and valid (you may need to decode and verify it)
  return token != null && token.isNotEmpty;
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocialTask',
      home: FutureBuilder<bool>(
        future: isUserAuthenticated(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking authentication status
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            // Handle errors if any
            return Text('Error: ${snapshot.error}');
          } else if (snapshot.data == true) {
            // User is authenticated, show the home page
            return const MainPage();
          } else {
            // User is not authenticated, show the welcome page
            return const WelcomePage();
          }
        },
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter is initialized
  await SharedPreferences.getInstance(); // Initialize SharedPreferences
  runApp(
    ChangeNotifierProvider(
      create: (context) => BackgroundNotifier(),
      child: const SafeArea(
          bottom: false, left: false, right: false, top: true, child: MyApp()),
    ),
  );
}
