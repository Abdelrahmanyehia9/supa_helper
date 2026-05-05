<div align="center">

# ⚡ supa_helper

### Supabase is powerful. Using it raw is punishment.

**`supa_helper` is the Flutter abstraction layer that replaces hundreds of lines of repetitive Supabase boilerplate with a single, consistent, typed API — so you ship features instead of infrastructure.**

<p>
  <a href="https://pub.dev/packages/supa_helper"><img src="https://img.shields.io/pub/v/supa_helper.svg" alt="pub version"/></a>
  <a href="https://pub.dev/packages/supa_helper"><img src="https://img.shields.io/pub/points/supa_helper" alt="pub points"/></a>
  <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/license-MIT-blue.svg" alt="MIT license"/></a>
</p>

</div>

---

## 😤 You've been here before

New Flutter project. Supabase backend. You're excited to build.

Then reality hits:

You write `try/catch` around every single call — auth, database, storage — each throwing a **different exception type** with **no shared structure**. You rewrite pagination logic for the third time this year. You wire up auth state listeners from scratch. You upload a file and manually construct the path, then call `getPublicUrl` separately. Someone on your team handles errors completely differently in their files and now the codebase is inconsistent. You add retry logic after your first production crash on a bad network.

**None of this is the app. All of this is noise.**

`supa_helper` is the package that kills that noise permanently.

---

## 🎯 One import. Every Supabase service. Zero boilerplate.

```dart
import 'package:supa_helper/supa_helper.dart';
```

Auth, Database, Storage, Realtime — all wired up, all typed, all consistent, all retryable. Ready from day one of every project.

---

## ⚙️ Setup in 10 seconds flat

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SupaHelper.instance.init(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_ANON_KEY',
  );

  runApp(const MyApp());
}
```

Need retries? Schema overrides? Auth flow customization? Optional. Nothing forced.

```dart
await SupaHelper.instance.init(
  url: 'YOUR_SUPABASE_URL',
  anonKey: 'YOUR_ANON_KEY',
  postgrestOptions: PostgrestOptions(retryAttempts: 3, schema: 'public'),
  authOptions: AuthOptions(retryAttempts: 2, autoRefreshToken: true),
  storageOptions: StorageOptions(retryAttempts: 2),
);
```

---

## 🔐 Auth — the way it should have always worked

### Sign up / Sign in / Sign out

```dart
final auth = SupaHelper.instance.auth;

// Create account with metadata saved directly to auth.users
await auth.createUser(
  email: 'user@example.com',
  password: 'password123',
  metaData: {'full_name': 'John Doe', 'role': 'customer'},
);

// Sign in
await auth.signInWithEmailAndPassword(
  email: 'user@example.com',
  password: 'password123',
);

// Password reset
await auth.sendForgetPasswordEmail(email: 'user@example.com');

// Update profile / password / email
await auth.updateUser(
  email: 'newemail@example.com',
  data: {'full_name': 'Updated Name'},
);

await auth.signOut();
```

### OTP / Phone auth

```dart
await auth.phoneProvider.sendOtp(phone: '+201234567890');

await auth.phoneProvider.verifyOtp(
  phone: '+201234567890',
  otp: '123456',
);
```

### Social Sign-In — built for extensibility

Other packages give you a rigid list of providers. `supa_helper` gives you an **interface**. You implement it once per provider. It plugs directly in — same call, same error type, same pattern forever.

```dart
class GoogleAuth implements SupaSocialMediaAuth {
  @override
  OAuthProvider get oAuthProvider => OAuthProvider.google;

  @override
  Future<SocialAuthResult> signIn() async {
    // your google_sign_in logic here
    return SocialAuthResult(
      idToken: googleUser.idToken,
      accessToken: googleUser.accessToken,
      email: googleUser.email,
    );
  }
}

await auth.socialMediaSignIn(
  GoogleAuth(),
  (result) => print('Welcome ${result.email}'),
);
```

Same pattern for Apple, Facebook, Twitter — any provider, forever.

### Auth State Listener — the one you'll never rewrite again

```dart
final subscription = auth.setupAuthListener(
  onSignedIn:       (id) => navigateToHome(),
  onSignedOut:      ()   => navigateToLogin(),
  onUserUpdated:    (id) => refreshUserProfile(id),
  onInitialSession: ()   => skipOnboarding(),
  onTokenRefreshed: ()   => print('Token silently refreshed'),
);

// Cancel when your widget disposes — no leaks
subscription.cancel();
```

Every auth event. Properly handled. Every time.

---

## 🗄️ Database — stop reinventing CRUD

### Before `supa_helper` — what you actually write

```dart
try {
  final data = await Supabase.instance.client
      .from('orders')
      .select()
      .eq('status', 'pending')
      .order('created_at', ascending: false);
  final orders = (data as List).map((e) => Order.fromJson(e)).toList();
} on PostgrestException catch (e) {
  // handle
} catch (e) {
  // handle again, differently
}
```

### After `supa_helper` — what you actually want to write

```dart
final orders = await db.GET<Order>(
  table: 'orders',
  filter: (q) => q.eq('status', 'pending').order('created_at'),
  mapper: Order.fromJson,
);
```

Typed. Mapped. Error handled. **One line of intent.**

### The full arsenal

```dart
final db = SupaHelper.instance.database;

// Fetch all — typed automatically with mapper
final users = await db.GET<User>(table: 'users', mapper: User.fromJson);

// Fetch exactly one row — returns empty map if not found, never throws null errors
final user = await db.GET_SINGLE<User>(
  table: 'users',
  filter: (q) => q.eq('id', userId),
  mapper: User.fromJson,
);

// Paginated fetch — totalCount, hasMore, currentPage all included
final page = await db.GET_PAGINATED<Order>(
  table: 'orders',
  page: 1,
  perPage: 20,
  filter: (q) => q.eq('user_id', currentUserId),
  mapper: Order.fromJson,
);

print(page.data);        // List<Order> for this page
print(page.totalCount);  // total matching rows in DB
print(page.hasMore);     // whether page 2 exists

// Insert one row — returns the created row
final newUser = await db.INSERT<User>(
  table: 'users',
  data: {'name': 'Alice', 'email': 'alice@example.com'},
  mapper: User.fromJson,
);

// Insert many at once
await db.INSERT_MANY(
  table: 'tags',
  data: [{'name': 'flutter'}, {'name': 'dart'}, {'name': 'supabase'}],
);

// Update by ID
await db.UPDATE<User>(
  table: 'users',
  idValue: userId,
  data: {'name': 'Alice Updated'},
  mapper: User.fromJson,
);

// Upsert — insert or update, conflict handled
await db.UPSERT(
  table: 'user_settings',
  idValue: userId,
  data: {'user_id': userId, 'theme': 'dark'},
);

// Delete with filter
await db.DELETE(
  table: 'notifications',
  filter: (q) => q.eq('read', true).eq('user_id', userId),
);

// Delete many by IDs — no loop needed
await db.DELETE_MANY(
  table: 'cart_items',
  ids: ['id1', 'id2', 'id3'],
);

// Does it exist? True/false, nothing else
final taken = await db.EXISTS(
  table: 'users',
  filter: (q) => q.eq('email', 'test@example.com'),
);

// Count — with or without filter
final total = await db.COUNT(table: 'orders');
final pending = await db.COUNT(
  table: 'orders',
  filter: (q) => q.eq('status', 'pending'),
);

// Call a Postgres RPC function
final stats = await db.RPC(
  function: 'get_user_stats',
  params: {'user_id': userId},
);
```

Every single method supports `retryAttempt` to override the global retry count per call. Production-grade resilience with zero extra dependencies.

---

## 📦 Storage — upload, get URL, done

### Before `supa_helper`

```dart
final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
final path = 'avatars/$fileName';
await Supabase.instance.client.storage
    .from('images')
    .upload(path, file, fileOptions: FileOptions(upsert: true));
final url = Supabase.instance.client.storage
    .from('images')
    .getPublicUrl(path);
```

5 lines. Manual path construction. Two separate calls. No error abstraction.

### After `supa_helper`

```dart
final url = await storage.uploadAndGetUrl(
  file,
  bucketName: 'images',
  folderName: 'avatars',
);
```

**One call. Automatic timestamp filename. Public URL returned directly.**

### Everything else storage will ever need

```dart
final storage = SupaHelper.instance.storage;

// Upload raw bytes — camera output, cropped images, generated PDFs
final url = await storage.uploadBytesAndGetUrl(
  bytes,
  bucketName: 'docs',
  folderName: 'contracts',
  mimeType: 'application/pdf',
  prefix: 'CONTRACT',
);

// Download to memory
final bytes = await storage.downloadFile(
  bucketName: 'images',
  filePath: 'avatars/IMG1234',
);

// Download and save to disk
await storage.downloadToFile(
  bucketName: 'images',
  filePath: 'avatars/IMG1234',
  destination: File('/local/path/avatar.jpg'),
);

// Delete one or many files
await storage.deleteFile(bucketName: 'images', filePath: 'avatars/IMG1234');
await storage.deleteFiles(bucketName: 'images', filePaths: ['a', 'b', 'c']);

// Move / Copy within a bucket
await storage.moveFile(bucketName: 'images', fromPath: 'temp/x', toPath: 'final/x');
await storage.copyFile(bucketName: 'images', fromPath: 'templates/t', toPath: 'user/t');

// List files with pagination and sorting
final files = await storage.listFiles(
  bucketName: 'images',
  folderPath: 'avatars',
  limit: 50,
  offset: 0,
);

// Expiring signed URL — for private buckets
final signedUrl = await storage.createSignedUrl(
  bucketName: 'private-docs',
  filePath: 'contracts/contract_123.pdf',
  expiresInSeconds: 3600,
);

// Bulk signed URLs — one call for many files
final signedUrls = await storage.createSignedUrls(
  bucketName: 'private-docs',
  filePaths: ['file1.pdf', 'file2.pdf', 'file3.pdf'],
  expiresInSeconds: 3600,
);

// Bucket management
await storage.createBucket('user-uploads', isPublic: true, fileSizeLimit: 5000000);
await storage.emptyBucket('temp-uploads');
await storage.deleteBucket('deprecated-bucket');
final buckets = await storage.listBuckets();
final bucket  = await storage.getBucket('images');
```

---

## 📡 Realtime — subscriptions that don't leak

### Before `supa_helper`

You manually hold a channel reference. You hope `dispose()` gets called. You handle errors inline. You write the same wiring code on every screen that needs live updates.

### After `supa_helper`

```dart
final realtime = SupaHelper.instance.realtime;

realtime.subscribeToTable(
  channelName: 'orders_channel',
  schema: 'public',
  table: 'orders',
  event: PostgresChangeEvent.insert,
  callback: (payload) => _handleNewOrder(payload),
);

// Clean, named unsubscribe — no reference management
realtime.unsubscribe('orders_channel');

// Or clear everything at once
realtime.unsubscribeAll();

// Useful for guards and debugging
print(realtime.isSubscribed('orders_channel')); // true/false
print(realtime.activeChannelsCount);            // total active

// In dispose() — one line, everything gone
realtime.dispose();
```

---

## 🛡️ Error Handling — typed, consistent, predictable

This is where most Supabase codebases quietly fall apart.

Raw `supabase_flutter` throws three completely unrelated exception types with different fields and no common interface. Every developer writes different catch blocks. Your error UI is inconsistent. Your logs are noisy.

`supa_helper` normalizes everything into one sealed hierarchy:

```
SupaException (sealed base — message, statusCode, rawError on all)
├── SupaAuthException       → auth operations
├── SupaDatabaseException   → database operations
├── SupaStorageException    → storage operations
├── SupaRealtimeException   → realtime subscriptions
└── SupaUnExpectedException → anything else
```

Write one error handler. Use it everywhere.

```dart
try {
  await SupaHelper.instance.auth.signInWithEmailAndPassword(
    email: email,
    password: password,
  );
} on SupaAuthException catch (e) {
  showSnackBar('Login failed: ${e.message}');
}
```

Or a global utility that covers your entire app:

```dart
String friendlyMessage(SupaException e) => switch (e) {
  SupaAuthException()       => 'Authentication failed. Please try again.',
  SupaDatabaseException()   => 'Something went wrong loading your data.',
  SupaStorageException()    => 'File operation failed.',
  SupaRealtimeException()   => 'Live updates unavailable.',
  SupaUnExpectedException() => 'An unexpected error occurred.',
};
```

---

## 🔁 Built-in Retry — production resilience for free

Mobile networks fail. Requests time out. Users lose signal mid-operation.

`supa_helper` ships with exponential backoff retry built into every service. Configure it globally, override per call when needed.

```dart
// Global — all DB calls retry up to 3 times automatically
postgrestOptions: PostgrestOptions(retryAttempts: 3),

// Per-call override — this one retries 5 times
final orders = await db.GET(table: 'orders', retryAttempt: 5);

// Zero retries for this critical path
await auth.signOut(0);
```

Delays follow exponential backoff — 1s, 2s, 4s, 8s — capped at 30s. Every retry is logged in debug mode. You see exactly what's happening, always.

---

## 🧹 Reset — multi-tenant and testing ready

Need to switch Supabase projects? Running integration tests?

```dart
SupaHelper.instance.reset();

await SupaHelper.instance.init(url: 'NEW_URL', anonKey: 'NEW_KEY');
```

---

## 📊 Raw `supabase_flutter` vs `supa_helper`

| | Raw `supabase_flutter` | `supa_helper` |
|---|---|---|
| **Error types** | 3 unrelated exceptions | 1 sealed hierarchy, always consistent |
| **Retry logic** | You write it every time | Built-in, configurable, exponential backoff |
| **Pagination** | Manual range + count + math | `GET_PAGINATED` returns `SupaPage<T>` |
| **Upload + URL** | 2 separate calls + manual path | `uploadAndGetUrl` — one call |
| **Type mapping** | Manual `.map()` everywhere | `mapper` param on every DB method |
| **Auth listener** | Manual switch, manual cancel | `setupAuthListener` with typed callbacks |
| **Channel cleanup** | Manual reference + manual remove | Named channels, `unsubscribe('name')` |
| **Social auth** | Custom per-provider logic | Implement `SupaSocialMediaAuth` once |
| **New dev ramp-up** | Hours of reading docs | Minutes |

---

## 📦 Installation

```yaml
dependencies:
  supa_helper: ^latest
```

```bash
flutter pub get
```

---

## 🤝 Contributing

Found something missing? Have a production use case that isn't covered?

Open an issue or submit a PR on [GitHub](https://github.com/Abdelrahmanyehia9/supa_helper). This package is built for the Flutter community and shaped by real-world usage.

---

## 📄 License

MIT © [Abdelrahman Yehia](https://github.com/Abdelrahmanyehia9)

---

<div align="center">

**If `supa_helper` saved you time, give it a ⭐ on [GitHub](https://github.com/Abdelrahmanyehia9/supa_helper) and a 👍 on [pub.dev](https://pub.dev/packages/supa_helper).**

*The best infrastructure code is the code you never had to write.*

</div>