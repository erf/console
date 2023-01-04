import 'package:console/console.dart';
import 'package:test/test.dart';

void main() {
  group('console tests', () {
    late Console console;

    setUp(() {
      console = Console();
    });

    test('cursorPosition', () {
      console.cursorPosition(y: 1, x: 2);
      expect(console.buffer.toString(), '\x1b[1;2H');
    });

    test('cursorVisible', () {
      console.cursorVisible(false);
      expect(console.buffer.toString(), '\x1b[?25l');
    });

    test('clear', () {
      console.clear();
      expect(console.buffer.toString(), '\x1b[H\x1b[J');
    });

    test('foreground', () {
      console.foreground(1);
      expect(console.buffer.toString(), '\x1b[38;5;1m');
    });

    test('background', () {
      console.background(6);
      expect(console.buffer.toString(), '\x1b[48;5;6m');
    });

    test('resetStyles', () {
      console.resetStyles();
      expect(console.buffer.toString(), '\x1b[0m');
    });

    test('two commands', () {
      console.foreground(1);
      console.append('hello');
      expect(console.buffer.toString(), '\x1b[38;5;1mhello');
    });

    test('clear buffer', () {
      //console.color_fg = 1;
      //console.append('hello');
      //console.apply();
      //expect(console.buffer.toString(), "");
    });
  });
}
