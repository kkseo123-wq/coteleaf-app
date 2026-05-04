import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _supabaseUrl = 'https://xogphoxosyzaunmwnhgb.supabase.co';
  static const String _apiKey = 'sb_publishable_T34yzYoDl8Dskz792U71TA_eWrReVjA';

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userEmailKey = 'user_email';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  String? _currentUserEmail;
  String? _accessToken;
  String? _refreshToken;
  bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
  String? get currentUserEmail => _currentUserEmail;
  String? get accessToken => _accessToken;

  Map<String, String> get _headers => {
        'apikey': _apiKey,
        'Content-Type': 'application/json',
      };

  Map<String, String> get authHeaders => {
        'apikey': _apiKey,
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_accessToken',
      };

  /// 앱 시작 시 저장된 토큰 확인 및 인증 상태 반환
  Future<AuthStatus> checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessTokenKey);
    _refreshToken = prefs.getString(_refreshTokenKey);
    _currentUserEmail = prefs.getString(_userEmailKey);

    // 토큰이 없으면 새 사용자 (회원가입 필요)
    if (_accessToken == null || _accessToken!.isEmpty) {
      return AuthStatus.noToken;
    }

    // 토큰 만료 확인
    if (_isTokenExpired(_accessToken!)) {
      // 리프레시 토큰으로 갱신 시도
      final refreshed = await _refreshAccessToken();
      if (refreshed) {
        _isLoggedIn = true;
        return AuthStatus.authenticated;
      } else {
        // 갱신 실패 - 로그인 필요
        await _clearTokens();
        return AuthStatus.tokenExpired;
      }
    }

    _isLoggedIn = true;
    return AuthStatus.authenticated;
  }

  /// JWT 토큰 만료 확인
  bool _isTokenExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final data = jsonDecode(decoded);

      final exp = data['exp'] as int?;
      if (exp == null) return true;

      final expDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expDate);
    } catch (e) {
      return true;
    }
  }

  /// 리프레시 토큰으로 액세스 토큰 갱신
  Future<bool> _refreshAccessToken() async {
    if (_refreshToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=refresh_token'),
        headers: _headers,
        body: jsonEncode({
          'refresh_token': _refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        await _saveTokens();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 토큰 저장
  Future<void> _saveTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString(_accessTokenKey, _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString(_refreshTokenKey, _refreshToken!);
    }
    if (_currentUserEmail != null) {
      await prefs.setString(_userEmailKey, _currentUserEmail!);
    }
  }

  /// 토큰 삭제
  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_refreshTokenKey);
    await prefs.remove(_userEmailKey);
    _accessToken = null;
    _refreshToken = null;
    _currentUserEmail = null;
    _isLoggedIn = false;
  }

  /// 온보딩 완료 여부 확인
  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  /// 온보딩 완료 저장
  Future<void> setOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, true);
  }

  Future<AuthResult> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult(success: false, message: '이메일과 비밀번호를 입력해주세요.');
    }

    if (!_isValidEmail(email)) {
      return AuthResult(success: false, message: '올바른 이메일 형식이 아닙니다.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/token?grant_type=password'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _accessToken = data['access_token'];
        _refreshToken = data['refresh_token'];
        _currentUserEmail = data['user']['email'];
        _isLoggedIn = true;
        await _saveTokens();
        return AuthResult(success: true, message: '로그인 성공!', isNewUser: false);
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error_description'] ?? error['msg'] ?? '로그인에 실패했습니다.';
        return AuthResult(success: false, message: errorMessage);
      }
    } catch (e) {
      return AuthResult(success: false, message: '네트워크 오류가 발생했습니다: $e');
    }
  }

  Future<AuthResult> register(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult(success: false, message: '이메일과 비밀번호를 입력해주세요.');
    }

    if (!_isValidEmail(email)) {
      return AuthResult(success: false, message: '올바른 이메일 형식이 아닙니다.');
    }

    if (password.length < 6) {
      return AuthResult(success: false, message: '비밀번호는 6자 이상이어야 합니다.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/signup'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Supabase는 이메일 확인이 필요할 수 있음
        if (data['access_token'] != null) {
          _accessToken = data['access_token'];
          _refreshToken = data['refresh_token'];
          _currentUserEmail = data['user']['email'];
          _isLoggedIn = true;
          await _saveTokens();
          return AuthResult(success: true, message: '회원가입 성공!', isNewUser: true);
        } else {
          // 이메일 확인이 필요한 경우
          return AuthResult(
            success: true,
            message: '회원가입 완료! 이메일을 확인해주세요.',
            isNewUser: true,
            requiresEmailVerification: true,
          );
        }
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error_description'] ?? error['msg'] ?? '회원가입에 실패했습니다.';
        return AuthResult(success: false, message: errorMessage);
      }
    } catch (e) {
      return AuthResult(success: false, message: '네트워크 오류가 발생했습니다: $e');
    }
  }

  Future<void> logout() async {
    await _clearTokens();
  }

  /// 비밀번호 재설정 이메일 발송
  Future<AuthResult> resetPassword(String email) async {
    if (email.isEmpty) {
      return AuthResult(success: false, message: '이메일을 입력해주세요.');
    }

    if (!_isValidEmail(email)) {
      return AuthResult(success: false, message: '올바른 이메일 형식이 아닙니다.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_supabaseUrl/auth/v1/recover'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
        }),
      );

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: '비밀번호 재설정 링크가 이메일로 발송되었습니다.',
        );
      } else {
        final error = jsonDecode(response.body);
        final errorMessage = error['error_description'] ?? error['msg'] ?? '이메일 발송에 실패했습니다.';
        return AuthResult(success: false, message: errorMessage);
      }
    } catch (e) {
      return AuthResult(success: false, message: '네트워크 오류가 발생했습니다: $e');
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

enum AuthStatus {
  noToken,       // 토큰 없음 - 회원가입 필요
  tokenExpired,  // 토큰 만료 - 로그인 필요
  authenticated, // 인증됨
}

class AuthResult {
  final bool success;
  final String message;
  final bool isNewUser;
  final bool requiresEmailVerification;

  AuthResult({
    required this.success,
    required this.message,
    this.isNewUser = false,
    this.requiresEmailVerification = false,
  });
}
