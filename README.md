# supa_helper

<p align="center">
  <a href="https://pub.dev/packages/supa_helper">
    <img src="https://img.shields.io/pub/v/supa_helper.svg" alt="pub version"/>
  </a>
  <a href="https://pub.dev/packages/supa_helper">
    <img src="https://img.shields.io/pub/points/supa_helper" alt="pub points"/>
  </a>
  <a href="https://pub.dev/packages/supa_helper">
    <img src="https://img.shields.io/pub/dm/supa_helper" alt="pub monthly downloads"/>
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT license"/>
  </a>
</p>

<p align="center">
  <b>Supabase is powerful. Using it shouldn't be painful.</b><br/>
  supa_helper wraps every Supabase service into a clean, consistent API — so you stop fighting boilerplate and start shipping features.
</p>

---

## The problem

`supabase_flutter` is great — but using it directly in every project means:

- Scattered try/catch blocks with no idea which service threw what
- Rewriting the same CRUD calls across every screen
- Manually wiring up auth listeners, storage uploads, and realtime subscriptions every single time
- No consistency — every developer on the team writes it differently

**supa_helper fixes all of that.**

---

## Before & After

### Authentication

**Before:**
```dart
try {
  await Supabase.instance.client.auth.signInWithPassword(
    email: email,
    password: password,
  );
} on AuthException catch (e) {
  // generic error — now what?
  print(e.message);
} catch (e) {
  print(e);
}
```

**After:**
```dart
try {
  await SupaHelper.instance.auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on SupaAuthException catch (e) {
  // typed, clear, always from auth
  print(e);
}
```

---

### Database

**Before:**
```dart
try {
  final data = await Supabase.instance.client
      .from('orders')
      .select()
      .eq('status', 'pending');

  final orders = List<Map<String, dynamic>>.from(data);
} on PostgrestException catch (e) {
  print(e.message);
} catch (e) {
  print(e);
}
```

**After:**
```dart
try {
  final orders = await SupaHelper.instance.database.GET(
    table: 'orders',
    filter: (q) => q.eq('status', 'pending'),
  );
} on SupaDatabaseException catch (e) {
  print(e);
}
```

---

### Storage

**Before:**
```dart
try {
  final path = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  await Supabase.instance.client.storage
      .from('images')
      .upload('avatars/$path', file);

  final url = Supabase.instance.client.storage
      .from('images')
      .getPublicUrl('avatars/$path');
} on StorageException catch (e) {
  print(e.message);
}
```

**After:**
```dart
try {
  final url = await SupaHelper.instance.storage.uploadAndGetUrl(
    file,
    bucketName: 'images',
    folderName: 'avatars',
  );
} on SupaStorageException catch (e) {
  print(e);
}
```

---

### Realtime

**Before:**
```dart
final channel = Supabase.instance.client
    .channel('orders_channel')
    .onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'orders',
      callback: (payload) => print(payload),
    )
    .subscribe((status, error) {
      if (error != null) print(error);
    });

// later...
await Supabase.instance.client.removeChannel(channel);
```

**After:**
```dart
SupaHelper.instance.realtime.subscribeToTable(
  channelName: 'orders_channel',
  schema: 'public',
  table: 'orders',
  callback: (payload) => print(payload),
  onError: (e) => print(e),
);

// later...
SupaHelper.instance.realtime.unsubscribe('orders_channel');
```

---

## Features

| Service | What you get |
|---|---|
| 🔐 **Auth** | Email/password, OTP, social sign-in, auth state listener — all typed |
| 🗄️ **Database** | GET, GET_SINGLE, GET_PAGINATED, INSERT, INSERT_MANY, UPDATE, UPSERT, DELETE, DELETE_MANY, EXISTS, COUNT, RPC |
| 📦 **Storage** | Upload files or bytes, download, delete, signed URLs |
| 📡 **Realtime** | Subscribe/unsubscribe to Postgres changes with error handling built-in |

---

## Installation

```yaml
dependencies:
  supa_helper: ^latest
```

```bash
flutter pub get
```

---

## Setup

One call. Everything is ready.

```dart
import 'package:supa_helper/supa_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupaHelper.instance.init(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(const MyApp());
}
```

---

## Authentication

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

// Forgot password
await SupaHelper.instance.auth.sendForgetPasswordEmail(
  email: 'user@example.com',
);

// OTP
await SupaHelper.instance.auth.phoneProvider.sendOtp(phone: '+201234567890');
await SupaHelper.instance.auth.phoneProvider.verifyOtp(
  phone: '+201234567890',
  otp: '123456',
);

// Social sign-in
class GoogleAuth implements SupaSocialMediaAuth {
  @override
  OAuthProvider get oAuthProvider => OAuthProvider.google;

  @override
  Future<SocialAuthResult> signIn() async {
    return SocialAuthResult(
      idToken: 'ID_TOKEN',
      accessToken: 'ACCESS_TOKEN',
      email: 'user@gmail.com',
    );
  }
}

await SupaHelper.instance.auth.socialMediaSignIn(
  GoogleAuth(),
  (result) => print('Logged in: ${result.email}'),
);

// Auth state listener
final subscription = SupaHelper.instance.auth.setupAuthListener(
  onSignedIn: (id) => print('Signed in: $id'),
  onSignedOut: () => print('Signed out'),
  onUserUpdated: (id) => print('User updated: $id'),
  onInitialSession: () => print('Session restored'),
  onError: (e) => print('Error: $e'),
);

subscription.cancel(); // cancel when done
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

// GET paginated
final page = await db.GET_PAGINATED(
  table: 'orders',
  page: 1,
  perPage: 20,
);
print(page.data);        // rows
print(page.totalCount);  // total rows
print(page.hasMore);     // is there a next page?

// INSERT
await db.INSERT(
  table: 'users',
  data: {'name': 'John', 'email': 'john@example.com'},
);

// INSERT many
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
  idValue: '123',
);

// UPSERT
await db.UPSERT(
  table: 'users',
  data: {'id': '123', 'name': 'John'},
  idValue: '123',
);

// DELETE one
await db.DELETE(
  table: 'users',
  filter: (q) => q.eq('id', '123'),
);

// DELETE many
await db.DELETE_MANY(
  table: 'orders',
  ids: ['1', '2', '3'],
);

// EXISTS
final exists = await db.EXISTS(
  table: 'users',
  filter: (q) => q.eq('email', 'test@example.com'),
);

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

// Upload file → get public URL
final url = await storage.uploadAndGetUrl(
  file,
  bucketName: 'images',
  folderName: 'avatars',
);

// Upload bytes → get public URL
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
realtime.unsubscribeAll();

// Check status
print(realtime.isSubscribed('orders_channel'));
print(realtime.activeChannelsCount);
```

---

## Error Handling

No more guessing. Every service throws its own typed exception.

| Service | Exception |
|---|---|
| Auth | `SupaAuthException` |
| Database | `SupaDatabaseException` |
| Storage | `SupaStorageException` |
| Realtime | `SupaRealtimeException` |

```dart
try {
  await SupaHelper.instance.auth.signInWithEmailAndPassword(
    email: 'user@example.com',
    password: 'wrong_password',
  );
} on SupaAuthException catch (e) {
  print('Auth failed: $e');
}
```

---

## Reset

```dart
await SupaHelper.instance.reset();
// call init() again with new credentials
```

---

## Contributing

Found a bug? Have an idea? Open an issue or submit a PR on [GitHub](https://github.com/Abdelrahmanyehia9/supa_helper) — contributions are welcome.

---

## License

MIT © [Abdelrahman Yehia](https://github.com/Abdelrahmanyehia9)