import 'dart:async';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'dart:html' as html;

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(content),
    ),
  );
}

String getNameFromEmail(String email) {
  return email.split('@')[0];
}

Future<List<XFile>> pickImages() async {
  final List<XFile> images = [];
  final ImagePicker picker = ImagePicker();
  final imageFiles = await picker.pickMultiImage();

  if (imageFiles.isNotEmpty) {
    for (final image in imageFiles) {
      final compressedImage = await compressImageForWeb(image);
      images.add(compressedImage!);
    }
  }
  return images;
}

Future<XFile?> pickImage() async {
  final picker = ImagePicker();
  final imageFile = await picker.pickImage(source: ImageSource.gallery);
  if (imageFile != null) {
    final compressedImage = await compressImageForWeb(imageFile);
    return compressedImage;
  }
  return null;
}

Future<XFile?> compressImageForWeb(XFile file) async {
  try {
    // 画像ファイルをバイトデータとして読み込む
    final bytes = await file.readAsBytes();

    // 画像をデコード
    img.Image? image = img.decodeImage(bytes);

    if (image == null) {
      return null;
    }

    int newWidth = (image.width * 0.5).round();
    int newHeight = (image.height * 0.5).round();

    // 画像を圧縮
    img.Image resized =
        img.copyResize(image, width: newWidth, height: newHeight);
    final compressedBytes =
        Uint8List.fromList(img.encodeJpg(resized, quality: 80));

    // 圧縮されたバイトデータをBlobとして作成
    final blob = html.Blob([compressedBytes]);

    // BlobをURLとして作成
    final url = html.Url.createObjectUrlFromBlob(blob);

    // XFileとして返す
    return XFile(url, name: file.name, length: compressedBytes.length);
  } catch (e) {
    print('Error during image compression: $e');
    return null;
  }
}
