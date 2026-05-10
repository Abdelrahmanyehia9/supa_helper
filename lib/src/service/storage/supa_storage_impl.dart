import 'dart:io';
import 'dart:typed_data';
import 'package:supa_helper/src/errors/handle_error.dart';
import 'package:supa_helper/supa_helper.dart' show SupaStorage;
import 'package:supabase_flutter/supabase_flutter.dart';


final class SupaStorageImpl implements SupaStorage{
  final SupabaseStorageClient storage;
  const SupaStorageImpl(this.storage,);

  /// Uploads a [File] to `[folderName]/[prefix][timestamp]` and returns its public URL.
  @override
  Future<String> uploadAndGetUrl(
      File file, {
        String? customName,
        required String bucketName,
        required String folderName,
        String prefix = "IMG",
        bool upsert = true,
      }) async {
    try {
      final fileName = customName ?? "$prefix${DateTime.now().millisecondsSinceEpoch}";
      final filePath = '$folderName/$fileName';
      await storage.from(bucketName).upload(filePath, file, fileOptions: FileOptions(upsert: upsert));
      return storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
       e.handleError();
    }
  }

  /// Uploads raw [Uint8List] bytes with the given [mimeType] and returns its public URL.
  @override
  Future<String> uploadBytesAndGetUrl(
      Uint8List bytes, {
        String? customName,
        required String bucketName,
        required String folderName,
        required String mimeType,
        String prefix = "FILE",
        bool upsert = true,
      }) async {
    try {
      final fileName =customName?? "$prefix${DateTime.now().millisecondsSinceEpoch}";
      final filePath = '$folderName/$fileName';
      await storage.from(bucketName).uploadBinary(
        filePath,
        bytes,
        fileOptions: FileOptions(upsert: upsert, contentType: mimeType),
      );
      return storage.from(bucketName).getPublicUrl(filePath);
    } catch (e) {
       e.handleError();
    }
  }

  // ───────────────────────── Download ─────────────────────────

  /// Downloads a file and returns its content as [Uint8List].
  @override
  Future<Uint8List> downloadFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      return await storage.from(bucketName).download(filePath);
    } catch (e) {
       e.handleError();
    }
  }

  /// Downloads a file and saves it directly to the given [destination] [File].
  @override
  Future<void> downloadToFile({
    required String bucketName,
    required String filePath,
    required File destination,
  }) async {
    try {
      final bytes = await storage.from(bucketName).download(filePath);
      await destination.writeAsBytes(bytes);
    } catch (e) {
       e.handleError();
    }
  }

  // ───────────────────────── Delete ─────────────────────────

  /// Deletes a single file at [filePath] from the bucket.
  @override
  Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  }) async {
    try {
      await storage.from(bucketName).remove([filePath]);
    } catch (e) {
       e.handleError();
    }
  }

  /// Deletes multiple files at once from the bucket.
  @override
  Future<void> deleteFiles({
    required String bucketName,
    required List<String> filePaths,
  }) async {
    try {
      await storage.from(bucketName).remove(filePaths);
    } catch (e) {
       e.handleError();
    }
  }

  // ───────────────────────── Move / Copy ─────────────────────────

  /// Moves a file from [fromPath] to [toPath] within the same bucket.
  @override
  Future<void> moveFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await storage.from(bucketName).move(fromPath, toPath);
    } catch (e) {
       e.handleError();
    }
  }

  /// Copies a file from [fromPath] to [toPath] within the same bucket.
  @override
  Future<void> copyFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) async {
    try {
      await storage.from(bucketName).copy(fromPath, toPath);
    } catch (e) {
       e.handleError();
    }
  }

  // ───────────────────────── List ─────────────────────────

  /// Lists files inside [folderPath] with optional pagination and sorting.
  @override
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
    } catch (e) {
       e.handleError();
    }
  }

  // ───────────────────────── URL Helpers ─────────────────────────

  /// Returns the permanent public URL for a file.
  @override
  String getPublicUrl({
    required String bucketName,
    required String filePath,
  }) {
    return storage.from(bucketName).getPublicUrl(filePath);
  }

  /// Generates a temporary signed URL that expires after [expiresInSeconds].
  @override
  Future<String> createSignedUrl({
    required String bucketName,
    required String filePath,
    required int expiresInSeconds,
  }) async {
    try {
      return await storage.from(bucketName).createSignedUrl(filePath, expiresInSeconds);
    } catch (e) {
       e.handleError();
    }
  }

  /// Generates signed URLs for multiple files at once.
  @override
  Future<List<SignedUrl>> createSignedUrls({
    required String bucketName,
    required List<String> filePaths,
    required int expiresInSeconds,
  }) async {
    try {
      return await storage.from(bucketName).createSignedUrls(filePaths, expiresInSeconds);
    } catch (e) {
       e.handleError();
    }
  }

  // ───────────────────────── Bucket Management ─────────────────────────

  /// Creates a new bucket with optional visibility and file restrictions.
  @override
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
    } catch (e) {
       e.handleError();
    }
  }

  /// Deletes all files inside the bucket without deleting the bucket itself.
  @override
  Future<void> emptyBucket(String bucketName) async {
    try {
      await storage.emptyBucket(bucketName);
    } catch (e) {
       e.handleError();
    }
  }

  /// Permanently deletes the bucket and all its contents.
  @override
  Future<void> deleteBucket(String bucketName) async {
    try {
      await storage.deleteBucket(bucketName);
    } catch (e) {
       e.handleError();
    }
  }

  /// Returns a list of all available buckets.
  @override
  Future<List<Bucket>> listBuckets() async {
    try {
      return await storage.listBuckets();
    } catch (e) {
       e.handleError();
    }
  }

  /// Fetches metadata for a single bucket by [bucketName].
  @override
  Future<Bucket> getBucket(String bucketName) async {
    try {
      return await storage.getBucket(bucketName);
    } catch (e) {
       e.handleError();
    }
  }
}