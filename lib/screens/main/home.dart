import 'package:flutter/material.dart';
import 'package:socialtask/utils/backend/post.dart';
import 'package:socialtask/utils/backend/users.dart';
import 'package:socialtask/screens/main/home/post_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> postList = [];
  int page = 1; // Initial page
  int perPage = 10; // Number of items per page
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPosts();

    // Add a scroll listener to the ScrollController
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts({bool refresh = false}) async {
    if (isLoading || !mounted) return;

    if (refresh) {
      setState(() {
        postList.clear(); // Limpiar la lista al hacer refresh
        page = 1; // Reiniciar la página al hacer refresh
      });
    } else {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final fetchedPosts = await PostService().fetchPosts(page, perPage);
      if (fetchedPosts.isEmpty) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final updatedPosts = await Future.wait(fetchedPosts.map((post) async {
        final user = await UsersService()
            .fetchUser(post.userId.toString(), fromid: true);
        post.user = user;
        return post;
      }));

      setState(() {
        postList.addAll(updatedPosts);
        isLoading = false;
        page++; // Incrementar la página para la próxima carga
      });
    } catch (e, stackTrace) {
      print("Error fetching posts: $e");
      print(stackTrace);
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _onVote(Post post, bool upvote) async {
    try {
      if (upvote) {
        await PostService().upvotePost(post.id);
      } else {
        await PostService().downvotePost(post.id);
      }
    } catch (e) {
      print("Error voting: $e");
    }
  }

  void _scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 1000 &&
        !_scrollController.position.outOfRange &&
        !isLoading) {
      // User has reached the end of the list (1000 pixels before the end of the list (when 1 post is remaining aprox)), and it's not already loading
      _loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => _loadPosts(refresh: true),
        child: ListView.builder(
          itemCount: postList.length + 1, // Add 1 for the loading indicator
          padding: const EdgeInsets.only(bottom: 0.0),
          itemBuilder: (context, index) {
            if (index < postList.length) {
              final post = postList[index];
              return PostCard(
                post: post,
                onUpvote: () => _onVote(post, true),
                onDownvote: () => _onVote(post, false),
              );
            } else if (isLoading) {
              // Display a loading indicator while fetching more data
              return const Center(
                child: LinearProgressIndicator(
                  minHeight: 10.0,
                ),
              );
            } else {
              return Container(); // End of the list
            }
          },
          controller: _scrollController,
        ),
      ),
    );
  }
}
