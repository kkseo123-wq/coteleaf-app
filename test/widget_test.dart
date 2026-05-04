import 'package:flutter_test/flutter_test.dart';
import 'package:coteleaf/main.dart';

void main() {
  testWidgets('앱이 올바르게 시작되어야 한다', (WidgetTester tester) async {
    await tester.pumpWidget(const CoteleafApp());

    // 앱이 로드될 때까지 대기
    await tester.pump();

    // 앱이 정상적으로 렌더링되는지 확인
    expect(find.byType(CoteleafApp), findsOneWidget);
  });
}
