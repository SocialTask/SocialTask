import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:async';
import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:socialtask/screens/main/task/post.dart';
import 'package:socialtask/widgets/customloading.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  _StartScreenState createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late bool _flashEnabled = false;
  late int _timerDuration = 0;
  late Timer _timer;
  late int _timerCountdown = 0;
  late bool _isRecording = false;
  File? _imageFile; // Stores the captured image file

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = initializeCamera(CameraLensDirection.back);
  }

  Future<void> _captureAndShowImage() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const CustomLoadingDialog(); // Mostrar el diálogo personalizado
        },
      );

      await _initializeControllerFuture;
      final image = await _controller.takePicture();

      final imageFile = File(image.path);

      setState(() {
        _imageFile = imageFile; // Usar la imagen comprimida
      });

      Navigator.of(context).pop(); // Cerrar el diálogo de carga

      _showConfirmationDialog(imageFile); // Mostrar el diálogo de confirmación
    } catch (e) {
      // Manejar el error
      print('Error taking picture and posting: $e');
      // Ocultar el diálogo de carga en caso de error
      Navigator.of(context).pop();
    }
  }

  Future<void> _startRecording() async {
    try {
      await Future(() async {
        await _controller.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      });
    } catch (e) {
      print('Error starting video recording: $e');
      // Handle error as needed, maybe notify the user
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      await Future(() async {
        XFile videoFile = await _controller.stopVideoRecording();
        setState(() {
          _isRecording = false;
        });

        // Call the method to display the recorded video and send confirmation
        _showVideoConfirmation(videoFile);
      });
    } catch (e) {
      print('Error stopping video recording: $e');
      // Handle error as needed, maybe notify the user
    }
  }

  void _showVideoConfirmation(XFile videoFile) {
    final VideoPlayerController videoController = VideoPlayerController.file(
      File(videoFile.path),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Inicializa el controlador y comienza la reproducción del video
        videoController.initialize().then((_) {
          videoController.play();
        });

        return AlertDialog(
          title: const Text('Video Confirmation'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AspectRatio(
                aspectRatio: 9 / 16,
                child: VideoPlayer(videoController),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Retoma la grabación
                  Navigator.of(context).pop();
                },
                child: const Text('Retake'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Confirmar y navegar a la pantalla PostScreen
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => PostScreen(
                        videoFile: File(videoFile.path),
                      ),
                    ),
                  );
                },
                child: const Text('Confirm'),
              ),
            ],
          ),
          // Al cerrar el diálogo, detén la reproducción del video
          // (Esta parte es opcional)
          actions: <Widget>[
            TextButton(
              onPressed: () {
                videoController.pause();
                videoController.dispose();
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showConfirmationDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Image Confirmation'),
          content: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                  height: 200,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Retake the photo
                    Navigator.of(context).pop();
                  },
                  child: const Text('Retake'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Confirm and navigate to the PostScreen
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PostScreen(
                          imageFile: imageFile,
                        ), // Pass the image File
                      ),
                    );
                  },
                  child: const Text('Confirm'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel(); // Cancelar el temporizador al cerrar la pantalla
    super.dispose();
  }

  Widget buildCameraPreview() {
    if (!_controller.value.isInitialized) {
      return const Center(child: Text('Camera initialization failed.'));
    }

    return Expanded(child: CameraPreview(_controller));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              children: [
                buildCameraPreview(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.camera_front),
                      onPressed: _onSwitchCamera,
                    ),
                    IconButton(
                      icon: const Icon(Icons.timer),
                      onPressed: _setTimer,
                    ),
                    IconButton(
                      icon: Icon(
                          _flashEnabled ? Icons.flash_on : Icons.flash_off),
                      onPressed: _toggleFlash,
                    ),
                    FloatingActionButton(
                      onPressed:
                          _isRecording ? _stopRecording : _startRecording,
                      backgroundColor: _isRecording ? Colors.red : Colors.blue,
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.videocam,
                        size: 32,
                      ),
                    ),
                    FloatingActionButton(
                      onPressed: () {
                        if (_timerDuration == 0) {
                          _captureAndShowImage();
                        } else {
                          startTimer();
                        }
                      },
                      backgroundColor: Colors.blue,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.camera,
                          key: ValueKey<int>(_imageFile?.hashCode ?? 0),
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
                if (_timerCountdown > 0)
                  Text(
                    '$_timerCountdown',
                    style: const TextStyle(
                        fontSize: 48, fontWeight: FontWeight.bold),
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  void _setTimer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Timer Duration'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('No Timer'),
                onTap: () {
                  setState(() {
                    _timerDuration = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('5 Seconds'),
                onTap: () {
                  setState(() {
                    _timerDuration = 5;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('10 Seconds'),
                onTap: () {
                  setState(() {
                    _timerDuration = 10;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('15 Seconds'),
                onTap: () {
                  setState(() {
                    _timerDuration = 15;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _toggleFlash() {
    setState(() {
      _flashEnabled = !_flashEnabled;
      _controller.setFlashMode(_flashEnabled ? FlashMode.torch : FlashMode.off);
    });
  }

  void _onSwitchCamera() {
    final lensDirection = _controller.description.lensDirection;
    CameraLensDirection newLensDirection;
    if (lensDirection == CameraLensDirection.back) {
      newLensDirection = CameraLensDirection.front;
    } else {
      newLensDirection = CameraLensDirection.back;
    }
    _initializeControllerFuture = initializeCamera(newLensDirection);
  }

  Future<void> initializeCamera(CameraLensDirection lensDirection) async {
    final cameras = await availableCameras();
    final camera = cameras.firstWhere(
      (camera) => camera.lensDirection == lensDirection,
      orElse: () => cameras.first,
    );

    setState(() {
      _controller = CameraController(
        camera,
        ResolutionPreset.high,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      _initializeControllerFuture = _controller.initialize();
    });
  }

  void startTimer() {
    _timerCountdown = _timerDuration;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timerCountdown > 0) {
          _timerCountdown--;
        } else {
          _timer.cancel(); // Detener el temporizador cuando alcanza 0
          _captureAndShowImage();
        }
      });
    });
  }
}
