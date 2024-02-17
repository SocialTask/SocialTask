import 'package:flutter/material.dart';
import 'package:socialtask/widgets/background.dart';
import 'package:socialtask/screens/auth/login.dart';
import 'package:socialtask/utils/api/auth.dart';
import 'package:socialtask/utils/lang.dart';

const String logoAssetPath = 'assets/images/logo_500px.png';

final TextEditingController registerUsernameController =
    TextEditingController();
final TextEditingController registerEmailController = TextEditingController();
final TextEditingController registerPasswordController =
    TextEditingController();

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

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
            AppLocalizations.of(context).translate('signUp'),
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
                    controller: registerUsernameController,
                    labelText:
                        AppLocalizations.of(context).translate('username'),
                    prefixIcon: Icons.person),
                const SizedBox(height: 20.0),
                _buildInputField(
                    controller: registerEmailController,
                    labelText: AppLocalizations.of(context).translate('email'),
                    prefixIcon: Icons.email),
                const SizedBox(height: 20.0),
                _buildInputField(
                    controller: registerPasswordController,
                    labelText:
                        AppLocalizations.of(context).translate('password'),
                    prefixIcon: Icons.lock,
                    obscureText: true),
              ],
            ),
          ),
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: () {
              AuthService authService = AuthService();
              authService.registerUser(
                context,
                registerUsernameController
                    .text, // Obtener el nombre de usuario del controlador
                registerEmailController
                    .text, // Obtener el correo electrónico del controlador
                registerPasswordController
                    .text, // Obtener la contraseña del controlador
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF343434),
              padding:
                  const EdgeInsets.symmetric(vertical: 15.0, horizontal: 80.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
            ),
            child: Text(
              AppLocalizations.of(context).translate('signUp'),
              style: const TextStyle(
                color: Color(0xFFFFFFFF),
                letterSpacing: 1.5,
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                fontFamily: 'OpenSans',
              ),
            ),
          ),
          const SizedBox(height: 10.0),
          Text(
            AppLocalizations.of(context).translate('or'),
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
                      const LoginPage(),
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context).translate('haveAccount'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                  const WidgetSpan(
                    child: SizedBox(width: 5),
                  ),
                  TextSpan(
                    text: AppLocalizations.of(context).translate('login'),
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
      controller: controller, // Asigna el controlador aquí
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
