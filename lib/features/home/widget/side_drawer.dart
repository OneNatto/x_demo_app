import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/common/common.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:x_demo_app/features/user_profile/view/user_profile_view.dart';
import 'package:x_demo_app/main.dart';
import 'package:x_demo_app/theme/theme.dart';

class SideDrawer extends ConsumerWidget {
  const SideDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    if (currentUser == null) {
      return const Loader();
    }
    return SafeArea(
      child: Drawer(
        backgroundColor: Palette.backgroundColor,
        child: Column(
          children: [
            const SizedBox(height: 50),
            ListTile(
              leading: const Icon(
                Icons.person,
                size: 30,
              ),
              title: const Text(
                'プロフィール',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: () =>
                  Navigator.push(context, UserProfileView.route(currentUser)),
            ),
            ListTile(
              leading: const Icon(
                Icons.payment,
                size: 30,
              ),
              title: const Text(
                'Twitter Blue',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              onTap: () {
                ref
                    .read(UserProfileControllerProvider.notifier)
                    .updateUserProfile(
                      userModel: currentUser.copyWith(isTwitterBlue: true),
                      context: context,
                      bannerFile: null,
                      profileFile: null,
                    );
              },
            ),
            ListTile(
                leading: const Icon(
                  Icons.logout,
                  size: 30,
                ),
                title: const Text(
                  'ログアウト',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                onTap: () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .logout(context);
                  ref.refresh(currentUserAccountProvider);

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyApp(),
                      ),
                      (route) => false);
                }),
          ],
        ),
      ),
    );
  }
}
