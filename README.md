# supa_helper

<p align="center">
  <a href="https://pub.dev/packages/supa_helper">
    <img src="https://img.shields.io/pub/v/supa_helper.svg" alt="pub version"/>
  </a>
  <a href="https://pub.dev/packages/supa_helper">
    <img src="https://img.shields.io/pub/points/supa_helper" alt="pub points"/>
  </a>
  <a href="https://opensource.org/licenses/MIT">
    <img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT license"/>
  </a>
</p>

<p align="center">
  A clean, unified Flutter wrapper around Supabase — less boilerplate, more productivity.
</p>

---

## Why supa_helper?

Using `supabase_flutter` directly works, but it requires repetitive setup code across every project. `supa_helper` gives you:

- ✅ **One-line initialization** — set up Auth, Database, Storage, and Realtime in a single call
- ✅ **Consistent API** — every service follows the same pattern, no surprises
- ✅ **Typed exceptions** — know exactly which service failed and why
- ✅ **Less boilerplate** — stop rewriting the same wrapper code in every project

---

## Features

| Service | Capabilities |
|---|---|
| 🔐 **Auth** | Email/password, OTP, social sign-in, auth state listener |
| 🗄️ **Database** | GET, INSERT, UPDATE, UPSERT, DELETE, COUNT, RPC |
| 📦 **Storage** | Upload, download, delete, signed URLs |
| 📡 **Realtime** | Subscribe/unsubscribe to Postgres changes |

---

## Installation

```yaml
dependencies:
  supa_helper: ^last-version
```

Then run:

```bash
flutter pub get
```

---

## Setup

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

// Forgot password
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
    // Your Google Sign-In logic here
    return SocialAuthResult(
      idToken: 'ID_TOKEN',
      accessToken: 'ACCESS_TOKEN',
      email: 'user@gmail.com',
    );
  }
}

// Then use it:
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

// Always cancel when done
subscription.cancel();
```

---

## Database

```dart
final db = SupaHelper.instance.database;

// GET all rows
final users = await db.GET(table: 'users');

// GET with filter
final admins = await db.GET(
  table: 'users',
  filter: (q) => q.eq('role', 'admin'),
);

// GET single row
final user = await db.GET_SINGLE(
  table: 'users',
  filter: (q) => q.eq('id', '123'),
);

// INSERT one row
await db.INSERT(
  table: 'users',
  data: {'name': 'John', 'email': 'john@example.com'},
);

// INSERT multiple rows
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

// UPSERT (insert or update)
await db.UPSERT(
  table: 'users',
  data: {'id': '123', 'name': 'John'},
);

// DELETE
await db.DELETE(table: 'users', column: 'id', value: '123');

// COUNT
final count = await db.COUNT(table: 'users');

// RPC (call a Postgres function)
final result = await db.RPC(
  function: 'my_postgres_function',
  params: {'param1': 'value'},
);
```

---

## Storage

```dart
final storage = SupaHelper.instance.storage;

// Upload a file and get its public URL
final url = await storage.uploadAndGetUrl(
  file,
  bucketName: 'images',
  folderName: 'avatars',
);

// Upload raw bytes
final url = await storage.uploadBytesAndGetUrl(
  bytes,
  bucketName: 'images',
  folderName: 'avatars',
  mimeType: 'image/jpeg',
);

// Download a file
final bytes = await storage.downloadFile(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
);

// Delete a file
await storage.deleteFile(
  bucketName: 'images',
  filePath: 'avatars/IMG123',
);

// Create a signed (temporary) URL
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

// Subscribe to table changes
realtime.subscribeToTable(
  channelName: 'orders_channel',
  schema: 'public',
  table: 'orders',
  event: PostgresChangeEvent.all,
  callback: (payload) => print('Change detected: $payload'),
  onError: (e) => print('Realtime error: $e'),
);

// Unsubscribe from a specific channel
realtime.unsubscribe('orders_channel');

// Unsubscribe from all channels
realtime.unsubscribeAll();

// Check subscription status
print(realtime.isSubscribed('orders_channel'));
print(realtime.activeChannelsCount);
```

---

## Error Handling

Every service throws its own typed exception, so you always know what went wrong:

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
} on SupaDatabaseException catch (e) {
  print('Database error: $e');
}
```

---

## Reset

If you need to re-initialize (e.g., switching environments):

```dart
await SupaHelper.instance.reset();
// Now you can call init() again with different credentials
```

---

## Contributing

Contributions are welcome! If you find a bug or want a new feature, feel free to open an issue or submit a PR on [GitHub](https://github.com/Abdelrahmanyehia9/supa_helper).

**Planned features:**
- Edge Functions support
- Pagination helpers
- Offline caching layer

---

## License

MIT © [Abdelrahman Yehia](https://github.com/Abdelrahmanyehia9)