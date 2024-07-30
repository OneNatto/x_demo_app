class AppwriteConstants {
  static const String endPoint = 'https://cloud.appwrite.io/v1';
  static const String databaseId = '659ba6bb6b9f44bd27b5';
  static const String projectId = '6597c7377976d7791cf2';

  static const String userCollection = '65bb9d87beb16fa5ab31';
  static const String tweetCollection = '65d1cfc16ace982d4d5b';
  static const String notificationCollection = '65e9b5d9f250f7088708';

  static const String imagesBucket = '65d35301685b95c103be';

  static String imageUrl(String imageId) {
    return '$endPoint/storage/buckets/$imagesBucket/files/$imageId/view?project=$projectId&mode=admin';
  }
}
