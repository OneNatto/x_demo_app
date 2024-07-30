enum NotificationType {
  like('like'),
  reply('reply'),
  retweet('retweet'),
  follow('follow');

  final String type;
  const NotificationType(this.type);
}

extension ConvertTweet on String {
  NotificationType toNotificationTypeEnum() {
    switch (this) {
      case 'reply':
        return NotificationType.reply;
      case 'retweet':
        return NotificationType.retweet;
      case 'follow':
        return NotificationType.follow;

      default:
        return NotificationType.like;
    }
  }
}
