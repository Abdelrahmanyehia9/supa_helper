import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:supa_helper/src/service/authentication/supa_auth_social_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../errors/supa_exception.dart';
import 'supa_auth_mobile.dart';

/// Handles all authentication operations with Supabase.
final class SupaAuth {
  final GoTrueClient _client;
  SupaAuth(this._client);

  /// Access phone/OTP authentication methods.
  SupaAuthMobileAuthHelper get phoneProvider => SupaAuthMobileAuthHelper(_client);

  /// Signs in a user with [email] and [password].
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _client.signInWithPassword(password: password, email: email);
    } on AuthException catch (e) {
      throw SupaAuthException(e.message);
    } catch (e) {
      throw SupaAuthException(e.toString());
    }
  }

  /// Creates a new user with [email] and [password].
  /// [metaData] is saved in `auth.users.raw_user_meta_data`.
  Future<AuthResponse> createUser({
    required String email,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? metaData,
  }) async {
    try {
      return await _client.signUp(password: password, email: email, data: metaData);
    } on AuthException catch (e) {
      throw SupaAuthException(e.message);
    } catch (e) {
      throw SupaAuthException(e.toString());
    }
  }

  /// Sends a password reset email to [email].
  /// [redirect] is the URL to redirect to after reset.
  Future<void> sendForgetPasswordEmail({
    required String email,
    String? redirect,
  }) async {
    try {
      await _client.resetPasswordForEmail(email, redirectTo: redirect);
    } on AuthException catch (e) {
      throw SupaAuthException(e.message);
    } catch (e) {
      throw SupaAuthException(e.toString());
    }
  }

  /// Updates the current user's [email], [password], or [data].
  Future<void> updateUser({
    String? password,
    String? email,
    Object? data,
  }) async {
    try {
      await _client.updateUser(UserAttributes(password: password, email: email, data: data));
    } on AuthException catch (e) {
      throw SupaAuthException(e.message);
    } catch (e) {
      throw SupaAuthException(e.toString());
    }
  }

  /// Signs in using a social media [provider] (e.g. Google, Facebook).
  /// [onSuccess] returns the raw data from the provider typed as [T].
  /// [T] can be -- `AuthorizationCredentialAppleID` for Apple, `GoogleSignInAuthentication` for Google, `LoginResult` for Facebook
  Future<AuthResponse> socialMediaSignIn<T>(
      SupaSocialMediaAuth provider,
      ValueChanged<T>? onSuccess,
      ) async {
    try {
      final response = await provider.signIn();
      final result = await _client.signInWithIdToken(
        idToken: response.idToken,
        provider: provider.oAuthProvider,
      );
      if (result.session != null) onSuccess?.call(response.rawData);
      return result;
    } on AuthException catch (e) {
      throw SupaAuthException(e.message);
    } catch (e) {
      throw SupaAuthException(e.toString());
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
    Function(SupaAuthException)? onError,
  }) =>
      _client.onAuthStateChange.listen(
            (data) async {
          final event = data.event;
          final session = data.session;
          switch (event) {
          // User just signed in (email, social, OTP, etc.)
            case AuthChangeEvent.signedIn:
              if (session == null) break ;
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
        },
          onError: (err) {
          onError?.call(SupaAuthException(err.toString()));
        },
      );
  bool get isAuthenticated => _client.currentUser != null;
  User? get user => _client.currentUser;
  String? get uID => user?.id;

  Future<void> signOut() => _client.signOut();

}