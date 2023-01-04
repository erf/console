import 'package:console/console.dart';
import 'package:test/test.dart';

void main() {
  group('console tests', () {
    late Console console;

    setUp(() {
      console = Console();
    });

    test('move', () {
      console.move(row: 1, col: 2);
      expect(console.buffer.toString(), '\x1b[1;2H');
    });

    test('hide cursor', () {
      console.cursor = false;
      expect(console.buffer.toString(), '\x1b[?25l');
    });

    test('clear', () {
      console.clear();
      expect(console.buffer.toString(), '\x1b[H\x1b[J');
    });

    test('color_fg', () {
      console.color_fg = 1;
      expect(console.buffer.toString(), '\x1b[38;5;1m');
    });

    test('color_bg', () {
      console.color_bg = 6;
      expect(console.buffer.toString(), '\x1b[48;5;6m');
    });

    test('color_reset', () {
      console.color_reset();
      expect(console.buffer.toString(), '\x1b[0m');
    });

    test('two commands', () {
      console.color_fg = 1;
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
