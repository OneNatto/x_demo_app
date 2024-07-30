import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_demo_app/constants/constants.dart';
import 'package:x_demo_app/features/explore/view/explore_view.dart';
import 'package:x_demo_app/features/notification/view/notifivation_view.dart';
import 'package:x_demo_app/features/tweet/widgets/tweet_list.dart';

class UiConstants {
  static AppBar appBar() {
    return AppBar(
      title: SvgPicture.asset(
        AssetsConstants.twitterLogo,
        height: 30,
      ),
      centerTitle: true,
    );
  }

  static List<Widget> bottomTabBarPages = const [
    TweetList(),
    ExploreView(),
    NotificationView(),
  ];
}
