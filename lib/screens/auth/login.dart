import 'package:flutter/material.dart';
import 'package:socialtask/widgets/background.dart';
import 'register.dart';
import 'package:socialtask/utils/api/auth.dart';

const String logoAssetPath = 'assets/images/logo_500px.png';

final TextEditingController loginEmailController = TextEditingController();
final TextEditingController loginPasswordController = TextEditingController();

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  Text incorrectPasswordMessage = const Text(
    'Incorrect email or password. Please try again.',
    style: TextStyle(
      color: Colors.red,
      fontSize: 16.0,
    ),
  );

  bool showIncorrectPasswordMessage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const AnimatedSwitcher(
            duration: Duration(seconds: 1),
            child: BackgroundWidget(),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
              ),
            ),
          ),
          _buildContent(context),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            'LOGIN',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 20.0),
          SizedBox(
            width: 350.0, // Ancho definido
            child: Column(
              children: [
                _buildInputField(
                    controller: loginEmailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email),
                const SizedBox(height: 20.0),
                _buildInputField(
                    controller: loginPasswordController,
                    labelText: 'Password',
                    prefixIcon: Icons.lock,
                    obscureText: true),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  AuthService authService = AuthService();
                  authService
                      .loginUser(
                    context,
                    loginEmailController
                        .text, // Obtener el correo electrónico del controlador
                    loginPasswordController
                        .text, // Obtener la contraseña del controlador
                  )
                      .then((loginSuccessful) {
                    if (!loginSuccessful) {
                      setState(() {
                        showIncorrectPasswordMessage = true;
                      });
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF343434),
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 80.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text(
                  'LOGIN',
                  style: TextStyle(
                    color: Color(0xFFFFFFFF),
                    letterSpacing: 1.5,
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'OpenSans',
                  ),
                ),
              ),
              if (showIncorrectPasswordMessage) incorrectPasswordMessage,
            ],
          ),
          const SizedBox(height: 10.0),
          Text(
            '- OR -',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white,
                ),
          ),
          const SizedBox(height: 20.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _buildSocialButton(() {
                // Handle Google login
              }, const AssetImage('assets/images/logos/google.png')),
            ],
          ),
          const SizedBox(height: 30.0),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const RegisterPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Don\'t have an Account? ',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                  TextSpan(
                    text: 'Sign Up',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.emailAddress,
      obscureText: obscureText,
      style: const TextStyle(
        color: Colors.white,
        fontFamily: 'OpenSans',
      ),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(
          color: Colors.white,
        ),
        prefixIcon: Icon(
          prefixIcon,
          color: Colors.white,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton(void Function()? onTap, AssetImage logo) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.0,
        width: 40.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              offset: Offset(0, 2),
              blurRadius: 6.0,
            ),
          ],
          image: DecorationImage(
            image: logo,
          ),
        ),
      ),
    );
  }
}
