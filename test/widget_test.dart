import 'package:flutter_test/flutter_test.dart';
import 'package:app_secretaria/main.dart';

void main() {
  testWidgets('App basic smoke test', (WidgetTester tester) async {
    const app = MisericordiaMaternaApp();
    expect(app, isNotNull);
  });
}
