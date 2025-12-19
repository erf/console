import 'package:console/console.dart';
import 'package:test/test.dart';

void main() {
  group('console tests', () {
    setUp(() {});

    test('cursorPosition', () {
      expect(VT100.cursorPosition(y: 1, x: 2), '\x1b[1;2H');
    });

    test('cursorVisible', () {
      expect(VT100.cursorVisible(false), '\x1b[?25l');
    });

    test('erase', () {
      expect(VT100.homeAndErase(), '\x1b[H\x1b[J');
    });

    test('foreground', () {
      expect(VT100.foreground(1), '\x1b[38;5;1m');
    });

    test('background', () {
      expect(VT100.background(6), '\x1b[48;5;6m');
    });

    test('resetStyles', () {
      expect(VT100.resetStyles(), '\x1b[0m');
    });

    test('combine two VT100 commands', () {
      expect(
        VT100.foreground(1) + VT100.background(6),
        '\x1b[38;5;1m\x1b[48;5;6m',
      );
    });
  });
}
