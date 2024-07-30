import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:x_demo_app/constants/constants.dart';
import 'package:x_demo_app/core/core.dart';
import '../models/tweet_model.dart';

final tweetAPIProvider = Provider((ref) {
  return TweetAPI(
    db: ref.watch(appwriteDatabaseProvider),
    realtime: ref.watch(appwriteRealtimeProvider),
  );
});

abstract class ITweetAPI {
  FutureEither<Document> shareTweet(Tweet tweet);
  Future<List<Document>> getTweets();
  Stream<RealtimeMessage> getLatestTweet();
  FutureEither<Document> likeTweet(Tweet tweet);
  FutureEither<Document> updateReshareCount(Tweet tweet);
  Future<List<Document>> getReplysToTweet(Tweet tweet);
  Future<Document> getTweetById(String id);
  Future<List<Document>> getUserTweet(String uid);
  Future<List<Document>> getTweetsByHashtag(String hashtagText);
  Future<List<Document>> getUserResharedTweet(String uid);
}

class TweetAPI implements ITweetAPI {
  final Databases _db;
  final Realtime _realtime;
  TweetAPI({
    required Databases db,
    required Realtime realtime,
  })  : _db = db,
        _realtime = realtime;

  @override
  FutureEither<Document> shareTweet(Tweet tweet) async {
    try {
      final document = await _db.createDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollection,
        documentId: ID.unique(),
        data: tweet.toMap(),
      );

      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? '不明なエラー', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getTweets() async {
    final documents = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetCollection,
      queries: [
        Query.orderDesc('tweetedAt'),
      ],
    );

    return documents.documents;
  }

  @override
  Stream<RealtimeMessage> getLatestTweet() {
    final stream = _realtime.subscribe([
      'databases.${AppwriteConstants.databaseId}.collections.${AppwriteConstants.tweetCollection}.documents'
    ]).stream;

    return stream;
  }

  @override
  FutureEither<Document> likeTweet(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollection,
        documentId: tweet.id,
        data: {
          'likes': tweet.likes,
        },
      );

      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? '不明なエラー', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  FutureEither<Document> updateReshareCount(Tweet tweet) async {
    try {
      final document = await _db.updateDocument(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollection,
        documentId: tweet.id,
        data: {
          'reshareCount': tweet.reshareCount,
        },
      );

      return right(document);
    } on AppwriteException catch (e, st) {
      return left(Failure(e.message ?? '不明なエラー', st));
    } catch (e, st) {
      return left(Failure(e.toString(), st));
    }
  }

  @override
  Future<List<Document>> getReplysToTweet(Tweet tweet) async {
    final document = await _db.listDocuments(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetCollection,
      queries: [
        Query.equal('repliedTo', tweet.id),
      ],
    );

    return document.documents;
  }

  @override
  Future<Document> getTweetById(String id) async {
    return _db.getDocument(
      databaseId: AppwriteConstants.databaseId,
      collectionId: AppwriteConstants.tweetCollection,
      documentId: id,
    );
  }

  @override
  Future<List<Document>> getUserTweet(String uid) async {
    final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollection,
        queries: [
          Query.equal('uid', uid),
        ]);

    return documents.documents;
  }

  @override
  Future<List<Document>> getTweetsByHashtag(String hashtagText) async {
    final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollection,
        queries: [
          Query.search('hashtags', hashtagText),
        ]);

    return documents.documents;
  }

  @override
  Future<List<Document>> getUserResharedTweet(String uid) async {
    final documents = await _db.listDocuments(
        databaseId: AppwriteConstants.databaseId,
        collectionId: AppwriteConstants.tweetCollection,
        queries: [
          Query.search('resharedUid', uid),
        ]);

    return documents.documents;
  }
}
