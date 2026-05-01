import 'dart:io';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';
import '../errors/supa_exception.dart';

final class SupaStorage {
  final SupabaseStorageClient storage;
  const SupaStorage(this.storage);


  /// Uploads a [File] to `[folderName]/[prefix][timestamp]` and returns its public URL.
  Future<String> uploadAndGetUrl(
      File file, {
        required String bucketName,
        required String folderName,
        String prefix = "IMG",
        bool upsert = true,
      }) async {
    try {
      final fileName = "$prefix${DateTime.now().millisecondsSinceEpoch}";
      final filePath = '$folderName/$fileName';
      await storage.from(bucketName).upload(filePath, file, fileOptions: FileOptions(upsert: upsert));
      return storage.from(bucketName).getPublicUrl(filePath);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Uploads raw [Uint8List] bytes with the given [mimeType] and returns its public URL.
  Future<String> uploadBytesAndGetUrl(
      Uint8List bytes, {
        required String bucketName,
        required String folderName,
        required String mimeType,
        String prefix = "FILE",
        bool upsert = true,
      }) async {
    try {
      final fileName = "$prefix${DateTime.now().millisecondsSinceEpoch}";
      final filePath = '$folderName/$fileName';
      await storage.from(bucketName).uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(upsert: upsert, contentType: mimeType),
      );
      return storage.from(bucketName).getPublicUrl(filePath);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  // ───────────────────────── Download ─────────────────────────

  /// Downloads a file and returns its content as [Uint8List].
  Future<Uint8List> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      return await storage.from(bucketName).download(filePath);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Downloads a file and saves it directly to the given [destination] [File].
  Future<void> downloadToFile({
    required String bucketName,
    required String filePath,
    required File destination,
  }) async {
    try {
      final bytes = await storage.from(bucketName).download(filePath);
      await destination.writeAsBytes(bytes);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  // ───────────────────────── Delete ─────────────────────────

  /// Deletes a single file at [filePath] from the bucket.
  Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await storage.from(bucketName).remove([filePath]);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Deletes multiple files at once from the bucket.
  Future<void> deleteFiles({
    required String bucketName,
    required List<String> filePaths,
  }) async {
    try {
      await storage.from(bucketName).remove(filePaths);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  // ───────────────────────── Move / Copy ─────────────────────────

  /// Moves a file from [fromPath] to [toPath] within the same bucket.
  Future<void> moveFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await storage.from(bucketName).move(fromPath, toPath);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Copies a file from [fromPath] to [toPath] within the same bucket.
  Future<void> copyFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await storage.from(bucketName).copy(fromPath, toPath);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  // ───────────────────────── List ─────────────────────────

  /// Lists files inside [folderPath] with optional pagination and sorting.
  Future<List<FileObject>> listFiles({
    required String bucketName,
    String folderPath = '',
    int limit = 100,
    int offset = 0,
    SortBy sortBy = const SortBy(column: 'name', order: 'asc'),
  }) async {
    try {
      return await storage.from(bucketName).list(
        path: folderPath,
        searchOptions: SearchOptions(limit: limit, offset: offset, sortBy: sortBy),
      );
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  // ───────────────────────── URL Helpers ─────────────────────────

  /// Returns the permanent public URL for a file.
  String getPublicUrl({
    required String bucketName,
    required String filePath,
  }) {
    return storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Generates a temporary signed URL that expires after [expiresInSeconds].
  Future<String> createSignedUrl({
    required String bucketName,
    required String filePath,
    required int expiresInSeconds,
  }) async {
    try {
      return await storage.from(bucketName).createSignedUrl(filePath, expiresInSeconds);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Generates signed URLs for multiple files at once.
  Future<List<SignedUrl>> createSignedUrls({
    required String bucketName,
    required List<String> filePaths,
    required int expiresInSeconds,
  }) async {
    try {
      return await storage.from(bucketName).createSignedUrls(filePaths, expiresInSeconds);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  // ───────────────────────── Bucket Management ─────────────────────────

  /// Creates a new bucket with optional visibility and file restrictions.
  Future<void> createBucket(
      String bucketName, {
        bool isPublic = false,
        int? fileSizeLimit,
        List<String>? allowedMimeTypes,
      }) async {
    try {
      await storage.createBucket(
        bucketName,
        BucketOptions(
          public: isPublic,
          fileSizeLimit: fileSizeLimit?.toString(),
          allowedMimeTypes: allowedMimeTypes,
        ),
      );
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Deletes all files inside the bucket without deleting the bucket itself.
  Future<void> emptyBucket(String bucketName) async {
    try {
      await storage.emptyBucket(bucketName);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Permanently deletes the bucket and all its contents.
  Future<void> deleteBucket(String bucketName) async {
    try {
      await storage.deleteBucket(bucketName);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Returns a list of all available buckets.
  Future<List<Bucket>> listBuckets() async {
    try {
      return await storage.listBuckets();
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }

  /// Fetches metadata for a single bucket by [bucketName].
  Future<Bucket> getBucket(String bucketName) async {
    try {
      return await storage.getBucket(bucketName);
    } on StorageException catch (e) {
      throw SupaStorageException(e.message);
    } catch (e) {
      throw SupaStorageException(e.toString());
    }
  }
}