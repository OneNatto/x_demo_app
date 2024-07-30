import 'package:any_link_preview/any_link_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:like_button/like_button.dart';
import 'package:x_demo_app/constants/assets_constants.dart';
import 'package:x_demo_app/core/core.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/features/tweet/controller/tweet_controller.dart';
import 'package:x_demo_app/features/tweet/views/reply_view.dart';
import 'package:x_demo_app/features/tweet/widgets/carousel_image.dart';
import 'package:x_demo_app/features/tweet/widgets/hashtag_text.dart';
import 'package:x_demo_app/features/tweet/widgets/tweet_icon_button.dart';
import 'package:x_demo_app/features/user_profile/view/user_profile_view.dart';
import 'package:x_demo_app/theme/theme.dart';

import '../../../common/common.dart';
import '../../../models/tweet_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class TweetCard extends ConsumerWidget {
  final Tweet tweet;
  const TweetCard({
    super.key,
    required this.tweet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return currentUser == null
        ? Container()
        : ref.watch(userDetailsProvider(tweet.uid)).when(
              data: (user) {
                return InkWell(
                  onTap: () {
                    Navigator.push(context, ReplyScreen.route(tweet));
                  },
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.all(10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  UserProfileView.route(user),
                                );
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(user.profilePic),
                                radius: 35,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (tweet.reshareBy.isNotEmpty)
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        AssetsConstants.retweetIcon,
                                        height: 20,
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        '${tweet.reshareBy}がリツイートしました',
                                        style: const TextStyle(
                                            fontSize: 16,
                                            color: Palette.greyColor,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                Row(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(
                                          right: user.isTwitterBlue ? 1 : 5),
                                      child: Text(
                                        user.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 19,
                                        ),
                                      ),
                                    ),
                                    if (user.isTwitterBlue)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(right: 5),
                                        child: SvgPicture.asset(
                                            AssetsConstants.verifiedIcon),
                                      ),
                                    Text(
                                      '@${user.name}・${timeago.format(
                                        tweet.tweetedAt,
                                        locale: 'en_short',
                                      )}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        color: Palette.greyColor,
                                      ),
                                    ),
                                  ],
                                ),
                                if (tweet.repliedTo.isNotEmpty)
                                  ref
                                      .watch(
                                          getTweetByIdProvider(tweet.repliedTo))
                                      .when(
                                        data: (data) {
                                          final replingToUser = ref
                                              .watch(
                                                  userDetailsProvider(data.uid))
                                              .value;
                                          return RichText(
                                            text: TextSpan(
                                              text: '@${replingToUser?.name}',
                                              style: const TextStyle(
                                                fontSize: 16,
                                                color: Palette.blueColor,
                                              ),
                                              children: const [
                                                TextSpan(
                                                  text: 'への返信',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Palette.greyColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                        error: (error, stackTrace) => ErrorText(
                                          error: error.toString(),
                                        ),
                                        loading: () => const SizedBox(),
                                      ),
                                HashtagText(text: tweet.text),
                                if (tweet.tweetType == TweetType.image)
                                  CarouselImage(imageLinks: tweet.imageLinks),
                                if (tweet.link.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  AnyLinkPreview(
                                    displayDirection:
                                        UIDirection.uiDirectionHorizontal,
                                    link: 'https://${tweet.link}',
                                  )
                                ],
                                Container(
                                  margin: const EdgeInsets.only(
                                    top: 10,
                                    right: 20,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TweetIconButton(
                                        text: (tweet.commentIds.length +
                                                tweet.likes.length +
                                                tweet.reshareCount)
                                            .toString(),
                                        pathName: AssetsConstants.viewsIcon,
                                        onTap: () {},
                                      ),
                                      TweetIconButton(
                                        text:
                                            tweet.commentIds.length.toString(),
                                        pathName: AssetsConstants.commentIcon,
                                        onTap: () {},
                                      ),
                                      TweetIconButton(
                                          text: tweet.reshareCount.toString(),
                                          pathName: AssetsConstants.retweetIcon,
                                          onTap: () {
                                            ref
                                                .read(tweetControllerProvider
                                                    .notifier)
                                                .reshareCount(tweet,
                                                    currentUser, context);
                                          }),
                                      LikeButton(
                                        size: 25,
                                        onTap: (isLiked) async {
                                          ref
                                              .read(tweetControllerProvider
                                                  .notifier)
                                              .likeTweet(tweet, currentUser);
                                          return !isLiked;
                                        },
                                        isLiked: tweet.likes
                                            .contains(currentUser.uid),
                                        likeBuilder: (isLiked) {
                                          return isLiked
                                              ? SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeFilledIcon,
                                                )
                                              : SvgPicture.asset(
                                                  AssetsConstants
                                                      .likeOutlinedIcon,
                                                );
                                        },
                                        likeCount: tweet.likes.length,
                                        countBuilder:
                                            (likeCount, isLiked, text) {
                                          return Padding(
                                            padding: const EdgeInsets.only(
                                                left: 2.0),
                                            child: Text(
                                              text,
                                              style: TextStyle(
                                                color: isLiked
                                                    ? Palette.redColor
                                                    : Palette.greyColor,
                                                fontSize: 16,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.share_outlined,
                                          size: 25,
                                          color: Palette.greyColor,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 1),
                              ],
                            ),
                          )
                        ],
                      ),
                      const Divider(
                        color: Palette.greyColor,
                      ),
                    ],
                  ),
                );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader(),
            );
  }
}
