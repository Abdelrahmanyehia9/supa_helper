import 'package:supa_helper/supa_helper.dart';

import 'supa_auth_mobile.dart';

/// Handles all authentication operations with Supabase.
abstract class SupabaseAuth{
  /// Access phone/OTP authentication methods.
  SupaAuthMobileAuthHelper get phoneProvider ;
  /// Signs in a user with [email] and [password].
  Future<AuthResponse> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  /// Creates a new user with [email] and [password].
  /// [metaData] is saved in `auth.users.raw_user_meta_data`.
  Future<AuthResponse> createUser({
    required String email,
    required String password,
    String? emailRedirectTo,
    Map<String, dynamic>? metaData,
  }) ;
  /// Sends a password reset email to [email].
  /// [redirect] is the URL to redirect to after reset.
  Future<void> sendForgetPasswordEmail({
    required String email,
    String? redirect,
  }) ;
  /// Updates the current user's [email], [password], or [data].
  Future<void> updateUser({
    String? password,
    String? email,
    Object? data,
  }) ;
  /// Signs in using a social media [provider] (e.g. Google, Facebook).
  /// [onSuccess] returns the raw data from the provider typed as [T].
  /// [T] can be -- `AuthorizationCredentialAppleID` for Apple, `GoogleSignInAuthentication` for Google, `LoginResult` for Facebook
  Future<AuthResponse> socialMediaSignIn(
      SupaSocialMediaAuth provider,
     void Function(SocialAuthResult)? onSuccess,
      );

}