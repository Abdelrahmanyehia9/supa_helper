# supa_helper

A Flutter package that simplifies Supabase integration by wrapping its core services — Authentication, Database, Storage, and Realtime — into a clean, unified API.

---

## Features

- 🔐 **Authentication** — Email/password, OTP, and social media sign-in
- 🗄️ **Database** — Simple CRUD operations with typed responses
- 📦 **Storage** — Upload, download, manage files and buckets
- 📡 **Realtime** — Subscribe to Postgres changes with ease
- ⚠️ **Typed Exceptions** — Every service throws its own typed exception

---

## Installation

```yaml
dependencies:
  supa_helper:
    git:
      url: https://github.com/YOUR_USERNAME/supa_helper.git
```

---

## Setup

```dart
import 'package:supa_helper/supa_helper.dart';

await SupaHelper.instance.init(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
);
```

---

## Authentication

### Email & Password

```dart
// Sign up
await SupaHelper.instance.auth.createUser(
  email: 'user@example.com',
  password: 'password123',
  metaData: {'name': 'John'},
);

// Sign in
await SupaHelper.instance.auth.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Sign out
await SupaHelper.instance.auth.signOut();

// Forget password
await SupaHelper.instance.auth.sendForgetPasswordEmail(
  email: 'user@example.com',
);
```

### OTP / Phone

```dart
// Send OTP
await SupaHelper.instance.auth.phoneProvider.sendOtp(
  phone: '+201234567890',
);

// Verify OTP
await SupaHelper.instance.auth.phoneProvider.verifyOtp(
  phone: '+201234567890',
  otp: '123456',
);
```

### Social Media

Implement `SupaSocialMediaAuth` for your provider:

```dart
class GoogleAuth implements SupaSocialMediaAuth {
  @override
  OAuthProvider get oAuthProvider => OAuthProvider.google;

  @override
  Future<SocialAuthResult> signIn() async {
    // your google sign in logic
    return SocialAuthResult(
      idToken: 'ID_TOKEN',
      accessToken: 'ACCESS_TOKEN',
      email: 'user@gmail.com',
    );
  }
}
```

Then pass it to `socialMediaSignIn`:

```dart
await SupaHelper.instance.auth.socialMediaSignIn(
  GoogleAuth(),
  (result) => print('Logged in: ${result.email}'),
);
```

### Auth State Listener

```dart
final subscription = SupaHelper.instance.auth.setupAuthListener(
  onSignedIn: (id) => print('Signed in: $id'),
  onSignedOut: () => print('Signed out'),
  onUserUpdated: (id) => print('User updated: $id'),
  onInitialSession: () => print('Session restored'),
  onError: (e) => print('Auth error: $e'),
);

// Cancel when no longer needed
subscription.cancel();
```

---

## Database

```dart
final db = SupaHelper.instance.database;

// GET all
final users = await db.GET(table: 'users');

// GET with filter
final admins = await db.GET(
  table: 'users',
  filter: (q) => q.eq('role', 'admin'),
);

// GET single
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
  column: 'id',
  value: '123',
);

// UPSERT
await db.UPSERT(
  table: 'users',
  data: {'id': '123', 'name': 'John'},
);

// DELETE
await db.DELETE(table: 'users', column: 'id', value: '123');

// COUNT
final count = await db.COUNT(table: 'users');

// RPC
final result = await db.RPC(
  function: 'my_postgres_function',
  params: {'param1': 'value'},
);
```

---

## Storage

```dart
final storage = SupaHelper.instance.storage;

// Upload file
final url = await storage.uploadAndGetUrl(
  file,
  bucketName: 'images',
  folderName: 'avatars',
);

// Upload bytes
final url = await storage.uploadBytesAndGetUrl(
  bytes,
  bucketName: 'images',
  folderName: 'avatars',
  mimeType: 'image/jpeg',
);

// Download
final bytes = await storage.downloadFile(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
);

// Delete
await storage.deleteFile(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
);

// Signed URL
final signedUrl = await storage.createSignedUrl(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
  expiresInSeconds: 3600,
);
```

---

## Realtime

```dart
final realtime = SupaHelper.instance.realtime;

// Subscribe
realtime.subscribeToTable(
  channelName: 'orders_channel',
  schema: 'public',
  table: 'orders',
  event: PostgresChangeEvent.all,
  callback: (payload) => print('Change: $payload'),
  onError: (e) => print('Error: $e'),
);

// Unsubscribe
realtime.unsubscribe('orders_channel');

// Unsubscribe all
realtime.unsubscribeAll();

// Check status
print(realtime.isSubscribed('orders_channel'));
print(realtime.activeChannelsCount);
```

---

## Error Handling

Every service throws a typed exception:

| Service    | Exception                |
|------------|--------------------------|
| Auth       | `SupaAuthException`      |
| Database   | `SupaDatabaseException`  |
| Storage    | `SupaStorageException`   |
| Realtime   | `SupaRealtimeException`  |

```dart
try {
  await SupaHelper.instance.auth.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'wrong_password',
  );
} on SupaAuthException catch (e) {
  print('Auth error: $e');
}
```

---

## Reset

```dart
// Disposes all services and allows re-initialization
await SupaHelper.instance.reset();
```