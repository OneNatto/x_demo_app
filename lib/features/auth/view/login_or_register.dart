import 'package:flutter/material.dart';
import 'package:x_demo_app/features/auth/view/login_view.dart';

import 'signup_view.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLogin = true;

  void onPressed() {
    setState(() {
      showLogin = !showLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLogin) {
      return LoginView(onPressed);
    } else {
      return SignUpView(onPressed);
    }
  }
}
