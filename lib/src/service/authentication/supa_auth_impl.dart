import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:supa_helper/src/service/authentication/supa_auth.dart';
import 'package:supa_helper/src/service/authentication/supa_auth_mobile.dart';
import 'package:supa_helper/src/service/authentication/supa_auth_social_media.dart';
import 'package:supa_helper/src/helpers/retry_option.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supa_helper/src/models/supa_login_result.dart';

final class SupaAuthImpl implements SupabaseAuth {
  final GoTrueClient _client;
  final RetryOption retryOption;

  const SupaAuthImpl(this._client, {required this.retryOption});

  @override
  SupaAuthMobileAuthHelper get phoneProvider =>
      SupaAuthMobileAuthHelper(_client, retryOption);

  /// Signs in a user with [email] and [password].
  @override
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<AuthResponse>(retries: retryAttempt, () async {
      return await _client.signInWithPassword(password: password, email: email);
    });
  }

  @override
  Future<AuthResponse> createUser({
    required String email,
    required String password,
    String? emailRedirectTo,
    int? retryAttempt,
    Map<String, dynamic>? metaData,
  }) async {
    return retryOption.withRetry<AuthResponse>(retries: retryAttempt, () async {
      return _client.signUp(password: password, email: email, data: metaData);
    });
  }

  @override
  Future<void> sendForgetPasswordEmail({
    required String email,
    String? redirect,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<void>(retries: retryAttempt, () async {
      return await _client.resetPasswordForEmail(email, redirectTo: redirect);
    });
  }

  @override
  Future<void> updateUser({
    String? password,
    String? email,
    Object? data,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<void>(retries: retryAttempt, () async {
      await _client.updateUser(
        UserAttributes(password: password, email: email, data: data),
      );
    });
  }

  @override
  Future<AuthResponse> socialMediaSignIn(
    SupaSocialMediaAuth provider,
    ValueChanged<SocialAuthResult>? onSuccess, {
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<AuthResponse>(retries: retryAttempt, () async {
      final response = await provider.signIn();
      final result = await _client.signInWithIdToken(
        idToken: response.idToken,
        provider: provider.oAuthProvider,
      );
      if (result.session != null) onSuccess?.call(response);
      return result;
    });
  }

  @override
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

  @override
  Future<void> signOut({int? retryAttempt}) {
    return retryOption.withRetry<void>(retries: retryAttempt, () async {
      return await _client.signOut();
    });
  }

  @override
  Future<void> reAuthenticate({int? retryAttempt}) {
    return retryOption.withRetry<void>(retries: retryAttempt, () async {
      return await _client.reauthenticate();
    });



  }

  @override
  Future<AuthResponse> refreshSession([int? retryAttempt]) {
    return retryOption.withRetry<AuthResponse>(retries: retryAttempt, () async {
      return await _client.refreshSession();
    });
  }


  @override
  Future<bool> signInWithOAuth(
    OAuthProvider provider, {
    String? redirectTo,
    String? scopes,
    LaunchMode launchMode = LaunchMode.platformDefault,
    Map<String, String>? queryParams,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry(() async {
      return await _client.signInWithOAuth(
        provider,
        scopes: scopes,
        redirectTo: redirectTo,
        authScreenLaunchMode: launchMode,
        queryParams: queryParams,
      );
    }, retries: retryAttempt);
  }

  @override
  Future<bool> signInWithSSO({
    String? providerId,
    String? domain,
    String? redirectTo,
    String? captchaToken,
    LaunchMode launchMode = LaunchMode.platformDefault,
    int? retryAttempt,
  }) async {
    return retryOption.withRetry<bool>(retries: retryAttempt, () async {
      return await _client.signInWithSSO(
        redirectTo: redirectTo,
        domain: domain,
        providerId: providerId,
        captchaToken: captchaToken,
        launchMode: launchMode,
      );
    });
  }

  @override
  Future<AuthResponse>signInAnonymously({Map<String, dynamic>? data, String? captchaToken, int? retryAttempt}) {
    return retryOption.withRetry<AuthResponse>(retries: retryAttempt, () async {
      return await _client.signInAnonymously(
        data: data,
        captchaToken: captchaToken,
      );
    });
  }
}
