import 'package:termio/termio.dart';
import 'package:test/test.dart';

void main() {
  group('Keys tests', () {
    test('basic keys', () {
      expect(Keys.escape, '\x1b');
      expect(Keys.backspace, '\x7f');
      expect(Keys.tab, '\t');
      expect(Keys.newline, '\n');
    });

    test('arrow keys', () {
      expect(Keys.arrowUp, '\x1b[A');
      expect(Keys.arrowDown, '\x1b[B');
      expect(Keys.arrowRight, '\x1b[C');
      expect(Keys.arrowLeft, '\x1b[D');
    });

    test('ctrl keys', () {
      expect(Keys.ctrlC, '\x03');
      expect(Keys.ctrlD, '\x04');
    });
  });
}
