import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_demo_app/common/common.dart';
import 'package:x_demo_app/core/utils.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/features/user_profile/controller/user_profile_controller.dart';

import '../../../theme/theme.dart';

class EditProfileView extends ConsumerStatefulWidget {
  static route() => MaterialPageRoute(
        builder: (context) => const EditProfileView(),
      );
  const EditProfileView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _EditProfileViewState();
}

class _EditProfileViewState extends ConsumerState<EditProfileView> {
  late TextEditingController nameController;
  late TextEditingController bioController;
  XFile? newProfileImage;
  XFile? newBanner;

  Uint8List? newBannerData;
  Uint8List? newProfileImageData;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
        text: ref.read(currentUserDetailsProvider).value?.name ?? '');
    bioController = TextEditingController(
        text: ref.read(currentUserDetailsProvider).value?.bio ?? '');
  }

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
    bioController.dispose();
  }

  void selectBannerImage() async {
    final banner = await pickImage();
    setState(() {
      newBanner = banner;
    });
    if (banner != null) {
      final bytes = await banner.readAsBytes();
      setState(() {
        newBannerData = bytes;
      });
    }
  }

  void selectProfileImage() async {
    final profileImage = await pickImage();
    setState(() {
      newProfileImage = profileImage;
    });
    if (profileImage != null) {
      final bytes = await profileImage.readAsBytes();
      setState(() {
        newProfileImageData = bytes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserDetailsProvider).value;
    final isLoading = ref.watch(UserProfileControllerProvider);

    return isLoading || user == null
        ? const Loader()
        : Scaffold(
            appBar: AppBar(
              title: const Text('プロフィールを編集'),
              centerTitle: false,
              actions: [
                TextButton(
                  onPressed: () {
                    ref
                        .read(UserProfileControllerProvider.notifier)
                        .updateUserProfile(
                          userModel: user.copyWith(
                            name: nameController.text,
                            bio: bioController.text,
                          ),
                          context: context,
                          bannerFile: newBanner,
                          profileFile: newProfileImage,
                        );
                  },
                  child: const Text('変更'),
                )
              ],
            ),
            body: Column(
              children: [
                SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: selectBannerImage,
                        child: Container(
                          width: double.infinity,
                          height: 150,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15)),
                          child: newBannerData != null
                              ? Image.memory(newBannerData!,
                                  fit: BoxFit.fitWidth)
                              : user.bannerPic.isNotEmpty
                                  ? Image.network(
                                      user.bannerPic,
                                      fit: BoxFit.fitWidth,
                                    )
                                  : Container(
                                      color: Palette.blueColor,
                                    ),
                        ),
                      ),
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: InkWell(
                          onTap: selectProfileImage,
                          child: newProfileImageData != null
                              ? CircleAvatar(
                                  backgroundImage:
                                      MemoryImage(newProfileImageData!),
                                  radius: 40,
                                )
                              : user.profilePic.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.profilePic),
                                      radius: 40,
                                    )
                                  : Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(40),
                                        color: const Color(0xFF4F378B),
                                      ),
                                    ),
                        ),
                      ),
                    ],
                  ),
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: '名前',
                    contentPadding: EdgeInsets.all(18),
                  ),
                ),
                TextField(
                  controller: bioController,
                  decoration: const InputDecoration(
                    hintText: '説明欄',
                    contentPadding: EdgeInsets.all(18),
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          );
  }
}
