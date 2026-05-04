import 'package:flutter_test/flutter_test.dart';
import 'package:coteleaf/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
      authService.logout(); // 각 테스트 전 로그아웃 상태로 초기화
    });

    group('login', () {
      test('올바른 이메일과 비밀번호로 로그인 성공해야 한다', () async {
        final result = await authService.login('test@example.com', '1234');

        expect(result.success, isTrue);
        expect(result.message, equals('로그인 성공!'));
        expect(authService.isLoggedIn, isTrue);
        expect(authService.currentUserEmail, equals('test@example.com'));
      });

      test('잘못된 비밀번호로 로그인 실패해야 한다', () async {
        final result = await authService.login('test@example.com', 'wrong');

        expect(result.success, isFalse);
        expect(result.message, equals('이메일 또는 비밀번호가 올바르지 않습니다.'));
        expect(authService.isLoggedIn, isFalse);
      });

      test('존재하지 않는 이메일로 로그인 실패해야 한다', () async {
        final result = await authService.login('unknown@example.com', '1234');

        expect(result.success, isFalse);
        expect(result.message, equals('이메일 또는 비밀번호가 올바르지 않습니다.'));
      });

      test('빈 이메일로 로그인 실패해야 한다', () async {
        final result = await authService.login('', '1234');

        expect(result.success, isFalse);
        expect(result.message, equals('이메일과 비밀번호를 입력해주세요.'));
      });

      test('빈 비밀번호로 로그인 실패해야 한다', () async {
        final result = await authService.login('test@example.com', '');

        expect(result.success, isFalse);
        expect(result.message, equals('이메일과 비밀번호를 입력해주세요.'));
      });

      test('잘못된 이메일 형식으로 로그인 실패해야 한다', () async {
        final result = await authService.login('invalid-email', '1234');

        expect(result.success, isFalse);
        expect(result.message, equals('올바른 이메일 형식이 아닙니다.'));
      });

      test('모든 더미 계정으로 로그인 가능해야 한다', () async {
        final accounts = {
          'test@example.com': '1234',
          'user@coteleaf.com': 'password',
          'admin@coteleaf.com': 'admin123',
        };

        for (final entry in accounts.entries) {
          authService.logout();
          final result = await authService.login(entry.key, entry.value);
          expect(result.success, isTrue, reason: '${entry.key} 로그인 실패');
        }
      });
    });

    group('register', () {
      test('새 이메일로 회원가입 성공해야 한다', () async {
        final result = await authService.register('new@example.com', 'password123');

        expect(result.success, isTrue);
        expect(result.message, equals('회원가입 성공!'));
        expect(authService.isLoggedIn, isTrue);
        expect(authService.currentUserEmail, equals('new@example.com'));
      });

      test('이미 등록된 이메일로 회원가입 실패해야 한다', () async {
        final result = await authService.register('test@example.com', 'newpass');

        expect(result.success, isFalse);
        expect(result.message, equals('이미 등록된 이메일입니다.'));
      });

      test('빈 이메일로 회원가입 실패해야 한다', () async {
        final result = await authService.register('', 'password');

        expect(result.success, isFalse);
        expect(result.message, equals('이메일과 비밀번호를 입력해주세요.'));
      });

      test('빈 비밀번호로 회원가입 실패해야 한다', () async {
        final result = await authService.register('new@example.com', '');

        expect(result.success, isFalse);
        expect(result.message, equals('이메일과 비밀번호를 입력해주세요.'));
      });

      test('잘못된 이메일 형식으로 회원가입 실패해야 한다', () async {
        final result = await authService.register('invalid-email', 'password');

        expect(result.success, isFalse);
        expect(result.message, equals('올바른 이메일 형식이 아닙니다.'));
      });

      test('4자 미만 비밀번호로 회원가입 실패해야 한다', () async {
        final result = await authService.register('new@example.com', '123');

        expect(result.success, isFalse);
        expect(result.message, equals('비밀번호는 4자 이상이어야 합니다.'));
      });
    });

    group('logout', () {
      test('로그아웃 시 상태가 초기화되어야 한다', () async {
        await authService.login('test@example.com', '1234');
        expect(authService.isLoggedIn, isTrue);

        authService.logout();

        expect(authService.isLoggedIn, isFalse);
        expect(authService.currentUserEmail, isNull);
      });
    });

    group('singleton', () {
      test('AuthService는 싱글톤이어야 한다', () {
        final service1 = AuthService();
        final service2 = AuthService();

        expect(identical(service1, service2), isTrue);
      });
    });
  });
}
