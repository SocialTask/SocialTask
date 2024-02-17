import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:socialtask/screens/welcome.dart';
import 'package:socialtask/screens/main.dart';
import 'package:socialtask/utils/lang.dart'; // Importa el archivo lang.dart
import 'widgets/background.dart';

Future<bool> isUserAuthenticated() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  // Check if the token is present and valid (you may need to decode and verify it)
  return token != null && token.isNotEmpty;
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key, Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocialTask',
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('es', 'ES'), // Spanish
        // Add more locales as needed
      ],
      localizationsDelegates: const [
        AppLocalizations
            .delegate, // Agrega el delegado de localizaciones personalizado
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // Add more delegates as needed
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        // Check if the current device locale is supported
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale!.languageCode &&
              supportedLocale.countryCode == locale.countryCode) {
            return supportedLocale;
          }
        }
        // If the device locale is not supported, use the first one from the list
        return supportedLocales.first;
      },
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
  runApp(
    ChangeNotifierProvider(
      create: (context) => BackgroundNotifier(),
      child: const SafeArea(
          bottom: false, left: false, right: false, top: true, child: MyApp()),
    ),
  );
}
