import 'dart:io';
import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupaStorage {
  /// Uploads a [File] to `[folderName]/[prefix][timestamp]` and returns its public URL.
  Future<String> uploadAndGetUrl(
      File file, {
        String? customName,
        required String bucketName,
        required String folderName,
        String prefix = "IMG",
        bool upsert = true,
      }) ;

  /// Uploads raw [Uint8List] bytes with the given [mimeType] and returns its public URL.
  Future<String> uploadBytesAndGetUrl(
      Uint8List bytes, {
        String? customName,
        required String bucketName,
        required String folderName,
        required String mimeType,
        String prefix = "FILE",
        bool upsert = true,
      })
  ;

  // ───────────────────────── Download ─────────────────────────

  /// Downloads a file and returns its content as [Uint8List].
  Future<Uint8List> downloadFile({
    required String bucketName,
    required String filePath,
  })
  ;

  /// Downloads a file and saves it directly to the given [destination] [File].
  Future<void> downloadToFile({
    required String bucketName,
    required String filePath,
    required File destination,
  })
 ;

  // ───────────────────────── Delete ─────────────────────────

  /// Deletes a single file at [filePath] from the bucket.
  Future<void> deleteFile({
    required String bucketName,
    required String filePath,
  })
;

  /// Deletes multiple files at once from the bucket.
  Future<void> deleteFiles({
    required String bucketName,
    required List<String> filePaths,
  })
 ;

  // ───────────────────────── Move / Copy ─────────────────────────

  /// Moves a file from [fromPath] to [toPath] within the same bucket.
  Future<void> moveFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) ;

  /// Copies a file from [fromPath] to [toPath] within the same bucket.
  Future<void> copyFile({
    required String bucketName,
    required String fromPath,
    required String toPath,
  }) ;

  // ───────────────────────── List ─────────────────────────

  /// Lists files inside [folderPath] with optional pagination and sorting.
  Future<List<FileObject>> listFiles({
    required String bucketName,
    String folderPath = '',
    int limit = 100,
    int offset = 0,
    SortBy sortBy = const SortBy(column: 'name', order: 'asc'),
  }) ;

  // ───────────────────────── URL Helpers ─────────────────────────

  /// Returns the permanent public URL for a file.
  String getPublicUrl({
    required String bucketName,
    required String filePath,
  }) ;

  /// Generates a temporary signed URL that expires after [expiresInSeconds].
  Future<String> createSignedUrl({
    required String bucketName,
    required String filePath,
    required int expiresInSeconds,
  }) ;
  /// Generates signed URLs for multiple files at once.
  Future<List<SignedUrl>> createSignedUrls({
    required String bucketName,
    required List<String> filePaths,
    required int expiresInSeconds,
  }) ;

  // ───────────────────────── Bucket Management ─────────────────────────

  /// Creates a new bucket with optional visibility and file restrictions.
  Future<void> createBucket(
      String bucketName, {
        bool isPublic = false,
        int? fileSizeLimit,
        List<String>? allowedMimeTypes,
      });

  /// Deletes all files inside the bucket without deleting the bucket itself.
  Future<void> emptyBucket(String bucketName);

  /// Permanently deletes the bucket and all its contents.
  Future<void> deleteBucket(String bucketName) ;
  /// Returns a list of all available buckets.
  Future<List<Bucket>> listBuckets() ;
  /// Fetches metadata for a single bucket by [bucketName].
  Future<Bucket> getBucket(String bucketName);
}