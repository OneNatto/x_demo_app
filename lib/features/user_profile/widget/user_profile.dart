import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_demo_app/common/common.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/features/tweet/widgets/tweet_card.dart';
import 'package:x_demo_app/features/user_profile/controller/user_profile_controller.dart';
import 'package:x_demo_app/features/user_profile/view/edit_profile_view.dart';
import 'package:x_demo_app/features/user_profile/widget/follow_count.dart';
import 'package:x_demo_app/models/user_model.dart';
import 'package:x_demo_app/theme/theme.dart';

import '../../../constants/constants.dart';
import '../../../models/tweet_model.dart';
import '../../tweet/controller/tweet_controller.dart';

class UserProfile extends ConsumerWidget {
  final UserModel user;
  const UserProfile({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;

    return currentUser == null
        ? const Loader()
        : NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 150,
                  floating: true,
                  snap: true,
                  flexibleSpace: Stack(
                    children: [
                      Positioned.fill(
                        child: user.bannerPic.isNotEmpty
                            ? Image.network(user.bannerPic,
                                fit: BoxFit.fitWidth)
                            : Container(
                                color: Palette.blueColor,
                              ),
                      ),
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.profilePic),
                          radius: 45,
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomRight,
                        margin: const EdgeInsets.all(20),
                        child: OutlinedButton(
                          onPressed: () {
                            if (currentUser.uid == user.uid) {
                              Navigator.push(context, EditProfileView.route());
                            } else {
                              ref
                                  .read(UserProfileControllerProvider.notifier)
                                  .followUser(
                                    user: user,
                                    context: context,
                                    currentUser: currentUser,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: const BorderSide(
                                      color: Palette.whiteColor)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 25)),
                          child: Text(
                            currentUser.uid == user.uid
                                ? 'プロフィールを編集'
                                : currentUser.following.contains(user.uid)
                                    ? 'アンフォロー'
                                    : 'フォロー',
                            style: const TextStyle(
                              color: Palette.whiteColor,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(8),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Row(
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (user.isTwitterBlue)
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: SvgPicture.asset(
                                    AssetsConstants.verifiedIcon),
                              ),
                          ],
                        ),
                        Text(
                          '@${user.name}',
                          style: const TextStyle(
                            fontSize: 17,
                            color: Palette.greyColor,
                          ),
                        ),
                        Text(
                          user.bio,
                          style: const TextStyle(
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            FollowCount(
                              count: user.following.length,
                              text: 'フォロー',
                            ),
                            const SizedBox(width: 15),
                            FollowCount(
                              count: user.followers.length,
                              text: 'フォロワー',
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        const Divider(
                          color: Palette.whiteColor,
                        ),
                      ],
                    ),
                  ),
                )
              ];
            },
            body: ref.watch(getUserTweetProvider(user.uid)).when(
                  data: (tweets) {
                    String profileUserId;
                    //自分で自分のプロフィールを見ている時
                    if (currentUser.uid == user.uid) {
                      profileUserId = currentUser.uid;
                    } else {
                      profileUserId = user.uid;
                    }
                    return ref
                        .watch(getUserResharedTweetProvider(profileUserId))
                        .when(
                          data: (resharedTweets) {
                            return ref.watch(getLatestTweetProvider).when(
                                  data: (data) {
                                    if (data.events.contains(
                                      'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.create',
                                    )) {
                                      final newTweet =
                                          Tweet.fromMap(data.payload);
                                      if (!tweets.contains(newTweet)) {
                                        tweets.insert(0, newTweet);
                                      }
                                    } else if (data.events.contains(
                                      'databases.*.collections.${AppwriteConstants.tweetCollection}.documents.*.update',
                                    )) {
                                      var tweet = Tweet.fromMap(data.payload);
                                      final tweetId = tweet.id;

                                      tweet = tweets
                                          .where((element) =>
                                              element.id == tweetId)
                                          .first;

                                      final tweetIndex = tweets.indexOf(tweet);
                                      tweets.removeWhere(
                                          (element) => element.id == tweetId);

                                      tweet = Tweet.fromMap(data.payload);
                                      tweets.insert(tweetIndex, tweet);
                                    }
                                    tweets = tweets.where((tweet) {
                                      return tweet.resharedUid == "" ||
                                          tweet.resharedUid == profileUserId;
                                    }).toList();

                                    if (resharedTweets.isNotEmpty) {
                                      tweets = [...tweets, ...resharedTweets];
                                    }

                                    tweets.sort((a, b) =>
                                        b.tweetedAt.compareTo(a.tweetedAt));
                                    return ListView.builder(
                                      itemCount: tweets.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final tweet = tweets[index];
                                        if (tweet.repliedTo.isNotEmpty) {
                                          return const SizedBox();
                                        } else if (tweet.uid != user.uid) {
                                          if (tweet.resharedUid == user.uid) {
                                            return TweetCard(tweet: tweet);
                                          } else {
                                            return const SizedBox();
                                          }
                                        } else {
                                          return TweetCard(tweet: tweet);
                                        }
                                      },
                                    );
                                  },
                                  error: (error, stackTrace) =>
                                      ErrorText(error: error.toString()),
                                  loading: () {
                                    tweets = tweets.where((tweet) {
                                      return tweet.resharedUid == "" ||
                                          tweet.resharedUid == profileUserId;
                                    }).toList();
                                    if (resharedTweets.isNotEmpty) {
                                      tweets = [...tweets, ...resharedTweets];
                                    }
                                    tweets.sort((a, b) =>
                                        b.tweetedAt.compareTo(a.tweetedAt));
                                    return ListView.builder(
                                      itemCount: tweets.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        final tweet = tweets[index];
                                        if (tweet.repliedTo.isNotEmpty) {
                                          return const SizedBox();
                                        } else if (tweet.uid != user.uid) {
                                          if (tweet.resharedUid == user.uid) {
                                            return TweetCard(tweet: tweet);
                                          } else {
                                            return const SizedBox();
                                          }
                                        } else {
                                          return TweetCard(tweet: tweet);
                                        }
                                      },
                                    );
                                  },
                                );
                          },
                          error: (error, stackTrace) =>
                              ErrorText(error: error.toString()),
                          loading: () => const Loader(),
                        );
                  },
                  error: (error, stackTrace) =>
                      ErrorText(error: error.toString()),
                  loading: () => const Loader(),
                ),
          );
  }
}
