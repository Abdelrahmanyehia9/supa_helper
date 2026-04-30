# supa_helper

A Flutter package that provides a clean, simplified wrapper around [Supabase](https://supabase.com/) services — authentication, database, storage, and realtime — through a single singleton interface.

---

## Features

- 🔐 **Authentication** — Email/password, social sign-in (Google, Apple, Facebook), and phone OTP
- 🗄️ **Database** — Simple CRUD helpers (`GET`, `INSERT`, `UPDATE`, `DELETE`, `UPSERT`, `RPC`, `COUNT`)
- 📦 **Storage** — Upload, download, delete, move, copy files and manage buckets
- 📡 **Realtime** — Subscribe to Postgres table changes with named channels
- ⚡ **Lazy initialization** — Services are only created when first accessed
- 🧱 **Typed exceptions** — Each service throws its own `SupaException` subclass

---

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  supa_helper:
    path: ../supa_helper   # or your pub.dev / git reference
```

Then run:

```bash
flutter pub get
```

---

## Setup

Initialize once at app startup, typically in `main.dart`:

```dart
import 'package:supa_helper/supa_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await supa.init(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );

  runApp(const MyApp());
}
```

---

## Authentication

### Email & Password

```dart
// Sign in
final response = await supa.auth.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Register
final response = await supa.auth.createUser(
  email: 'user@example.com',
  password: 'password123',
  metaData: {'name': 'John Doe'},
);

// Forgot password
await supa.auth.sendForgetPasswordEmail(email: 'user@example.com');

// Update user
await supa.auth.updateUser(password: 'newPassword');
```

### Social Sign-In

```dart
// Google
final response = await supa.auth.socialMediaSignIn<GoogleSignInAuthentication>(
  SupaGoogleProvider(serverClientId: 'YOUR_SERVER_CLIENT_ID'),
  (googleAuth) => print('Google raw data: $googleAuth'),
);

// Apple
final response = await supa.auth.socialMediaSignIn<AuthorizationCredentialAppleID>(
  SupaAppleProvider(),
  (appleCred) => print('Apple raw data: $appleCred'),
);

// Facebook
final response = await supa.auth.socialMediaSignIn<LoginResult>(
  SupaFacebookProvider(),
  (fbResult) => print('Facebook raw data: $fbResult'),
);
```

> For Facebook, follow the setup guide at https://facebook.meedu.app/docs/7.x.x/intro/

### Phone OTP

```dart
// Send OTP
await supa.auth.phoneProvider.sendOtp(phone: '+1234567890');

// Verify OTP
final response = await supa.auth.phoneProvider.verifyOtp(
  phone: '+1234567890',
  otp: '123456',
);
```

---

## Database

All methods map directly to common Supabase PostgREST operations.

```dart
// Fetch multiple rows
final users = await supa.database.GET(
  table: 'users',
  filter: (q) => q.eq('active', true).order('created_at'),
);

// Fetch a single row
final user = await supa.database.GET_SINGLE(
  table: 'users',
  filter: (q) => q.eq('id', userId),
);

// Insert
final newUser = await supa.database.INSERT(
  table: 'users',
  data: {'name': 'Jane', 'email': 'jane@example.com'},
);

// Insert many
final rows = await supa.database.INSERT_MANY(
  table: 'products',
  data: [{'name': 'A'}, {'name': 'B'}],
);

// Upsert
await supa.database.UPSERT(
  table: 'profiles',
  data: {'id': userId, 'bio': 'Hello!'},
);

// Update
await supa.database.UPDATE(
  table: 'users',
  data: {'name': 'Updated Name'},
  column: 'id',
  value: userId,
);

// Delete
await supa.database.DELETE(
  table: 'users',
  column: 'id',
  value: userId,
);

// Call a Postgres function
final result = await supa.database.RPC(
  function: 'my_function',
  params: {'param1': 'value'},
);

// Count rows
final count = await supa.database.COUNT(
  table: 'orders',
  filter: (q) => q.eq('status', 'pending'),
);
```

---

## Storage

```dart
import 'dart:io';

// Upload a File and get its public URL
final url = await supa.storage.uploadAndGetUrl(
  File('/path/to/image.jpg'),
  bucketName: 'avatars',
  folderName: 'users',
  prefix: 'AVATAR',
);

// Upload raw bytes
final url = await supa.storage.uploadBytesAndGetUrl(
  bytes,
  bucketName: 'documents',
  folderName: 'reports',
  mimeType: 'application/pdf',
);

// Download a file
final bytes = await supa.storage.downloadFile(
  bucketName: 'avatars',
  filePath: 'users/AVATAR123456',
);

// Download directly to a File
await supa.storage.downloadToFile(
  bucketName: 'avatars',
  filePath: 'users/AVATAR123456',
  destination: File('/local/path/file.jpg'),
);

// Get public URL
final url = supa.storage.getPublicUrl(
  bucketName: 'avatars',
  filePath: 'users/AVATAR123456',
);

// Create a signed (temporary) URL
final signedUrl = await supa.storage.createSignedUrl(
  bucketName: 'documents',
  filePath: 'reports/report.pdf',
  expiresInSeconds: 3600,
);

// Delete a file
await supa.storage.deleteFile(
  bucketName: 'avatars',
  filePath: 'users/AVATAR123456',
);

// Delete multiple files
await supa.storage.deleteFiles(
  bucketName: 'avatars',
  filePaths: ['users/A', 'users/B'],
);

// Move / copy
await supa.storage.moveFile(bucketName: 'docs', fromPath: 'a/file', toPath: 'b/file');
await supa.storage.copyFile(bucketName: 'docs', fromPath: 'a/file', toPath: 'b/file');

// List files in a folder
final files = await supa.storage.listFiles(
  bucketName: 'avatars',
  folderPath: 'users',
);

// Bucket management
await supa.storage.createBucket('my-bucket', isPublic: true);
await supa.storage.emptyBucket('my-bucket');
await supa.storage.deleteBucket('my-bucket');
final buckets = await supa.storage.listBuckets();
```

---

## Realtime

```dart
// Subscribe to all changes on a table
supa.realtime.subscribeToTable(
  channelName: 'orders-channel',
  schema: 'public',
  table: 'orders',
  callback: (payload) => print('Change: ${payload.newRecord}'),
  onError: (e) => print('Error: $e'),
);

// Subscribe to a specific row
supa.realtime.subscribeToTable(
  channelName: 'my-order',
  schema: 'public',
  table: 'orders',
  event: PostgresChangeEvent.update,
  filter: PostgresChangeFilter(
    type: PostgresChangeFilterType.eq,
    column: 'id',
    value: orderId,
  ),
  callback: (payload) => print('Updated: ${payload.newRecord}'),
);

// Unsubscribe a single channel
supa.realtime.unsubscribe('orders-channel');

// Unsubscribe all
supa.realtime.unsubscribeAll();

// Check subscription status
final isActive = supa.realtime.isSubscribed('orders-channel');
final count = supa.realtime.activeChannelsCount;
```

---

## Error Handling

Every service throws a typed subclass of `SupaException`:

| Exception | Thrown by |
|---|---|
| `SupaAuthException` | `supa.auth` |
| `SupaDatabaseException` | `supa.database` |
| `SupaStorageException` | `supa.storage` |
| `SupaRealtimeException` | `supa.realtime` |

```dart
try {
  await supa.auth.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'wrong',
  );
} on SupaAuthException catch (e) {
  print('Auth error: ${e.message}');
} on SupaException catch (e) {
  print('Supa error: ${e.message}');
}
```

---

## Custom Social Provider

Implement `SupaSocialMediaAuth<T>` to add your own OAuth provider:

```dart
class MyCustomProvider implements SupaSocialMediaAuth<MyCredential> {
  @override
  OAuthProvider get oAuthProvider => OAuthProvider.github;

  @override
  Future<SupaAuthResult<MyCredential>> signIn() async {
    // your sign-in logic
    return SupaAuthResult(idToken: 'token', rawData: myCredential);
  }
}
```

---

## Reset / Logout

Call `supa.reset()` after sign-out to clear all cached service instances:

```dart
await supabase.auth.signOut();
supa.reset();
```

---

## License

MIT