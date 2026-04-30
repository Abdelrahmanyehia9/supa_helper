import 'package:supa_helper/src/models/supa_login_result.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class SupaSocialMediaAuth<T> {

  /// login and return id token
  Future<SupaAuthResult<T>> signIn();
  /// oAuth provider
  OAuthProvider get oAuthProvider;

}