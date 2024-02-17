import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:socialtask/utils/backend/profile.dart';
import 'package:socialtask/utils/backend/post.dart';
import 'package:socialtask/utils/backend/auth.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Profile userProfile = Profile();
  List<Post> profilePosts = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await retrieveUserProfileFromSharedPreferences();
    await fetchUserPosts();
  }

  Future<void> retrieveUserProfileFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final profileDataString = prefs.getString('profileData');
    if (profileDataString != null) {
      final profileData = json.decode(profileDataString);
      setState(() {
        userProfile = Profile.fromJson(profileData);
      });
    }
  }

  Future<void> refreshProfile() async {
    await ProfileService().fetchProfile(context);
    await retrieveUserProfileFromSharedPreferences();
  }

  Future<void> fetchUserPosts() async {
    try {
      final posts =
          await PostService().fetchUserPosts(userProfile.username ?? "");
      setState(() {
        profilePosts = posts;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _updateProfilePicture() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        final imageFile = File(pickedFile.path);

        final updatedProfilePicUrl =
            await ProfileService().uploadPicture(imageFile);

        setState(() {
          userProfile.profilePicUrl = updatedProfilePicUrl;
        });

        await saveUserProfileToSharedPreferences(userProfile);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update profile picture: $e'),
        ),
      );
    }
  }

  Future<void> saveUserProfileToSharedPreferences(Profile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileData', json.encode(profile.toJson()));
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: refreshProfile,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications), // Icono de notificaciones
              onPressed: () {
                // Aquí puedes implementar la lógica para ver los likes y nuevos seguidores
              },
            ),
          ],
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.blue,
                ),
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: const Text('Settings (Working)'),
                onTap: () {
                  // Handle settings tap
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('Edit Profile (Working)'),
                onTap: () {
                  // Handle edit profile tap
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Log Out'),
                onTap: () {
                  // Handle edit profile tap
                  AuthService().logoutUser(context);
                },
              ),
              // Add more options as needed
            ],
          ),
        ),
        body: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                InkWell(
                  onTap: _updateProfilePicture,
                  child: CircleAvatar(
                    radius: 75.0,
                    backgroundImage: userProfile.profilePicUrl != null
                        ? NetworkImage(userProfile.profilePicUrl!)
                        : const AssetImage('assets/images/logo_500px.png')
                            as ImageProvider<Object>?,
                  ),
                ),
                const SizedBox(height: 16.0),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (userProfile.verified == true)
                        const Icon(
                          Icons.verified,
                          color: Colors.green,
                          size: 24.0,
                        ),
                      const SizedBox(width: 5.0),
                      Text(
                        userProfile.username ?? "",
                        style: const TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15.0),
                Text(
                  userProfile.description ?? "",
                  style: const TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    _buildProfileInfo('Tasks', userProfile.madeTasks),
                    const SizedBox(width: 20.0),
                    _buildProfileInfo('Followers', userProfile.followersCount),
                    const SizedBox(width: 20.0),
                    _buildProfileInfo('Following', userProfile.followingCount),
                  ],
                ),
                const SizedBox(height: 20.0),
                Text(
                  'Privacy Setting: ${userProfile.privacySetting}',
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 10.0),
                _buildPostGrid(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(String label, int? value) {
    return Column(
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '${value ?? 0}',
          style: const TextStyle(
            fontSize: 18.0,
          ),
        ),
      ],
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (BuildContext context, int index) {
        final post = profilePosts[index];

        if (post.videoThumbnail != null) {
          return _buildImage(post.videoThumbnail!);
        } else if (post.imgCompressed != null) {
          return _buildImage(post.imgCompressed!);
        }

        return Container();
      },
      itemCount: profilePosts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _buildImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        _showImageDialog(context, imageUrl);
      },
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 10.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cerrar',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
