import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'package:socialtask/utils/backend/task.dart';
import 'package:provider/provider.dart';
import 'package:socialtask/widgets/background.dart';
import 'package:socialtask/widgets/animatedbutton.dart';
import 'package:socialtask/screens/main/task/start.dart';
import 'package:socialtask/utils/logger.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  int secondsRemaining = 0;
  Timer? timer;
  Task? task;

  @override
  void initState() {
    super.initState();
    secondsRemaining = 300;
    fetchTask();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        // Handle task completion here
        timer.cancel();
      }
    });
  }

  Future<void> fetchTask() async {
    try {
      final fetchedTask = await TaskService().fetchTask(context);
      setState(() {
        task = fetchedTask;
      });
    } catch (e) {
      customLogger.logError('Error fetching task: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BackgroundNotifier>(
      create: (_) => BackgroundNotifier(),
      child: Scaffold(
        body: BackgroundWidget(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 40),
                  Image.asset(
                    'assets/images/logo_500px.png',
                    width: 100,
                    height: 100,
                  ),
                  const SizedBox(height: 20),
                  AnimatedTextKit(
                    totalRepeatCount: 1,
                    animatedTexts: [
                      ColorizeAnimatedText(
                        'Daily Task',
                        textStyle: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        colors: [
                          const Color.fromARGB(255, 255, 204, 0),
                          const Color(0xFFFFCC00),
                          const Color.fromARGB(245, 11, 243, 228),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (task != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            task!.description ?? 'No description available',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const SizedBox(height: 20),
                          const Text(
                            '-- Instructions --',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment
                                .start, // Align features to the start
                            children: <Widget>[
                              Text(
                                '· ${task!.feature1 ?? 'Not available'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '· ${task!.feature2 ?? 'Not available'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                '· ${task!.feature3 ?? 'Not available'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  AnimatedButton(
                    onPressed: () {
                      // Navigate to the StartScreen when the button is pressed
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StartScreen(),
                        ),
                      );
                    },
                    context: context, // Provide the current build context
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
