import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:x_demo_app/constants/constants.dart';
import 'package:x_demo_app/core/enums/notification_type_enum.dart';
import 'package:x_demo_app/models/notification_model.dart' as model;
import 'package:x_demo_app/theme/theme.dart';

class NotificationTile extends StatelessWidget {
  final model.Notification notification;
  const NotificationTile({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: notification.notificationType == NotificationType.follow
          ? const Icon(Icons.person, color: Palette.blueColor)
          : notification.notificationType == NotificationType.like
              ? SvgPicture.asset(
                  AssetsConstants.likeFilledIcon,
                  height: 20,
                )
              : notification.notificationType == NotificationType.retweet
                  ? SvgPicture.asset(
                      AssetsConstants.retweetIcon,
                      height: 20,
                    )
                  : null,
      title: Text(notification.text),
    );
  }
}
