import 'package:termio/termio.dart';
import 'package:test/test.dart';

void main() {
  group('VT100 tests', () {
    test('escape constant', () {
      expect(VT100.e, '\x1b');
    });

    test('cursorPosition', () {
      expect(VT100.cursorPosition(y: 1, x: 2), '\x1b[1;2H');
    });

    test('cursorVisible', () {
      expect(VT100.cursorVisible(false), '\x1b[?25l');
      expect(VT100.cursorVisible(true), '\x1b[?25h');
    });

    test('homeAndErase', () {
      expect(VT100.homeAndErase(), '\x1b[H\x1b[J');
    });

    test('foreground', () {
      expect(VT100.foreground(1), '\x1b[38;5;1m');
    });

    test('background', () {
      expect(VT100.background(6), '\x1b[48;5;6m');
    });

    test('bold', () {
      expect(VT100.bold(), '\x1b[1m');
    });

    test('underline', () {
      expect(VT100.underline(), '\x1b[4m');
    });

    test('resetStyles', () {
      expect(VT100.resetStyles(), '\x1b[0m');
    });

    test('combine VT100 commands', () {
      expect(
        VT100.foreground(1) + VT100.background(6),
        '\x1b[38;5;1m\x1b[48;5;6m',
      );
      expect(
        VT100.bold() + VT100.underline() + VT100.foreground(2),
        '\x1b[1m\x1b[4m\x1b[38;5;2m',
      );
    });
  });
}
