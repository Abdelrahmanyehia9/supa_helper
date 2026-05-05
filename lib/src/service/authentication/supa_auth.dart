import 'dart:async';

import 'package:supa_helper/src/service/authentication/supa_auth_mobile.dart';
import 'package:supa_helper/supa_helper.dart';


/// Handles all authentication operations with Supabase.
abstract class SupabaseAuth{
  /// Access phone/OTP authentication methods.
  SupaAuthMobileAuthHelper get phoneProvider ;
  /// Signs in a user with [email] and [password].
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
    int? retryAttempt,
  });
  /// Creates a new user with [email] and [password].
  /// [metaData] is saved in `auth.users.raw_user_meta_data`.
  Future<AuthResponse> createUser({
    required String email,
    required String password,
    String? emailRedirectTo,
    int? retryAttempt ,
    Map<String, dynamic>? metaData,
  }) ;
  /// Sends a password reset email to [email].
  /// [redirect] is the URL to redirect to after reset.
  Future<void> sendForgetPasswordEmail({
    required String email,
    String? redirect,
    int? retryAttempt
  }) ;
  /// Updates the current user's [email], [password], or [data].
  Future<void> updateUser({
    String? password,
    String? email,
    Object? data,
    int? retryAttempt
  }) ;



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
  });
  /// Signs in using a social media [provider] (e.g. Google, Facebook).
  /// [onSuccess] returns the raw data from the provider typed as [T].
  /// [T] can be -- `AuthorizationCredentialAppleID` for Apple, `GoogleSignInAuthentication` for Google, `LoginResult` for Facebook
  Future<AuthResponse> socialMediaSignIn(
      SupaSocialMediaAuth provider,
     void Function(SocialAuthResult)? onSuccess,
  {int? retryAttempt}
      );
  /// sign out the current user
  Future<void> signOut({int? retryAttempt})  ;
  /// re-authenticate the current user
  Future<void> reAuthenticate({int? retryAttempt}) ;
  /// refresh the current user's session
  Future<AuthResponse> refreshSession([int? retryAttempt]) ;
  /// Signs in a user using an OAuth provider (e.g. Google, GitHub, Apple).
  ///
  /// [provider] — the OAuth provider to use.
  /// [redirectTo] — the URL to redirect to after sign in. Defaults to the app's deep link.
  /// [scopes] — additional OAuth scopes to request (e.g. `'email profile'`).
  /// [launchMode] — how to open the OAuth URL. Defaults to [LaunchMode.platformDefault].
  /// [queryParams] — extra query parameters to pass to the OAuth provider.
  ///
  /// Returns `true` if the OAuth flow was launched successfully.
  ///
  /// Example:
  /// ```dart
  /// await SupaHelper.instance.auth.signInWithOAuth(
  ///   OAuthProvider.google,
  ///   redirectTo: 'io.myapp://login-callback',
  ///   scopes: 'email profile',
  /// );
  /// ```
  Future<bool> signInWithOAuth(
      OAuthProvider provider, {
        String? redirectTo,
        String? scopes,
        LaunchMode launchMode = LaunchMode.platformDefault,
        Map<String, String>? queryParams,
        int? retryAttempt,
      });

  /// Signs in a user using SSO (Single Sign-On).
  ///
  /// Either [providerId] or [domain] must be provided.
  /// [providerId] — the SSO provider ID configured in your Supabase dashboard.
  /// [domain] — the email domain used to identify the SSO provider (e.g. `'mycompany.com'`).
  /// [redirectTo] — the URL to redirect to after sign in.
  /// [captchaToken] — optional captcha token for bot protection.
  /// [launchMode] — how to open the SSO URL. Defaults to [LaunchMode.platformDefault].
  ///
  /// Returns `true` if the SSO flow was launched successfully.
  ///
  /// Example:
  /// ```dart
  /// await SupaHelper.instance.auth.signInWithSSO(
  ///   domain: 'mycompany.com',
  ///   redirectTo: 'io.myapp://login-callback',
  /// );
  /// ```
  Future<bool> signInWithSSO({
    String? providerId,
    String? domain,
    String? redirectTo,
    String? captchaToken,
    LaunchMode launchMode = LaunchMode.platformDefault,
    int? retryAttempt,
  });

  /// Signs in a user anonymously.
  /// [data] is saved in `auth.users.raw_user_meta_data`.
  /// [captchaToken] is used for bot protection.
  Future<AuthResponse>signInAnonymously({Map<String, dynamic>? data, String? captchaToken, int? retryAttempt}) ;
}