import 'package:flutter/material.dart';
import 'package:socialtask/screens/auth/login.dart';
import 'package:socialtask/widgets/background.dart';
import 'package:socialtask/utils/lang.dart';

const String logoAssetPath = 'assets/images/logo_500px.png';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background with image and gradient
          const AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: BackgroundWidget(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, // Transparent at the top
                  Colors.black.withOpacity(0.7), // Dark gradient below
                ],
              ),
            ),
          ),

          // Central content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                // Logo
                Image.asset(
                  logoAssetPath,
                  width: 180,
                ),
                const SizedBox(height: 5.0),
                ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [
                        const Color(0xFFFFCC00).withOpacity(1),
                        const Color(0xFF00E1CF).withOpacity(1),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds);
                  },
                  child: Text(
                    AppLocalizations.of(context).translate('joinDailyTask'),
                    style: const TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors
                          .white, // Set the text color to match the shader mask
                    ),
                  ),
                ),

                const SizedBox(height: 10.0),
                Text(
                  AppLocalizations.of(context)
                      .translate('colaborateOnSocialTask'),
                  style: const TextStyle(fontSize: 18.0, color: Colors.white),
                ),
                const SizedBox(height: 100),
                CustomButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation1, animation2) =>
                            const LoginPage(),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CustomButton extends StatelessWidget {
  final VoidCallback onPressed;

  const CustomButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50.0,
      width: 200,
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color.fromARGB(255, 178, 237, 255).withOpacity(1),
                const Color.fromARGB(255, 129, 238, 255).withOpacity(1),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(5.0),
          ),
          alignment: Alignment.center,
          child: Text(
            AppLocalizations.of(context).translate('joinSocialTask'),
            style: const TextStyle(
              color: Color.fromARGB(194, 0, 0, 0),
              fontWeight: FontWeight.bold,
              fontSize: 18.0,
            ),
          ),
        ),
      ),
    );
  }
}
