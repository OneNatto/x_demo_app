// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_demo_app/theme/palette.dart';

class TweetIconButton extends StatelessWidget {
  final String text;
  final String pathName;
  final VoidCallback onTap;
  const TweetIconButton({
    Key? key,
    required this.text,
    required this.pathName,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        SvgPicture.asset(
          pathName,
          color: Palette.greyColor,
        ),
        Container(
          margin: const EdgeInsets.all(6),
          child: Text(
            text,
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ]),
    );
  }
}
