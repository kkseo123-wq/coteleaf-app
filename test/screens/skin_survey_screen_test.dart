import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:coteleaf/screens/skin_survey_screen.dart';

void main() {
  group('SkinSurveyScreen', () {
    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: SkinSurveyScreen(),
      );
    }

    testWidgets('설문 화면이 올바르게 렌더링되어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('피부 설문'), findsOneWidget);
      expect(find.text('1 / 7'), findsOneWidget);
    });

    testWidgets('첫 번째 섹션에 기본정보가 표시되어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('기본정보'), findsOneWidget);
      expect(find.text('개인정보 수집 동의'), findsOneWidget);
      expect(find.text('성별'), findsOneWidget);
      expect(find.text('연령대'), findsOneWidget);
      expect(find.text('피부타입'), findsOneWidget);
    });

    testWidgets('성별 옵션에 남성, 여성만 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('남성'), findsOneWidget);
      expect(find.text('여성'), findsOneWidget);
    });

    testWidgets('피부타입 옵션이 표시되어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 스크롤해서 피부타입 옵션 보이게
      await tester.scrollUntilVisible(find.text('건성'), 100);

      expect(find.text('건성'), findsOneWidget);
      expect(find.text('지성'), findsOneWidget);
      expect(find.text('복합성'), findsOneWidget);
      expect(find.text('민감성'), findsOneWidget);
    });

    testWidgets('다음 버튼이 표시되어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('다음'), findsOneWidget);
    });

    testWidgets('다음 버튼 클릭 시 다음 섹션으로 이동해야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();

      expect(find.text('2 / 7'), findsOneWidget);
    });

    testWidgets('이전 버튼 클릭 시 이전 섹션으로 이동해야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 다음으로 이동
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
      expect(find.text('2 / 7'), findsOneWidget);

      // 이전으로 이동
      await tester.tap(find.text('이전'));
      await tester.pumpAndSettle();
      expect(find.text('1 / 7'), findsOneWidget);
    });

    testWidgets('개인정보 동의를 선택할 수 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('동의합니다'));
      await tester.pump();

      final radioTile = tester.widget<RadioListTile<bool>>(
        find.widgetWithText(RadioListTile<bool>, '동의합니다'),
      );
      expect(radioTile.value, isTrue);
    });

    testWidgets('7개의 섹션을 모두 탐색할 수 있어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 1 -> 7까지 이동
      for (int i = 1; i <= 6; i++) {
        expect(find.text('$i / 7'), findsOneWidget);
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }
      expect(find.text('7 / 7'), findsOneWidget);
    });

    testWidgets('마지막 섹션에 제출 버튼이 표시되어야 한다', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // 마지막 섹션으로 이동
      for (int i = 0; i < 6; i++) {
        await tester.tap(find.text('다음'));
        await tester.pumpAndSettle();
      }

      expect(find.text('제출'), findsOneWidget);
    });
  });
}
