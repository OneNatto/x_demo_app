import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:x_demo_app/apis/user_api.dart';
import 'package:x_demo_app/models/user_model.dart';

final exploreControllerProvider = StateNotifierProvider((ref) {
  return ExploreController(userAPI: ref.watch(userAPIProvider));
});

final searchUserByNameProvider =
    FutureProvider.family((ref, String name) async {
  final exploreController = ref.watch(exploreControllerProvider.notifier);
  return exploreController.seacrhUserByName(name);
});

class ExploreController extends StateNotifier<bool> {
  final UserAPI _userAPI;
  ExploreController({
    required UserAPI userAPI,
  })  : _userAPI = userAPI,
        super(false);

  Future<List<UserModel>> seacrhUserByName(String name) async {
    final users = await _userAPI.searchUserByName(name);
    return users.map((e) => UserModel.fromMap(e.data)).toList();
  }
}
