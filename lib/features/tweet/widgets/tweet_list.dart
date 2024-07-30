import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/common/common.dart';
import 'package:x_demo_app/constants/appwrite_constants.dart';
import 'package:x_demo_app/features/tweet/controller/tweet_controller.dart';
import 'package:x_demo_app/features/tweet/widgets/tweet_card.dart';

import '../../../models/tweet_model.dart';
import '../../auth/controller/auth_controller.dart';

class TweetList extends ConsumerWidget {
  const TweetList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return ref.watch(getTweetsProvider).when(
          data: (tweets) {
            return ref.watch(getLatestTweetProvider).when(
                  data: (data) {
                    if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.create',
                    )) {
                      tweets.insert(0, Tweet.fromMap(data.payload));
                    } else if (data.events.contains(
                      'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.update',
                    )) {
                      var tweet = Tweet.fromMap(data.payload);
                      final tweetId = tweet.id;

                      tweet = tweets
                          .where((element) => element.id == tweetId)
                          .first;

                      final tweetIndex = tweets.indexOf(tweet);
                      tweets.removeWhere((element) => element.id == tweetId);

                      tweet = Tweet.fromMap(data.payload);
                      tweets.insert(tweetIndex, tweet);
                    }

                    final allTweets = tweets.where((tweet) {
                      return currentUser!.following.contains(tweet.uid) ||
                          (tweet.uid == currentUser.uid &&
                              (currentUser.following
                                      .contains(tweet.resharedUid) ||
                                  tweet.resharedUid == "")) ||
                          tweet.resharedUid == currentUser.uid ||
                          currentUser.following.contains(tweet.resharedUid);
                    }).toList();

                    tweets = allTweets;

                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        if (tweet.repliedTo.isNotEmpty) {
                          return const SizedBox();
                        } else {
                          return TweetCard(tweet: tweet);
                        }
                      },
                    );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () {
                    final allTweets = tweets.where((tweet) {
                      return currentUser!.following.contains(tweet.uid) ||
                          (tweet.uid == currentUser.uid &&
                              (currentUser.following
                                      .contains(tweet.resharedUid) ||
                                  tweet.resharedUid == "")) ||
                          tweet.resharedUid == currentUser.uid ||
                          currentUser.following.contains(tweet.resharedUid);
                    }).toList();

                    tweets = allTweets;
                    return ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (BuildContext context, int index) {
                        final tweet = tweets[index];
                        if (tweet.repliedTo.isNotEmpty) {
                          return const SizedBox();
                        } else {
                          return TweetCard(tweet: tweet);
                        }
                      },
                    );
                  },
                );
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loader(),
        );
  }
}
