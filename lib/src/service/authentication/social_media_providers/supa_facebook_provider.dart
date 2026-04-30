import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supa_helper/src/errors/supa_exception.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../models/supa_login_result.dart';
import '../supa_auth_social_media.dart';

///using config first read https://facebook.meedu.app/docs/7.x.x/intro/
class SupaFacebookProvider implements SupaSocialMediaAuth<LoginResult> {
  final List<String> scopes;
  final LoginBehavior loginBehavior;
  final LoginTracking loginTracking;
  final String? nonce;

  const SupaFacebookProvider({
    this.loginBehavior = LoginBehavior.nativeWithFallback,
    this.loginTracking = LoginTracking.limited,
    this.nonce,
    this.scopes = const ['email', 'public_profile'],
  });

  @override
  Future<SupaAuthResult<LoginResult>> signIn() async {
try{
  final result = await FacebookAuth.instance.login(
    permissions: scopes,
    loginBehavior: loginBehavior,
    loginTracking: loginTracking,
    nonce: nonce,
  );
  // if login failed throw error
  if (result.status == LoginStatus.success && result.accessToken != null) {
    return SupaAuthResult<LoginResult>(idToken: result.accessToken!.tokenString, rawData: result);
  } else {
    throw SupaAuthException('No id token found');
  }
}
catch(e){
  throw SupaAuthException(e.toString());
}
  }

  @override
  OAuthProvider get oAuthProvider => OAuthProvider.facebook;
}
