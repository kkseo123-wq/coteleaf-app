import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coteleaf/screens/login_screen.dart';

void main() {
  group('LoginScreen', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: LoginScreen(),
      );
    }

    testWidgets('로그인 화면이 올바르게 렌더링되어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('로그인'), findsWidgets);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('이메일 입력 필드가 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('email_field')), findsOneWidget);
    });

    testWidgets('비밀번호 입력 필드가 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byKey(const Key('password_field')), findsOneWidget);
    });

    testWidgets('이메일을 입력할 수 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.byKey(const Key('email_field')),
        'test@example.com',
      );
      await tester.pump();

      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('비밀번호를 입력할 수 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
        find.byKey(const Key('password_field')),
        '1234',
      );
      await tester.pump();

      expect(find.text('1234'), findsOneWidget);
    });

    testWidgets('로그인 버튼이 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.widgetWithText(ElevatedButton, '로그인'), findsOneWidget);
    });

    testWidgets('회원가입 버튼이 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('회원가입'), findsOneWidget);
    });

    testWidgets('테스트 계정 정보가 표시되어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.textContaining('test@example.com'), findsOneWidget);
    });
  });
}
