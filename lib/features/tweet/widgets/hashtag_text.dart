import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:x_demo_app/features/tweet/views/hashtag_tweet_view.dart';
import 'package:x_demo_app/theme/palette.dart';

class HashtagText extends StatelessWidget {
  final String text;
  const HashtagText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    List<TextSpan> textspans = [];
    text.split(' ').forEach((element) {
      if (element.startsWith('#')) {
        textspans.add(
          TextSpan(
            text: '$element ',
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                Navigator.push(context, HashtagTweetView.route(element));
              },
            style: const TextStyle(
                color: Palette.blueColor,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
        );
      } else if (element.startsWith('https://') || element.startsWith('www.')) {
        textspans.add(
          TextSpan(
            text: '$element ',
            style: const TextStyle(
              color: Palette.blueColor,
              fontSize: 18,
            ),
          ),
        );
      } else {
        textspans.add(
          TextSpan(
            text: '$element ',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
            ),
          ),
        );
      }
    });

    return RichText(
      text: TextSpan(children: textspans),
    );
  }
}
