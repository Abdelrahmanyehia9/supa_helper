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
}