import 'package:flutter_test/flutter_test.dart';
import 'package:offline_pdf_tool/src/app/offline_pdf_app.dart';

void main() {
  testWidgets('App loads dashboard shell', (WidgetTester tester) async {
    await tester.pumpWidget(const OfflinePdfApp());
    await tester.pumpAndSettle();

    expect(find.text('Offline PDF Tool'), findsOneWidget);
    expect(find.text('PDF Tools'), findsOneWidget);
    expect(find.text('Convert'), findsOneWidget);
    expect(find.text('Queue'), findsNothing);
  });
}
