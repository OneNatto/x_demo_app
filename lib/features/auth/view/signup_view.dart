import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/common/common.dart';
import 'package:x_demo_app/constants/constants.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/theme/theme.dart';

import '../widgets/auth_field.dart';

class SignUpView extends ConsumerStatefulWidget {
  final void Function()? onPressed;

  static route(void Function()? onPressed) => MaterialPageRoute(
        builder: (context) => SignUpView(onPressed),
      );

  const SignUpView(this.onPressed, {super.key});

  @override
  ConsumerState<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends ConsumerState<SignUpView> {
  final appBar = UiConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  void onSignUp() {
    ref.read(authControllerProvider.notifier).signUp(
          email: emailController.text,
          password: passwordController.text,
          context: context,
        );
    emailController.clear();
    passwordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    double boxWidth;

    if (screenWidth > 1200) {
      boxWidth = screenWidth * 0.5;
    } else if (screenWidth > 600) {
      boxWidth = screenWidth * 0.7;
    } else {
      boxWidth = screenWidth;
    }

    return isLoading
        ? const LoadingPage()
        : Scaffold(
            appBar: appBar,
            body: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: boxWidth,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(children: [
                      AuthField(
                        controller: emailController,
                        hintText: 'Eメールを入力してください',
                      ),
                      const SizedBox(height: 25),
                      AuthField(
                        controller: passwordController,
                        hintText: 'パスワードを入力してください',
                        obscureText: true,
                      ),
                      const SizedBox(height: 40),
                      Align(
                        alignment: Alignment.topRight,
                        child: RoundedSmallButton(
                          onTap: onSignUp,
                          label: '登録',
                        ),
                      ),
                      const SizedBox(height: 40),
                      RichText(
                        text: TextSpan(
                          text: 'アカウントを持ってる？',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: 'ログイン',
                              style: const TextStyle(
                                color: Palette.blueColor,
                                fontSize: 16,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  widget.onPressed!();
                                },
                            ),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          );
  }
}
