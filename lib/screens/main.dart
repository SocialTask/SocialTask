import 'package:flutter/material.dart';
import 'package:socialtask/screens/main/home.dart';
import 'package:socialtask/screens/main/task.dart';
import 'package:socialtask/screens/main/leaderboard.dart';
import 'package:socialtask/screens/main/profile.dart';
import 'package:socialtask/screens/main/search.dart';
import 'package:socialtask/widgets/navbar.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _HomePage();
}

class _HomePage extends State<MainPage> {
  int _selectedIndex = 0;
  late Widget _selectedWidget;

  @override
  void initState() {
    _selectedWidget = const HomeScreen();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Set extendBody to true
      body: Container(
        margin: const EdgeInsets.only(bottom: 65), // Set top and bottom margin
        child: _selectedWidget,
      ),
      bottomNavigationBar: BottomNavigation(
        itemIcons: const [
          Icons.home,
          Icons.search,
          Icons.emoji_events,
          Icons.person,
        ],
        centerIcon: Icons.radar,
        selectedIndex: _selectedIndex,
        onItemPressed: onPressed,
      ),
    );
  }

  void onPressed(index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        _selectedWidget = const HomeScreen();
      } else if (index == 1) {
        _selectedWidget = const SearchScreen();
      } else if (index == 2) {
        _selectedWidget = const TaskScreen();
      } else if (index == 3) {
        _selectedWidget = const MessagesScreen();
      } else if (index == 4) {
        _selectedWidget = const ProfileScreen();
      }
    });
  }
}
