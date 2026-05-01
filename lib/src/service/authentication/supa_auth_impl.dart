import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:supa_helper/src/errors/handle_error.dart';
import 'package:supa_helper/src/service/authentication/supa_auth.dart';
import 'package:supa_helper/src/service/authentication/supa_auth_mobile.dart';
import 'package:supa_helper/src/service/authentication/supa_auth_social_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supa_helper/src/errors/supa_exception.dart';
import 'package:supa_helper/src/models/supa_login_result.dart';

final class SupaAuthImpl implements SupabaseAuth {
  final GoTrueClient _client;

  const SupaAuthImpl(this._client);

  @override
  SupaAuthMobileAuthHelper get phoneProvider => SupaAuthMobileAuthHelper(_client);

  /// Signs in a user with [email] and [password].
  @override
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.signInWithPassword(password: password, email: email);
    } catch (e) {
       e.handleError();
    }
  }


  @override
  Future<AuthResponse> createUser({
    required String email,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? metaData,
  }) async {
    try {
      return await _client.signUp(
        password: password,
        email: email,
        data: metaData,
      );
    } catch (e) {
       e.handleError();
    }
  }


  @override
  Future<void> sendForgetPasswordEmail({
    required String email,
    String? redirect,
  }) async {
    try {
      await _client.resetPasswordForEmail(email, redirectTo: redirect);
    } catch (e) {
      e.handleError();
    }
  }

  @override
  Future<void> updateUser({
    String? password,
    String? email,
    Object? data,
  }) async {
    try {
      await _client.updateUser(
        UserAttributes(password: password, email: email, data: data),
      );
    } catch (e) {
       e.handleError();
    }
  }

  @override
  Future<AuthResponse> socialMediaSignIn(
    SupaSocialMediaAuth provider,
    ValueChanged<SocialAuthResult>? onSuccess,
  ) async {
    try {
      final response = await provider.signIn();
      final result = await _client.signInWithIdToken(
        idToken: response.idToken,
        provider: provider.oAuthProvider,
      );
      if (result.session != null) onSuccess?.call(response);
      return result;
    } catch (e) {
       e.handleError();
    }
  }

  /// Sets up a listener for Supabase authentication state changes.
  ///
  /// Returns a [StreamSubscription] — call `.cancel()` when no longer needed
  /// Required callbacks:
  /// - [onSignedIn] — called when a user signs in. Provides the user [id].
  /// - [onSignedOut] — called when the user signs out or the session expires.
  /// - [onUserUpdated] — called when user data (email/password/metadata) is updated. Provides the user [id].
  /// Optional callbacks:
  /// - [onInitialSession] — called on app launch if a valid session already exists.
  /// - [onTokenRefreshed] — called when the access token is silently refreshed.
  /// - [onFirstTimeJoin] — reserved for new user registration flow (handle externally).
  /// - [onError] — called on unrecoverable auth errors with a [SupaAuthException].
  StreamSubscription<AuthState> setupAuthListener({
    required Function(String id) onSignedIn,
    required Function() onSignedOut,
    required Function(String id) onUserUpdated,
    Function()? onInitialSession,
    Function()? onTokenRefreshed,
  }) => _client.onAuthStateChange.listen((data) async {
    final event = data.event;
    final session = data.session;
    switch (event) {
      // User just signed in (email, social, OTP, etc.)
      case AuthChangeEvent.signedIn:
        if (session == null) break;
        onSignedIn.call(session.user.id);
        break;
      // Access token was silently refreshed in the background
      case AuthChangeEvent.tokenRefreshed:
        onTokenRefreshed?.call();
        break;

      // App launched and found an existing valid session
      case AuthChangeEvent.initialSession:
        if (session != null) onInitialSession?.call();
        break;
      // User signed out or session was invalidated
      case AuthChangeEvent.signedOut:
        onSignedOut.call();
        break;
      // User updated their email, password, or metadata
      case AuthChangeEvent.userUpdated:
        if (session == null) break;
        onUserUpdated.call(session.user.id);
        break;

      default:
        debugPrint("Unhandled auth event: $event");
    }
  });
  bool get isAuthenticated => _client.currentUser != null;
  User? get user => _client.currentUser;
  String? get uID => user?.id;
  Future<void> signOut() => _client.signOut();
}
