import 'package:flutter/material.dart';

import '../theme/palette.dart';

class RoundedSmallButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const RoundedSmallButton({
    super.key,
    required this.onTap,
    required this.label,
    this.backgroundColor = Palette.whiteColor,
    this.textColor = Palette.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Chip(
        label: Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 20,
        ),
        backgroundColor: backgroundColor,
      ),
    );
  }
}
