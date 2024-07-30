import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/common/common.dart';
import 'package:x_demo_app/constants/appwrite_constants.dart';
import 'package:x_demo_app/features/tweet/controller/tweet_controller.dart';
import 'package:x_demo_app/features/tweet/widgets/tweet_card.dart';

import '../../../models/tweet_model.dart';

class ReplyScreen extends ConsumerStatefulWidget {
  static route(Tweet tweet) =>
      MaterialPageRoute(builder: (context) => ReplyScreen(tweet: tweet));
  final Tweet tweet;
  const ReplyScreen({
    super.key,
    required this.tweet,
  });

  @override
  _ReplyScreenState createState() => _ReplyScreenState();
}

class _ReplyScreenState extends ConsumerState<ReplyScreen> {
  final TextEditingController replyText = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    replyText.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tweet = widget.tweet;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ポスト'),
      ),
      body: Column(
        children: [
          TweetCard(tweet: tweet),
          ref.watch(getReplysToTweetProvider(tweet)).when(
              data: (tweets) {
                return ref.watch(getLatestTweetProvider).when(
                      data: (data) {
                        final latestTweet = Tweet.fromMap(data.payload);

                        bool isTweetAlreadyPresent = false;
                        for (final tweetModel in tweets) {
                          if (tweetModel.id == latestTweet.id) {
                            isTweetAlreadyPresent = true;
                            break;
                          }
                        }

                        if (!isTweetAlreadyPresent &&
                            latestTweet.repliedTo == tweet.id) {
                          if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.create')) {
                            tweets.insert(0, Tweet.fromMap(data.payload));
                          } else if (data.events.contains(
                              'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.update')) {
                            var tweet = Tweet.fromMap(data.payload);
                            final tweetId = tweet.id;

                            tweet = tweets
                                .where((element) => element.id == tweetId)
                                .first;

                            final tweetIndex = tweets.indexOf(tweet);
                            tweets.removeWhere(
                                (element) => element.id == tweetId);

                            tweet = Tweet.fromMap(data.payload);
                            tweets.insert(tweetIndex, tweet);
                          }
                        }
                        return Expanded(
                          child: ListView.builder(
                            itemCount: tweets.length,
                            itemBuilder: (BuildContext context, int index) {
                              final tweet = tweets[index];
                              return TweetCard(tweet: tweet);
                            },
                          ),
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: tweets.length,
                            itemBuilder: (BuildContext context, int index) {
                              final tweet = tweets[index];
                              return TweetCard(tweet: tweet);
                            },
                          ),
                        );
                      },
                    );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader()),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(
          bottom: 20,
          right: 10,
          left: 10,
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: replyText,
                onSubmitted: (value) {
                  ref.read(tweetControllerProvider.notifier).shareTweet(
                    images: [],
                    text: value,
                    context: context,
                    repliedTo: tweet.id,
                    repliedToUserId: tweet.uid,
                  );
                  replyText.clear();
                },
                decoration: const InputDecoration(
                  hintText: 'リプライを入力',
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                ref.read(tweetControllerProvider.notifier).shareTweet(
                  images: [],
                  text: replyText.text,
                  context: context,
                  repliedTo: tweet.id,
                  repliedToUserId: tweet.uid,
                );
                replyText.clear();
              },
              icon: const Icon(Icons.send),
            ),
          ],
        ),
      ),
      resizeToAvoidBottomInset: true,
    );
  }
}
