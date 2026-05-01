import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supa_helper/src/models/supa_login_result.dart';

/// to Add new Social Media Provider
/// implement [SupaSocialMediaAuth]
abstract class SupaSocialMediaAuth{
  /// login and return id token
  Future<SocialAuthResult> signIn();
  /// oAuth provider
  OAuthProvider get oAuthProvider;
}
