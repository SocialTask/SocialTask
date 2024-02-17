import 'package:flutter/material.dart';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:socialtask/utils/api/post.dart';
import 'package:socialtask/utils/logger.dart';
import 'package:socialtask/utils/lang.dart';

class PostScreen extends StatefulWidget {
  final File? imageFile;
  final File? videoFile;

  const PostScreen({super.key, this.imageFile, this.videoFile});

  @override
  _PostScreenState createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  final TextEditingController _textEditingController = TextEditingController();
  bool _isPublishing = false;
  late VideoPlayerController _videoPlayerController;

  Future<void> _postMedia() async {
    final content = _textEditingController.text;

    if (content.isNotEmpty) {
      try {
        setState(() {
          _isPublishing = true;
        });

        final postService = PostService();
        customLogger.logInfo('Posting Content: $content');

        if (widget.imageFile != null) {
          await postService.createPost(content, widget.imageFile, null);
        } else if (widget.videoFile != null) {
          await postService.createPost(content, null, widget.videoFile);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(AppLocalizations.of(context).translate('postCreated')),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pop();
      } catch (e) {
        customLogger.logError('Error creating post: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                AppLocalizations.of(context).translate('errorCreatingPost') +
                    '$e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isPublishing = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(AppLocalizations.of(context).translate('pleaseAddContent')),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.videoFile != null) {
      _videoPlayerController = VideoPlayerController.file(widget.videoFile!)
        ..initialize().then((_) {
          // Se asegura de que el primer fotograma se muestre después de que el video se inicialice
          setState(() {});

          // Establece el bucle para que el video se reproduzca continuamente
          _videoPlayerController.setLooping(true);

          // Inicia la reproducción del video cuando esté inicializado
          _videoPlayerController.play();
        });

      // Agrega un listener para detectar cambios en el estado de reproducción
      _videoPlayerController.addListener(() {
        if (_videoPlayerController.value.isInitialized &&
            !_videoPlayerController.value.isPlaying) {
          // Inicia la reproducción si el video está listo pero no está reproduciéndose
          _videoPlayerController.play();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              flex: 1,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: widget.imageFile != null
                    ? Image.file(
                        widget.imageFile!,
                        fit: BoxFit.cover,
                        height: double.infinity,
                      )
                    : widget.videoFile != null
                        ? AspectRatio(
                            aspectRatio:
                                9 / 16, // Adjust aspect ratio as per your video
                            child: _videoPlayerController.value.isInitialized
                                ? VideoPlayer(_videoPlayerController)
                                : Container(),
                          )
                        : Container(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textEditingController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).translate('writePost'),
                labelText:
                    AppLocalizations.of(context).translate('postContent'),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isPublishing ? null : _postMedia,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: _isPublishing
                  ? const CircularProgressIndicator()
                  : Text(
                      AppLocalizations.of(context).translate('publish'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    if (widget.videoFile != null) {
      _videoPlayerController.dispose();
    }
    super.dispose();
  }
}
