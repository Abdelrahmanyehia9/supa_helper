import 'package:supa_helper/src/errors/handle_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaAuthMobileAuthHelper {
  final GoTrueClient _client;

  const SupaAuthMobileAuthHelper(this._client);

  /// send otp to phone number
  Future<void> sendOtp({
    String? phone,
    OtpChannel channel = OtpChannel.sms,
    Map<String, dynamic>? data,
    // if true will create new user if not exist
    bool createUser = true,
    String? captchaToken,
  }) async {
    try {
      await _client.signInWithOtp(
        phone: phone,
        channel: channel,
        data: data,
        shouldCreateUser: createUser,
        captchaToken: captchaToken,
      );
    } catch (e) {
       e.handleError();
    }
  }

  /// verify otp
  Future<AuthResponse> verifyOtp({
    required String phone,
    required String otp,
    OtpType type = OtpType.sms,
    String? captchaToken,
    String? tokenHash,
  }) async {
    try {
      return await _client.verifyOTP(
        phone: phone,
        token: otp,
        type: type,
        captchaToken: captchaToken,
        tokenHash: tokenHash,
      );
    } catch (e) {
       e.handleError();
    }
  }
}
