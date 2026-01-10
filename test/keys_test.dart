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

    test('shift+tab (backtab)', () {
      expect(Keys.shiftTab, '\x1b[Z');
    });

    test('shift+arrow keys', () {
      expect(Keys.shiftArrowUp, '\x1b[1;2A');
      expect(Keys.shiftArrowDown, '\x1b[1;2B');
      expect(Keys.shiftArrowRight, '\x1b[1;2C');
      expect(Keys.shiftArrowLeft, '\x1b[1;2D');
    });

    test('alt+arrow keys', () {
      expect(Keys.altArrowUp, '\x1b[1;3A');
      expect(Keys.altArrowDown, '\x1b[1;3B');
      expect(Keys.altArrowRight, '\x1b[1;3C');
      expect(Keys.altArrowLeft, '\x1b[1;3D');
    });

    test('ctrl+arrow keys', () {
      expect(Keys.ctrlArrowUp, '\x1b[1;5A');
      expect(Keys.ctrlArrowDown, '\x1b[1;5B');
      expect(Keys.ctrlArrowRight, '\x1b[1;5C');
      expect(Keys.ctrlArrowLeft, '\x1b[1;5D');
    });

    test('ctrl+shift+arrow keys', () {
      expect(Keys.ctrlShiftArrowUp, '\x1b[1;6A');
      expect(Keys.ctrlShiftArrowDown, '\x1b[1;6B');
      expect(Keys.ctrlShiftArrowRight, '\x1b[1;6C');
      expect(Keys.ctrlShiftArrowLeft, '\x1b[1;6D');
    });

    test('modified navigation keys', () {
      expect(Keys.shiftHome, '\x1b[1;2H');
      expect(Keys.shiftEnd, '\x1b[1;2F');
      expect(Keys.ctrlHome, '\x1b[1;5H');
      expect(Keys.ctrlEnd, '\x1b[1;5F');
      expect(Keys.ctrlShiftHome, '\x1b[1;6H');
      expect(Keys.ctrlShiftEnd, '\x1b[1;6F');
      expect(Keys.shiftDelete, '\x1b[3;2~');
      expect(Keys.ctrlDelete, '\x1b[3;5~');
      expect(Keys.ctrlPageUp, '\x1b[5;5~');
      expect(Keys.ctrlPageDown, '\x1b[6;5~');
    });
  });
}
