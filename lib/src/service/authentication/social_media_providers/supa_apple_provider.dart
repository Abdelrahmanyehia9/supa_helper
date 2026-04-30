import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supa_helper/src/errors/supa_exception.dart';
import 'package:supa_helper/src/service/authentication/supa_auth_social_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/supa_login_result.dart';

class SupaAppleProvider
    implements SupaSocialMediaAuth<AuthorizationCredentialAppleID> {
  final List<AppleIDAuthorizationScopes> scopes;
  final WebAuthenticationOptions? webAuthenticationOptions;
  final String? nonce;
  final String? state;

  SupaAppleProvider({
    this.scopes = const [
      AppleIDAuthorizationScopes.email,
      AppleIDAuthorizationScopes.fullName,
    ],
    this.webAuthenticationOptions,
    this.nonce,
    this.state,
  });

  @override
  OAuthProvider get oAuthProvider => OAuthProvider.apple;

  @override
  Future<SupaAuthResult<AuthorizationCredentialAppleID>> signIn() async {
    try {
      {
        final cred = await SignInWithApple.getAppleIDCredential(
          scopes: scopes,
          nonce: nonce,
          state: state,
          webAuthenticationOptions: webAuthenticationOptions,
        );
        if (cred.identityToken != null) {
          return SupaAuthResult<AuthorizationCredentialAppleID>(
            idToken: cred.identityToken!,
            rawData: cred,
          );
        } else {
          throw SupaAuthException('No id token found');
        }
      }
    } catch (e) {
      throw SupaAuthException(e.toString());
    }
  }
}
