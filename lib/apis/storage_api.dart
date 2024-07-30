import 'dart:async';
import 'package:appwrite/appwrite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:x_demo_app/constants/appwrite_constants.dart';
import 'package:x_demo_app/core/provider.dart';

final storageAPIProvider = Provider((ref) {
  return StorageAPI(storage: ref.watch(appwriteStorageProvider));
});

class StorageAPI {
  final Storage _storage;
  StorageAPI({required Storage storage}) : _storage = storage;

  Future<List<String>> uploadImage(List<XFile> files) async {
    List<String> imageLinks = [];
    try {
      for (final file in files) {
        final bytes = await file.readAsBytes();
        final uploadFile =
            InputFile.fromBytes(bytes: bytes, filename: "${file.path}.png");
        final uploadedImage = await _storage.createFile(
          bucketId: AppwriteConstants.imagesBucket,
          fileId: ID.unique(),
          file: uploadFile,
        );

        imageLinks.add(AppwriteConstants.imageUrl(uploadedImage.$id));
      }
      return imageLinks;
    } catch (e) {
      return [];
    }
  }
}
