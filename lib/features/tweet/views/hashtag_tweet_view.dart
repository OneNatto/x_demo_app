import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/features/tweet/controller/tweet_controller.dart';
import 'package:x_demo_app/features/tweet/widgets/tweet_card.dart';

import '../../../common/common.dart';
import '../../../models/tweet_model.dart';

class HashtagTweetView extends ConsumerWidget {
  static route(String hashtagText) => MaterialPageRoute(
        builder: (context) => HashtagTweetView(hashtagText: hashtagText),
      );
  final String hashtagText;
  const HashtagTweetView({
    super.key,
    required this.hashtagText,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(hashtagText),
      ),
      body: Column(
        children: [
          ref.watch(getTweetByHashtagProvider(hashtagText)).when(
                data: (tweets) {
                  return Expanded(
                    child: ListView.builder(
                      itemCount: tweets.length,
                      itemBuilder: (context, index) {
                        Tweet tweet = tweets[index];
                        return TweetCard(tweet: tweet);
                      },
                    ),
                  );
                },
                error: (error, stackTrace) =>
                    ErrorText(error: error.toString()),
                loading: () => const Loader(),
              ),
        ],
      ),
    );
  }
}
