import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/common/common.dart';
import 'package:x_demo_app/constants/constants.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/theme/theme.dart';
import '../widgets/auth_field.dart';

class LoginView extends ConsumerStatefulWidget {
  final void Function()? onPressed;

  static route(void Function()? onPressed) => MaterialPageRoute(
        builder: (context) => LoginView(onPressed),
      );

  const LoginView(this.onPressed, {super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final appBar = UiConstants.appBar();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String errorText = "";

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
  }

  Future login() async {
    try {
      final isSuccess = await ref.read(authControllerProvider.notifier).login(
            email: emailController.text,
            password: passwordController.text,
            context: context,
          );
      if (isSuccess) {
        setState(() {
          errorText = "";
        });
        ref.refresh(currentUserAccountProvider);
      }
    } catch (e) {
      //showSnackBar(context, "ログインに失敗しました。もう一度入力してください。");
      setState(() {
        errorText = "ログインに失敗しました。もう一度入力してください。";
      });
    }
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
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: boxWidth,
                    child: Column(children: [
                      if (errorText.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4.0),
                          child: Text(
                            errorText,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
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
                          onTap: login,
                          label: 'ログイン',
                        ),
                      ),
                      const SizedBox(height: 40),
                      RichText(
                        text: TextSpan(
                          text: 'アカウントを持ってない？',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: '登録',
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
