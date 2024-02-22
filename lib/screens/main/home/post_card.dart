import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:socialtask/utils/api/post.dart';
import 'package:socialtask/utils/api/profile.dart';
import 'package:socialtask/screens/main/social/user.dart';
import 'package:socialtask/utils/lang.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const PostCard({
    super.key,
    required this.post,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  _PostCardState createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  ChewieController? _chewieController;
  bool _isImageExpanded = false;
  int? _userId;
  Profile? userProfile;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.post.videoUrl;
    final videoThumbnail = widget.post.videoThumbnail;
    if (videoUrl != null) {
      _initializeVideoController(videoUrl, videoThumbnail!);
    }
    _initializeUserId();

    // Perform any async initialization tasks here.
    ProfileService profileService = ProfileService();
    profileService.getProfileData().then((data) {
      setState(() {
        userProfile = data;
      });
    });
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initializeUserId() async {
    final userId = await getUserIdFromSharedPreferences();
    if (mounted) {
      setState(() {
        _userId = userId;
      });
    }
  }

  Future<int?> getUserIdFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final profileDataString = prefs.getString('profileData');
    if (profileDataString != null) {
      final profileData = json.decode(profileDataString);
      final profile = Profile.fromJson(profileData);
      return profile.userId;
    }
    return null;
  }

  void _initializeVideoController(String videoUrl, String thumbnailUrl) {
    final videoUri = Uri.parse(videoUrl);
    final thumbnail =
        Image.network(thumbnailUrl); // Load thumbnail from network

    _chewieController = ChewieController(
      videoPlayerController: VideoPlayerController.networkUrl(videoUri),
      aspectRatio: 9 / 16,
      autoPlay: false,
      looping: false,
      showControls: true,
      allowMuting: true,
      allowFullScreen: true,
      fullScreenByDefault: false,
      placeholder: thumbnail, // Set thumbnail as placeholder
    );
  }

  Widget _buildMediaWidget() {
    return _chewieController != null
        ? _buildChewieWidget()
        : _buildImageWidget(widget.post.imgRaw, widget.post.imgCompressed);
  }

  Widget _buildChewieWidget() {
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width / 9 * 16,
        child: AspectRatio(
          aspectRatio:
              _chewieController!.videoPlayerController.value.aspectRatio,
          child: VisibilityDetector(
            key: const Key('chewie_key'),
            onVisibilityChanged: (visibilityInfo) {
              if (visibilityInfo.visibleFraction == 0) {
                _chewieController!.pause();
              }
            },
            child: Chewie(controller: _chewieController!),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget(String? imgRaw, String? imgCompressed) {
    final imageUrl = _isImageExpanded ? imgRaw : imgCompressed;

    return SizedBox(
      height: _isImageExpanded ? null : 300.0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _isImageExpanded = !_isImageExpanded;
          });
        },
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: _isImageExpanded ? BoxFit.contain : BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  }
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(AppLocalizations.of(context).translate('error')),
                          const SizedBox(height: 5.0),
                          const Icon(Icons.error),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Container(),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp, Duration timezoneOffset) {
    final adjustedTimestamp = timestamp.subtract(timezoneOffset);
    return timeago.format(adjustedTimestamp, locale: 'en');
  }

  IconButton _buildVoteButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
    );
  }

  Future<void> _deletePost(int postId) async {
    try {
      final postService = PostService();
      await postService.deletePost(postId);
      // Puedes realizar cualquier acción adicional después de eliminar el post
    } catch (e) {
      // Maneja cualquier error que pueda ocurrir durante la eliminación del post
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedTimestamp =
        _formatTimestamp(widget.post.createdAt, const Duration(hours: 0));
    final username = widget.post.user?.username ?? 'Unknown';
    final verifiedIcon = widget.post.user?.verified == 1
        ? const Icon(Icons.verified, color: Colors.green, size: 16.0)
        : const SizedBox.shrink();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfileView(
                    user: widget.post.user!,
                    loggedInUserId: _userId!,
                  ),
                ),
              );
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: widget.post.user?.profilePicUrl != null
                    ? NetworkImage(widget.post.user!.profilePicUrl!)
                    : const AssetImage('assets/images/logo_500px.png')
                        as ImageProvider<Object>?,
                radius: 24,
              ),
              title: Row(
                children: [
                  Text(
                    username,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 3.0),
                  verifiedIcon,
                ],
              ),
              subtitle: Text(
                formattedTimestamp,
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),
              trailing: userProfile?.userId == widget.post.userId
                  ? PopupMenuButton(
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(AppLocalizations.of(context)
                              .translate('deletePost')),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'delete') {
                          _deletePost(widget.post.id);
                        }
                      },
                    )
                  : null,
            ),
          ),
          _buildMediaWidget(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildVoteButton(Icons.arrow_upward_rounded, widget.onUpvote),
              Text('${widget.post.upvotes}'),
              const SizedBox(width: 16.0),
              _buildVoteButton(Icons.arrow_downward_rounded, widget.onDownvote),
              Text('${widget.post.downvotes}'),
            ],
          ),
          if (widget.post.text != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(widget.post.text!),
            ),
        ],
      ),
    );
  }
}
