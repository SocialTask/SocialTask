import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:socialtask/screens/main/task/post.dart';
import 'package:socialtask/widgets/customloading.dart';
import 'package:socialtask/utils/logger.dart';
import 'package:socialtask/utils/lang.dart';

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

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel(); // Cancelar el temporizador al cerrar la pantalla
    super.dispose();
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

  Widget buildCameraPreview() {
    if (!_controller.value.isInitialized) {
      return Center(
          child: Text(AppLocalizations.of(context)
              .translate('cameraInitializationFailed')));
    }

    return Expanded(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _controller.value.previewSize!.height,
          height: _controller.value.previewSize!.width,
          child: CameraPreview(_controller),
        ),
      ),
    );
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

  void _setTimer() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context).translate('timerDuration')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(AppLocalizations.of(context).translate('noTimer')),
                onTap: () {
                  setState(() {
                    _timerDuration = 0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                    '5 ' + AppLocalizations.of(context).translate('seconds')),
                onTap: () {
                  setState(() {
                    _timerDuration = 5;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                    '10 ' + AppLocalizations.of(context).translate('seconds')),
                onTap: () {
                  setState(() {
                    _timerDuration = 10;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                    '15 ' + AppLocalizations.of(context).translate('seconds')),
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

  void _toggleFlash() {
    setState(() {
      _flashEnabled = !_flashEnabled;
    });
  }

  Future<void> _startRecording() async {
    try {
      await Future(() async {
        await _controller
            .setFlashMode(_flashEnabled ? FlashMode.torch : FlashMode.off);
        await _controller.startVideoRecording();
        setState(() {
          _isRecording = true;
        });
      });
    } catch (e) {
      customLogger.logError('Error starting video recording: $e');
      // Handle error as needed, maybe notify the user
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording) return;

    try {
      await Future(() async {
        XFile videoFile = await _controller.stopVideoRecording();
        await _controller.setFlashMode(FlashMode.off);
        setState(() {
          _isRecording = false;
        });

        // Call the method to display the recorded video and send confirmation
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => PostScreen(
              videoFile: File(videoFile.path),
            ),
          ),
        );
      });
    } catch (e) {
      customLogger.logError('Error stopping video recording: $e');
      // Handle error as needed, maybe notify the user
    }
  }

  void _captureAndShowImage() async {
    try {
      // Restaurar el modo de flash después de tomar la foto
      _controller
          .setFlashMode(_flashEnabled ? FlashMode.always : FlashMode.off);

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

      _controller.setFlashMode(FlashMode.off);

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PostScreen(
            imageFile: imageFile,
          ), // Pasar el archivo de imagen
        ),
      );
    } catch (e) {
      // Manejar el error
      customLogger.logError('Error taking picture and posting: $e');
      // Ocultar el diálogo de carga en caso de error
      Navigator.of(context).pop();
    }
  }
}
