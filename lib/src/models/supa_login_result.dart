
/// this is result model of login specialy for social media providers
/// this model is used to return id token and raw data from social media providers
class SocialAuthResult {
  final String? accessToken;
  final String idToken;
  final String? email;
  final String? displayName;

  SocialAuthResult({
    this.accessToken,
   required this.idToken,
    this.email,
    this.displayName,
  });
}

