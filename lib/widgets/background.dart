import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

class BackgroundNotifier extends ChangeNotifier {
  static const int totalImages = 30;
  int currentImageIndex = Random().nextInt(totalImages - 1);
  late Timer timer;

  static const Duration imageChangeDuration = Duration(seconds: 7);

  BackgroundNotifier() {
    loadBackgroundData();
  }

  void loadBackgroundData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    int remainingSeconds =
        prefs.getInt('remainingSeconds') ?? imageChangeDuration.inSeconds;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds == 0) {
        int newIndex;
        do {
          newIndex = Random().nextInt(totalImages - 1);
        } while (newIndex == currentImageIndex);
        currentImageIndex = newIndex;
        remainingSeconds = imageChangeDuration.inSeconds;
        prefs.setInt('currentImageIndex', currentImageIndex);
      } else {
        remainingSeconds--;
      }

      prefs.setInt('remainingSeconds', remainingSeconds);
      notifyListeners(); // Notify listeners when the image changes
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }
}

class BackgroundWidget extends StatelessWidget {
  final Widget? child; // Make child parameter optional by adding '?'

  const BackgroundWidget({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    final backgroundNotifier = Provider.of<BackgroundNotifier>(context);

    return AnimatedSwitcher(
      duration: const Duration(seconds: 1),
      child: Container(
        key: ValueKey<int>(backgroundNotifier.currentImageIndex),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(
                'assets/images/backgrounds/background${backgroundNotifier.currentImageIndex}.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child:
            child, // Use the provided child widget (null is handled gracefully)
      ),
    );
  }
}
