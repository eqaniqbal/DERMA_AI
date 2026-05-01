import 'package:flutter_test/flutter_test.dart';
import 'package:derma_ai/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const DermaAIApp());
    expect(find.byType(DermaAIApp), findsOneWidget);
  });
}