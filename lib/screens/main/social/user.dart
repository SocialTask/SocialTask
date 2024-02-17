import 'package:flutter/material.dart';
import 'package:socialtask/utils/api/users.dart';
import 'package:socialtask/utils/api/follow.dart';
import 'package:socialtask/utils/api/post.dart';

// ignore: must_be_immutable
class ProfileView extends StatefulWidget {
  User user;
  final int loggedInUserId;

  ProfileView({super.key, required this.user, required this.loggedInUserId});

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  FollowService followService = FollowService();
  UsersService usersService = UsersService();
  PostService postService = PostService();
  bool isFollowing = false;
  List<Post> userPosts = [];

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchFollowStatus();
    fetchUserPosts();
  }

  Future<void> fetchUserData() async {
    try {
      User fetchedUser =
          await usersService.fetchUser(widget.user.username ?? "");
      setState(() {
        widget.user = fetchedUser;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchFollowStatus() async {
    try {
      bool status = await followService.fetchFollowStatus(widget.user.id ?? 0);
      setState(() {
        isFollowing = status;
      });
    } catch (e) {
      // Handle error
    }
  }

  Future<void> fetchUserPosts() async {
    try {
      List<Post> posts =
          await postService.fetchUserPosts(widget.user.username ?? "");
      setState(() {
        userPosts = posts;
      });
    } catch (e) {
      // Handle error
    }
  }

  toggleFollow() async {
    try {
      if (isFollowing) {
        await followService.unfollowUser(widget.user.id ?? 0);
      } else {
        await followService.followUser(widget.user.id ?? 0);
      }
      setState(() {
        isFollowing = !isFollowing;
      });
    } catch (e) {
      // Handle error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 20.0),
              CircleAvatar(
                radius: 75.0,
                backgroundImage: widget.user.profilePicUrl != null
                    ? NetworkImage(widget.user.profilePicUrl!)
                    : const AssetImage('assets/images/logo_500px.png')
                        as ImageProvider<Object>?,
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.user.verified == 1)
                      const Icon(
                        Icons.verified,
                        color: Colors.green,
                        size: 24.0,
                      ),
                    const SizedBox(width: 5.0),
                    Text(
                      widget.user.username ?? "",
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
                widget.user.description ?? "",
                style: const TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      const Text(
                        'Tasks',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.user.madeTasks}',
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20.0),
                  Column(
                    children: <Widget>[
                      const Text(
                        'Followers',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.user.followersCount}',
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 20.0),
                  Column(
                    children: <Widget>[
                      const Text(
                        'Following',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${widget.user.followingCount}',
                        style: const TextStyle(
                          fontSize: 18.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20.0),
              if (widget.user.id != widget.loggedInUserId)
                ElevatedButton(
                  onPressed: () async {
                    await toggleFollow();
                    await fetchUserData();
                  },
                  child: Text(
                    isFollowing ? 'Unfollow' : 'Follow',
                    style: const TextStyle(
                      fontSize: 18.0,
                    ),
                  ),
                ),
              const SizedBox(height: 10.0),
              _buildPostGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
      ),
      itemBuilder: (BuildContext context, int index) {
        final post = userPosts[index];

        if (post.imgCompressed != null) {
          return _buildImage(post.imgCompressed!);
        }

        return Container();
      },
      itemCount: userPosts.length,
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Image.network(
                imageUrl,
                fit: BoxFit
                    .contain, // Puedes ajustar el ajuste según tus necesidades
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      },
    );
  }
}
