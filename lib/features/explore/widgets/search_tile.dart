import 'package:flutter/material.dart';
import 'package:x_demo_app/features/user_profile/view/user_profile_view.dart';
import 'package:x_demo_app/models/user_model.dart';
import 'package:x_demo_app/theme/palette.dart';

class SearchTile extends StatelessWidget {
  final UserModel user;
  const SearchTile({
    required this.user,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(context, UserProfileView.route(user));
      },
      leading: CircleAvatar(
        backgroundImage: NetworkImage(user.profilePic),
        radius: 30,
      ),
      title: Text(
        user.name,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '@${user.name}',
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
          Text(
            user.bio,
            style: const TextStyle(
              color: Palette.whiteColor,
            ),
          ),
        ],
      ),
    );
  }
}
