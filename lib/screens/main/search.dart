import 'package:flutter/material.dart';
import 'dart:async';
import 'package:socialtask/screens/main/social/user.dart';
import 'package:socialtask/utils/api/search.dart';
import 'package:socialtask/utils/api/users.dart';
import 'package:socialtask/utils/api/profile.dart';
import 'package:socialtask/utils/logger.dart';
import 'package:socialtask/utils/lang.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchController;
  List<User> _searchResults = [];
  Timer? _searchTimer;
  Profile? userProfile;
  bool _isMounted = false; // Flag to track widget's state

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController()
      ..addListener(_onSearchTextChanged);

    // Set the mounted flag to true when the widget is mounted
    _isMounted = true;

    // Perform any async initialization tasks here.
    ProfileService profileService = ProfileService();
    profileService.fetchProfile(context).then((data) {
      if (_isMounted) {
        setState(() {
          userProfile = data;
        });
      }
    });

    Future.microtask(() async {
      if (_isMounted) {
        await _performSearchDelayed();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchTimer?.cancel();
    // Set the mounted flag to false when the widget is disposed
    _isMounted = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                border: Border.all(
                  color: Colors.grey,
                  width: 1.0,
                ),
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context).translate('search'),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) =>
                  _buildUserCard(_searchResults[index]),
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchTextChanged() {
    if (_searchTimer != null && _searchTimer!.isActive) {
      _searchTimer!.cancel();
    }
    _searchTimer =
        Timer(const Duration(milliseconds: 500), _performSearchDelayed);
  }

  Future<void> _performSearchDelayed() async {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      try {
        final users = await SearchService().searchUsers(query);
        if (_isMounted) {
          setState(() {
            _searchResults = users;
          });
        }
      } catch (e) {
        customLogger.logError('Error searching users: $e');
      }
    }
  }

  Widget _buildUserCard(User user) => Card(
        color: Colors.transparent,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundImage: user.profilePicUrl != null
                ? NetworkImage(user.profilePicUrl!)
                : const AssetImage('assets/images/logo_500px.png')
                    as ImageProvider,
          ),
          title: Row(
            children: [
              Text(user.username ?? ""),
              const SizedBox(width: 5.0),
              if (user.verified == 1)
                const Icon(Icons.verified, color: Colors.green),
            ],
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProfileView(
                user: user,
                loggedInUserId: userProfile?.userId ?? 0,
              ),
            ),
          ),
        ),
      );
}
