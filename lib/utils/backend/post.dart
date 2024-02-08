import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'constants.dart';
import 'package:intl/intl.dart';
import 'package:socialtask/utils/backend/users.dart';
import 'package:socialtask/utils/logger.dart';
import 'dart:io';

class Post {
  final int id;
  final int userId;
  final String? text;
  final String? imgRaw;
  final String? imgCompressed;
  final String? videoUrl;
  final String? videoThumbnail;
  final DateTime createdAt;
  int upvotes;
  int downvotes;
  User? user;

  Post({
    required this.id,
    required this.userId,
    this.text,
    required this.createdAt,
    this.imgRaw,
    this.imgCompressed,
    this.videoUrl,
    this.videoThumbnail,
    this.user,
    required this.upvotes,
    required this.downvotes,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      userId: json['user_id'],
      text: json['text'],
      createdAt: DateTime.parse(json['created_at']),
      imgRaw: json['media_raw'],
      imgCompressed: json['media_compressed'],
      videoUrl: json['video_url'],
      videoThumbnail: json['video_thumbnail'],
      upvotes: json['upvotes'],
      downvotes: json['downvotes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'text': text,
      'created_at': createdAt.toIso8601String(),
      'img_raw': imgRaw,
      'img_compressed': imgCompressed,
      'video_url': videoUrl,
      'video_thumbnail': videoThumbnail,
      'upvotes': upvotes,
      'downvotes': downvotes,
    };
  }
}

class PostVote {
  final int userId;
  final String voteType;

  PostVote({
    required this.userId,
    required this.voteType,
  });
}

class PostService {
  // Fetch general (non-username) posts
  Future<List<Post>> fetchPosts(int page, int perPage) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse(
        '${Constants.baseUrl}/posts?token=$token&page=$page&per_page=$perPage');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> postsData = json.decode(response.body);
      final List<Post> posts = postsData.map((postData) {
        final DateTime createdAt = DateFormat('E, dd MMM yyyy HH:mm:ss Z')
            .parse(postData['created_at'], true);
        return Post(
          id: postData['id'],
          userId: postData['user_id'],
          text: postData['text'],
          imgRaw: postData['img_raw'],
          imgCompressed: postData['img_compressed'],
          videoUrl: postData['video_url'],
          videoThumbnail: postData['video_thumbnail'],
          upvotes: postData['upvotes'],
          downvotes: postData['downvotes'],
          createdAt: createdAt,
        );
      }).toList();

      return posts;
    } else {
      customLogger
          .logError('Failed to retrieve general posts: ${response.statusCode}');
      throw Exception('Failed to retrieve posts');
    }
  }

  Future<Post> fetchPost(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('${Constants.baseUrl}/post/$postId?token=$token');

      final headers = {
        'Content-Type': 'application/json',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final Map<String, dynamic> postData = json.decode(response.body);
        final DateTime createdAt =
            DateFormat('yyyy-MM-dd HH:mm:ss').parse(postData['created_at']);

        return Post(
          id: postData['id'],
          userId: postData['user_id'],
          text: postData['text'],
          imgRaw: postData['img_raw'],
          imgCompressed: postData['img_compressed'],
          videoUrl: postData['video_url'],
          videoThumbnail: postData['video_thumbnail'],
          upvotes: postData['upvotes'],
          downvotes: postData['downvotes'],
          createdAt: createdAt,
        );
      } else {
        customLogger
            .logError('Failed to retrieve post: ${response.statusCode}');
        throw Exception('Failed to retrieve post');
      }
    } catch (e) {
      customLogger.logError('Error fetching post: $e');
      throw Exception('Failed to fetch post');
    }
  }

  // Fetch user-specific posts
  Future<List<Post>> fetchUserPosts(String username) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url =
        Uri.parse('${Constants.baseUrl}/user/$username/posts?token=$token');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> postsData = json.decode(response.body);
      final List<Post> posts = postsData.map((postData) {
        final DateTime createdAt = DateFormat('E, dd MMM yyyy HH:mm:ss Z')
            .parse(postData['created_at'], true);
        return Post(
          id: postData['id'],
          userId: postData['user_id'],
          text: postData['text'],
          imgRaw: postData['img_raw'],
          imgCompressed: postData['img_compressed'],
          videoUrl: postData['video_url'],
          videoThumbnail: postData['video_thumbnail'],
          upvotes: postData['upvotes'],
          downvotes: postData['downvotes'],
          createdAt: createdAt,
        );
      }).toList();

      return posts;
    } else {
      customLogger.logError(
          'Failed to retrieve user-specific posts: ${response.statusCode}');
      return [];
    }
  }

  Future<void> createPost(
      String content, File? imageFile, File? videoFile) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('${Constants.baseUrl}/post?token=$token');

      final request = http.MultipartRequest('POST', url);
      request.fields['text'] = content;

      if (imageFile != null) {
        final imageStream = http.ByteStream(imageFile.openRead());
        final imageLength = await imageFile.length();

        final imageUpload = http.MultipartFile(
          'media',
          imageStream,
          imageLength,
          filename: 'image.png', // Set your desired filename and extension
        );

        request.files.add(imageUpload);
      }

      if (videoFile != null) {
        final videoStream = http.ByteStream(videoFile.openRead());
        final videoLength = await videoFile.length();

        final videoUpload = http.MultipartFile(
          'media',
          videoStream,
          videoLength,
          filename: 'video.mp4', // Set your desired filename and extension
        );

        request.files.add(videoUpload);
      }

      final response = await request.send();

      if (response.statusCode == 200) {
        customLogger.logInfo('Post created successfully');
        // Handle successful post creation
      } else {
        customLogger.logError('Failed to create post: ${response.statusCode}');
        // Handle post creation failure
      }
    } catch (e) {
      customLogger.logError('Error creating post: $e');
      // Handle error
    }
  }

  // Upvote a post
  Future<void> upvotePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url =
        Uri.parse('${Constants.baseUrl}/post/$postId/upvote?token=$token');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      customLogger.logInfo('Upvoted post successfully');
      // Handle successful upvote
    } else {
      customLogger.logError('Failed to upvote post: ${response.statusCode}');
      // Handle upvote failure
    }
  }

  Future<void> downvotePost(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url =
        Uri.parse('${Constants.baseUrl}/post/$postId/downvote?token=$token');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.post(url, headers: headers);

    if (response.statusCode == 200) {
      customLogger.logInfo('Downvoted post successfully');
      // Handle successful downvote
    } else {
      customLogger.logError('Failed to downvote post: ${response.statusCode}');
      // Handle downvote failure
    }
  }

  Future<List<PostVote>> fetchPostVotes(int postId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url =
        Uri.parse('${Constants.baseUrl}/post/$postId/votes?token=$token');

    final headers = {
      'Content-Type': 'application/json',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> votesData = json.decode(response.body);
      final List<PostVote> votes = votesData.map((voteData) {
        return PostVote(
          userId: voteData['user_id'],
          voteType: voteData['vote_type'],
        );
      }).toList();

      return votes;
    } else {
      customLogger
          .logError('Failed to retrieve post votes: ${response.statusCode}');
      return [];
    }
  }

  Future<void> deletePost(int postId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final url = Uri.parse('${Constants.baseUrl}/post/$postId?token=$token');

      final headers = {
        'Content-Type': 'application/json',
      };

      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        customLogger.logInfo('Post deleted successfully');
        // Handle successful post deletion
      } else {
        customLogger.logError('Failed to delete post: ${response.statusCode}');
        // Handle post deletion failure
      }
    } catch (e) {
      customLogger.logError('Error deleting post: $e');
      // Handle error
    }
  }
}
