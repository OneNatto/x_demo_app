import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_demo_app/apis/storage_api.dart';
import 'package:x_demo_app/apis/tweet_api.dart';
import 'package:x_demo_app/core/core.dart';
import 'package:x_demo_app/core/enums/notification_type_enum.dart';
import 'package:x_demo_app/core/utils.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/features/notification/controller/notification_controller.dart';
import 'package:x_demo_app/models/user_model.dart';

import '../../../models/tweet_model.dart';

final tweetControllerProvider = StateNotifierProvider<TweetController, bool>(
  (ref) {
    return TweetController(
      ref: ref,
      tweetAPI: ref.watch(tweetAPIProvider),
      storageAPI: ref.watch(storageAPIProvider),
      notificationController:
          ref.watch(notificationControllerProvider.notifier),
    );
  },
);

final getTweetsProvider = FutureProvider((ref) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweets();
});

final getTweetByIdProvider = FutureProvider.family((ref, String id) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getTweetById(id);
});

final getReplysToTweetProvider =
    FutureProvider.family((ref, Tweet tweet) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController.getReplysToTweet(tweet);
});

final getLatestTweetProvider = StreamProvider((ref) {
  final tweetAPI = ref.watch(tweetAPIProvider);
  return tweetAPI.getLatestTweet();
});

final getTweetByHashtagProvider =
    FutureProvider.family((ref, String hashtagText) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController._getTweetByHashtag(hashtagText);
});

final getUserResharedTweetProvider =
    FutureProvider.family((ref, String uid) async {
  final tweetController = ref.watch(tweetControllerProvider.notifier);
  return tweetController._getUserResharedTweet(uid);
});

class TweetController extends StateNotifier<bool> {
  final StorageAPI _storageAPI;
  final TweetAPI _tweetAPI;
  final NotificationController _notificationController;
  final Ref _ref;
  TweetController({
    required Ref ref,
    required TweetAPI tweetAPI,
    required StorageAPI storageAPI,
    required NotificationController notificationController,
  })  : _ref = ref,
        _tweetAPI = tweetAPI,
        _storageAPI = storageAPI,
        _notificationController = notificationController,
        super(false);

  Future<List<Tweet>> getTweets() async {
    final tweetList = await _tweetAPI.getTweets();
    return tweetList.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  Future<List<Tweet>> getReplysToTweet(Tweet tweet) async {
    final documents = await _tweetAPI.getReplysToTweet(tweet);
    return documents.map((tweet) => Tweet.fromMap(tweet.data)).toList();
  }

  Future<List<Tweet>> _getTweetByHashtag(String hashtagText) async {
    final documents = await _tweetAPI.getTweetsByHashtag(hashtagText);
    return documents.map((e) => Tweet.fromMap(e.data)).toList();
  }

  Future<Tweet> getTweetById(String id) async {
    final tweet = await _tweetAPI.getTweetById(id);
    return Tweet.fromMap(tweet.data);
  }

  Future<List<Tweet>> _getUserResharedTweet(String uid) async {
    final documents = await _tweetAPI.getUserResharedTweet(uid);
    return documents.map((e) => Tweet.fromMap(e.data)).toList();
  }

  void shareTweet({
    required List<XFile> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) {
    if (text.isEmpty) {
      showSnackBar(context, 'ツイートを入力してください');
      return;
    }

    if (images.isNotEmpty) {
      _shareImageTweet(
        images: images,
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    } else {
      _shareTextTweet(
        text: text,
        context: context,
        repliedTo: repliedTo,
        repliedToUserId: repliedToUserId,
      );
    }
  }

  void _shareImageTweet({
    required List<XFile> images,
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromTweet(text);
    String link = _getLinkFromTweet(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    final imageLinks = await _storageAPI.uploadImage(images);
    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: imageLinks,
      uid: user.uid,
      tweetType: TweetType.image,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      reshareBy: '',
      repliedTo: repliedTo,
      resharedUid: '',
    );
    final res = await _tweetAPI.shareTweet(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
          text: '${user.name}がリプライしました！',
          postId: r.$id,
          notificationType: NotificationType.reply,
          uid: repliedToUserId,
        );
      }
      state = false;
    });
  }

  void _shareTextTweet({
    required String text,
    required BuildContext context,
    required String repliedTo,
    required String repliedToUserId,
  }) async {
    state = true;
    final hashtags = _getHashtagsFromTweet(text);
    String link = _getLinkFromTweet(text);
    final user = _ref.read(currentUserDetailsProvider).value!;
    Tweet tweet = Tweet(
      text: text,
      hashtags: hashtags,
      link: link,
      imageLinks: const [],
      uid: user.uid,
      tweetType: TweetType.text,
      tweetedAt: DateTime.now(),
      likes: const [],
      commentIds: const [],
      id: '',
      reshareCount: 0,
      reshareBy: '',
      repliedTo: repliedTo,
      resharedUid: '',
    );
    final res = await _tweetAPI.shareTweet(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) {
      if (repliedToUserId.isNotEmpty) {
        _notificationController.createNotification(
          text: '${user.name}がリプライしました！',
          postId: r.$id,
          notificationType: NotificationType.reply,
          uid: repliedToUserId,
        );
      }
      state = false;
    });
  }

  void likeTweet(Tweet tweet, UserModel user) async {
    List<String> likes = tweet.likes;

    if (tweet.likes.contains(user.uid)) {
      likes.remove(user.uid);
    } else {
      likes.add(user.uid);
    }

    tweet = tweet.copyWith(likes: likes);
    final res = await _tweetAPI.likeTweet(tweet);
    res.fold((l) => null, (r) {
      _notificationController.createNotification(
        text: '${user.name} が「いいね」をしました！',
        postId: tweet.id,
        notificationType: NotificationType.like,
        uid: tweet.uid,
      );
    });
  }

  void reshareCount(
    Tweet tweet,
    UserModel currentUser,
    BuildContext context,
  ) async {
    tweet = tweet.copyWith(
      reshareBy: currentUser.name,
      likes: [],
      commentIds: [],
      reshareCount: tweet.reshareCount + 1,
    );

    final res = await _tweetAPI.updateReshareCount(tweet);
    res.fold((l) => showSnackBar(context, l.message), (r) async {
      tweet = tweet.copyWith(
        id: ID.unique(),
        reshareCount: 0,
        tweetedAt: DateTime.now(),
        resharedUid: currentUser.uid,
      );

      final res2 = await _tweetAPI.shareTweet(tweet);
      res2.fold(
        (l) => showSnackBar(context, l.message),
        (r) {
          showSnackBar(context, 'リツイートしました！');
          _notificationController.createNotification(
            text: '${currentUser.name}がリツイートしました！',
            postId: tweet.id,
            notificationType: NotificationType.retweet,
            uid: tweet.uid,
          );
        },
      );
    });
  }

  //リンクの取得
  String _getLinkFromTweet(String text) {
    String link = '';
    List<String> wordInSentence = text.split(' ');
    for (String word in wordInSentence) {
      if (word.startsWith('https://') || word.startsWith('www.')) {
        link = word;
      }
    }
    return link;
  }

  //ハッシュタグの取得
  List<String> _getHashtagsFromTweet(String text) {
    List<String> hashtags = [];
    List<String> wordInSentence = text.split(' ');
    for (String word in wordInSentence) {
      if (word.startsWith('#')) {
        hashtags.add(word);
      }
    }
    return hashtags;
  }
}
