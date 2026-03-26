import 'package:flutter_test/flutter_test.dart';

import 'package:pcs_app/main.dart';

void main() {
  testWidgets('App renders Hello Guys screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PCSApp());

    // Verify the Hindi title is displayed
    expect(find.text('नमस्ते दोस्तों'), findsOneWidget);

    // Verify the tap button text is displayed
    expect(find.text('🙏 यहाँ दबाएँ'), findsOneWidget);
  });
}
