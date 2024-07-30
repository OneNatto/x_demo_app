import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_demo_app/apis/storage_api.dart';
import 'package:x_demo_app/apis/tweet_api.dart';
import 'package:x_demo_app/apis/user_api.dart';
import 'package:x_demo_app/features/notification/controller/notification_controller.dart';
import 'package:x_demo_app/models/user_model.dart';

import '../../../core/enums/notification_type_enum.dart';
import '../../../core/utils.dart';
import '../../../models/tweet_model.dart';
import '../../auth/controller/auth_controller.dart';
import '../../tweet/controller/tweet_controller.dart';

final UserProfileControllerProvider =
    StateNotifierProvider<UserProfileController, bool>((ref) {
  return UserProfileController(
    tweetAPI: ref.watch(tweetAPIProvider),
    userAPI: ref.watch(userAPIProvider),
    storageAPI: ref.watch(storageAPIProvider),
    notificationController: ref.watch(notificationControllerProvider.notifier),
    ref: ref,
  );
});

final getUserTweetProvider = FutureProvider.family((ref, String uid) async {
  final userProfileController =
      ref.watch(UserProfileControllerProvider.notifier);
  return userProfileController.getUserTweet(uid);
});

final getLatestUserProfileDataProvider = StreamProvider((ref) {
  final userAPI = ref.watch(userAPIProvider);
  return userAPI.getLatestUserProfileData();
});

class UserProfileController extends StateNotifier<bool> {
  final TweetAPI _tweetAPI;
  final UserAPI _userAPI;
  final StorageAPI _storageAPI;
  final NotificationController _notificationController;
  final Ref _ref;
  UserProfileController({
    required TweetAPI tweetAPI,
    required UserAPI userAPI,
    required StorageAPI storageAPI,
    required NotificationController notificationController,
    required Ref ref,
  })  : _ref = ref,
        _userAPI = userAPI,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getUserTweet(String uid) async {
    final tweets = await _tweetAPI.getUserTweet(uid);
    return tweets.map((e) => Tweet.fromMap(e.data)).toList();
  }

  void updateUserProfile({
    required UserModel userModel,
    required BuildContext context,
    required XFile? bannerFile,
    required XFile? profileFile,
  }) async {
    state = true;
    if (bannerFile != null) {
      final bannerUrl = await _storageAPI.uploadImage([bannerFile]);
      userModel = userModel.copyWith(bannerPic: bannerUrl[0]);
    }
    if (profileFile != null) {
      final profileUrl = await _storageAPI.uploadImage([profileFile]);
      userModel = userModel.copyWith(profilePic: profileUrl[0]);
    }

    final res = await _userAPI.updateUserData(userModel);
    state = false;
    res.fold(
      (l) => showSnackBar(context, l.message),
      (r) {
        _ref.refresh(userDetailsProvider(userModel.uid));
        Navigator.pop(context, true);
      },
    );
  }

  void followUser({
    required UserModel user,
    required BuildContext context,
    required UserModel currentUser,
  }) async {
    if (currentUser.following.contains(user.uid)) {
      user.followers.remove(currentUser.uid);
      currentUser.following.remove(user.uid);
    } else {
      user.followers.add(currentUser.uid);
      currentUser.following.add(user.uid);
    }

    user = user.copyWith(followers: user.followers);
    currentUser = currentUser.copyWith(following: currentUser.following);

    final res = await _userAPI.followUser(user);
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      final res2 = await _userAPI.addToFollowing(currentUser);
      res2.fold((l) => showSnackBar(context, l.message), (r) {
        _notificationController.createNotification(
          text: '${currentUser.name} があなたをフォローしました！',
          postId: '',
          notificationType: NotificationType.follow,
          uid: user.uid,
        );
      });
    });
  }
}
