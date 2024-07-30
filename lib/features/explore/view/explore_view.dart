import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/common/error_page.dart';
import 'package:x_demo_app/common/loading_page.dart';
import 'package:x_demo_app/features/explore/controller/explore_controller.dart';
import 'package:x_demo_app/features/explore/widgets/search_tile.dart';
import 'package:x_demo_app/theme/palette.dart';

class ExploreView extends ConsumerStatefulWidget {
  const ExploreView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ExploreViewState();
}

class _ExploreViewState extends ConsumerState<ExploreView> {
  final searchController = TextEditingController();
  bool isShowUser = false;

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(50),
      borderSide: const BorderSide(
        color: Palette.searchBarColor,
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          onSubmitted: (value) {
            setState(() {
              isShowUser = true;
            });
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10).copyWith(left: 20),
            fillColor: Palette.searchBarColor,
            filled: true,
            enabledBorder: searchBorder,
            focusedBorder: searchBorder,
            hintText: 'ユーザーを検索',
          ),
        ),
      ),
      body: isShowUser
          ? ref.watch(searchUserByNameProvider(searchController.text)).when(
                data: (users) {
                  return ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (BuildContext context, int index) {
                      final user = users[index];
                      return SearchTile(user: user);
                    },
                  );
                },
                error: (error, stackTrace) => ErrorText(
                  error: error.toString(),
                ),
                loading: () => const Loader(),
              )
          : const SizedBox(),
    );
  }
}
