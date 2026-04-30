import 'package:google_sign_in/google_sign_in.dart';
import 'package:supa_helper/src/errors/supa_exception.dart';
import 'package:supa_helper/src/service/authentication/supa_auth_social_media.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../models/supa_login_result.dart';

class SupaGoogleProvider implements SupaSocialMediaAuth<GoogleSignInAuthentication> {
  final String? clientId ;
  final String? serverClientId ;
  final String? nonce ;
   final String? hostedDomain ;
   final List<String>scopes ;
   SupaGoogleProvider({this.clientId, this.scopes = const ['email', 'profile'],this.hostedDomain, this.nonce, this.serverClientId}){
     init() ;
   }

   Future<void>init()async{
    await GoogleSignIn.instance.initialize(
       clientId: clientId,
       hostedDomain: hostedDomain,
       nonce: nonce,
       serverClientId: serverClientId,
     ) ;
   }

   @override
  Future<SupaAuthResult<GoogleSignInAuthentication>> signIn() async{
try{
  final GoogleSignIn google = GoogleSignIn.instance ;
  final googleUser = await google.authenticate(scopeHint: scopes);
  final googleAuth = googleUser.authentication;
  final idToken = googleAuth.idToken;
  if (idToken == null) {
    throw SupaAuthException('No id token found');
  }
  return SupaAuthResult<GoogleSignInAuthentication>(idToken: idToken, rawData: googleAuth);
}on GoogleSignInException catch (e){
  throw SupaAuthException(e.code.name);
} catch(e){
  throw SupaAuthException(e.toString());
}
  }

  @override
  OAuthProvider get oAuthProvider => OAuthProvider.google;
}