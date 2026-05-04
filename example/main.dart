// ignore_for_file: unused_local_variable, avoid_redundant_argument_values
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:supa_helper/supa_helper.dart';

Future<void> main() async {
 WidgetsFlutterBinding.ensureInitialized();
/// Init SupaHelper
 await SupaHelper.instance.init(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
 );

 /// auth create New user
 await SupaHelper.instance.auth.createUser(
  email: 'user@example.com',
  password: 'password123',

  metaData: {'name': 'John'} //optional,
 );
 /// login
 await SupaHelper.instance.auth.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
 );
 /// send forget password email
 await SupaHelper.instance.auth.sendForgetPasswordEmail(
  email: 'user@example.com',
 );
/// update user
 await SupaHelper.instance.auth.updateUser(
  password: 'newPassword123',
  email: 'newemail@example.com',
 );


/// mobile login steps (send otp / verify otp)
 await SupaHelper.instance.auth.phoneProvider.sendOtp(
  phone: '+201234567890',
 );

 await SupaHelper.instance.auth.phoneProvider.verifyOtp(
  phone: '+201234567890',
  otp: '123456',
 );

 // ═══════════════════════════════════════════
 // Auth - Social Media
 // ═══════════════════════════════════════════
 await SupaHelper.instance.auth.socialMediaSignIn(
  GoogleAuth(), // should implements SupaSocialMediaAuth
      (result) => debugPrint('Logged in: ${result.email}'),
 );

 // ═══════════════════════════════════════════
 // Auth - Listener
 // ═══════════════════════════════════════════
 final subscription = SupaHelper.instance.auth.setupAuthListener(
  onSignedIn: (id) => debugPrint('Signed in: $id'),
  onSignedOut: () => debugPrint('Signed out'),
  onUserUpdated: (id) => debugPrint('User updated: $id'),
  onInitialSession: () => debugPrint('Session initialized'),
 );
 ///cancel listener
 subscription.cancel();
 /// logout
 await SupaHelper.instance.auth.signOut();

 ///helper getters
 debugPrint('${SupaHelper.instance.auth.isAuthenticated}');
 debugPrint('${SupaHelper.instance.auth.user}');
 debugPrint('${SupaHelper.instance.auth.uID}');

/// postgres database
 final db = SupaHelper.instance.database;
 /// GET * FROM users TABLE
 final users = await db.GET(table: 'users');
 /// GET * FROM users WHERE role = admin
 final admins = await db.GET(
  table: 'users',
  select: 'id, name, email',
  filter: (q /* query*/ ) => q.eq('role', 'admin').order("created_at", ascending:  true),
 );

 // GET SINGLE
 final user = await db.GET_SINGLE(
  table: 'users',
  filter: (q) => q.eq('id', '123'),
 );


 // INSERT
 await db.INSERT(
  table: 'users',
  data: {'name': 'John', 'email': 'john@example.com'},
 );

 // INSERT MANY
 await db.INSERT_MANY(
  table: 'users',
  data: [
   {'name': 'Alice'},
   {'name': 'Bob'},
  ],
 );

 // UPDATE
 await db.UPDATE(
  table: 'users',
  data: {'name': 'John Updated'},
  idValue: 'id',
  idColumn: 'id'
 );

 // UPSERT
 await db.UPSERT(
  table: 'users',
  data: {'id': '123', 'name': 'John'},
  idColumn: 'id',
  idValue: 'id'
 );

 // DELETE
 await db.DELETE(
  table: 'users',
  filter: (q) => q.eq('id', '123'),
 );

 // Count
 final count = await db.COUNT(table: 'users');
// count for filtered data
 final activeCount = await db.COUNT(
  table: 'users',
  filter: (q) => q.eq('status', 'active'),
 );

 // RPC
 final result = await db.RPC(
  function: 'my_postgres_function',
  params: {'param1': 'value'},
 );

 // ═══════════════════════════════════════════
 // Storage
 // ═══════════════════════════════════════════
 final storage = SupaHelper.instance.storage;

 // Upload File
 final url = await storage.uploadAndGetUrl(
  File('file/to/upload'),
  bucketName: 'images',
  folderName: 'avatars',
  prefix: 'IMG',
 );

 // Upload Bytes
 final bytesUrl = await storage.uploadBytesAndGetUrl(
  Uint8List(100000),
  bucketName: 'images',
  folderName: 'avatars',
  mimeType: 'image/jpeg',
 );

 // Download
 final fileBytes = await storage.downloadFile(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
 );

 await storage.downloadToFile(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
  destination: File('path/to/save'),
 );

 // Delete
 await storage.deleteFile(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
 );

 await storage.deleteFiles(
  bucketName: 'images',
  filePaths: ['avatars/IMG1', 'avatars/IMG2'],
 );

 // Move & Copy
 await storage.moveFile(
  bucketName: 'images',
  fromPath: 'avatars/IMG123',
  toPath: 'archive/IMG123',
 );

 await storage.copyFile(
  bucketName: 'images',
  fromPath: 'avatars/IMG123',
  toPath: 'backup/IMG123',
 );

 // List
 final files = await storage.listFiles(
  bucketName: 'images',
  folderPath: 'avatars',
  limit: 20,
  offset: 0,
 );

 // URLs
 final publicUrl = storage.getPublicUrl(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
 );

 final signedUrl = await storage.createSignedUrl(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
  expiresInSeconds: 3600,
 );

 final signedUrls = await storage.createSignedUrls(
  bucketName: 'images',
  filePaths: ['avatars/IMG1', 'avatars/IMG2'],
  expiresInSeconds: 3600,
 );

 // Bucket Management
 await storage.createBucket('videos', isPublic: true);
 await storage.emptyBucket('videos');
 await storage.deleteBucket('videos');
 final buckets = await storage.listBuckets();
 final bucket = await storage.getBucket('images');

 // ═══════════════════════════════════════════
 // Realtime
 // ═══════════════════════════════════════════
 final realtime = SupaHelper.instance.realtime;

 realtime.subscribeToTable(
  channelName: 'orders_channel',
  schema: 'public',
  table: 'orders',
  event: PostgresChangeEvent.all,
  callback: (payload) => debugPrint('Change: $payload'),
 );

 realtime.unsubscribe('orders_channel');
 realtime.unsubscribeAll();
 /// if sunbscriped
 debugPrint(realtime.isSubscribed('orders_channel').toString());
 /// total active channels
 debugPrint(realtime.activeChannelsCount.toString());

 // ═══════════════════════════════════════════
 // Error Handling
 // ═══════════════════════════════════════════
 try {
  await SupaHelper.instance.auth.signInWithEmailAndPassword(
   email: 'user@example.com',
   password: 'wrong_password',
  );
 } on SupaAuthException catch (e) {
  /// e.message , e.code , e.rawError ,e.statusCode
  debugPrint('Auth error: ${e.message}');
 } on SupaDatabaseException catch (e) {
  debugPrint('Database error: ${e.message}');
 } on SupaStorageException catch (e) {
  debugPrint('Storage error: ${e.message}');
 } on SupaRealtimeException catch (e) {
  debugPrint('Realtime error: ${e.message}');
 } on SupaUnExpectedException catch (e) {
  debugPrint('Unexpected error: ${e.message}');
 }catch (e){
  debugPrint(e.toString()) ;
 }

  SupaHelper.instance.reset();
}

/// implements Social Auth Example
class GoogleAuth implements SupaSocialMediaAuth {
 @override
 OAuthProvider get oAuthProvider => OAuthProvider.google;

 @override
 Future<SocialAuthResult> signIn() async {
  // your google sign in logic
  return const SocialAuthResult(
   idToken: 'ID_TOKEN',
   accessToken: 'ACCESS_TOKEN',
   email: 'user@gmail.com',
   displayName: 'John Doe',
  );
 }
}