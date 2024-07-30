import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/features/auth/controller/auth_controller.dart';
import 'package:x_demo_app/features/notification/controller/notification_controller.dart';
import 'package:x_demo_app/models/notification_model.dart' as model;
import '../../../common/common.dart';
import '../../../constants/constants.dart';
import '../widget/notification_tile.dart';

class NotificationView extends ConsumerWidget {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserDetailsProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('通知'),
      ),
      body: currentUser == null
          ? const Loader()
          : ref.watch(getNotificationsProvider(currentUser.uid)).when(
              data: (notifications) {
                print("1:${currentUser.uid}");
                print("1:$notifications");
                return ref.watch(getLatestNotificationProvider).when(
                      data: (data) {
                        print("2:$currentUser");
                        print("2:$data");

                        if (data.events.contains(
                            'databases.*.collections.${AppwriteConstants.notificationCollection}.documents.*.create')) {
                          final latestNotif =
                              model.Notification.fromMap(data.payload);

                          if (latestNotif.uid == currentUser.uid) {
                            notifications.insert(0, latestNotif);
                          }
                        }

                        return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            final notification = notifications[index];
                            return NotificationTile(notification: notification);
                          },
                        );
                      },
                      error: (error, stackTrace) =>
                          ErrorText(error: error.toString()),
                      loading: () {
                        print("3:$currentUser");
                        return ListView.builder(
                          itemCount: notifications.length,
                          itemBuilder: (BuildContext context, int index) {
                            final notification = notifications[index];
                            return NotificationTile(notification: notification);
                          },
                        );
                      },
                    );
              },
              error: (error, stackTrace) => ErrorText(error: error.toString()),
              loading: () => const Loader()),
    );
  }
}
