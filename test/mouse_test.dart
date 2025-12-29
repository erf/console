import 'package:termio/termio.dart';
import 'package:test/test.dart';

void main() {
  group('MouseEvent parsing', () {
    test('parses left button press', () {
      final event = MouseEvent.tryParse('\x1b[<0;10;20M');
      expect(event, isNotNull);
      expect(event!.x, 10);
      expect(event.y, 20);
      expect(event.button, MouseButton.left);
      expect(event.isPress, true);
      expect(event.isRelease, false);
    });

    test('parses left button release', () {
      final event = MouseEvent.tryParse('\x1b[<0;5;15m');
      expect(event, isNotNull);
      expect(event!.x, 5);
      expect(event.y, 15);
      expect(event.button, MouseButton.left);
      expect(event.isPress, false);
      expect(event.isRelease, true);
    });

    test('parses middle button', () {
      final event = MouseEvent.tryParse('\x1b[<1;1;1M');
      expect(event, isNotNull);
      expect(event!.button, MouseButton.middle);
    });

    test('parses right button', () {
      final event = MouseEvent.tryParse('\x1b[<2;1;1M');
      expect(event, isNotNull);
      expect(event!.button, MouseButton.right);
    });

    test('parses shift modifier', () {
      // 0 + 4 (shift) = 4
      final event = MouseEvent.tryParse('\x1b[<4;1;1M');
      expect(event, isNotNull);
      expect(event!.button, MouseButton.left);
      expect(event.shift, true);
      expect(event.alt, false);
      expect(event.ctrl, false);
    });

    test('parses alt modifier', () {
      // 0 + 8 (alt) = 8
      final event = MouseEvent.tryParse('\x1b[<8;1;1M');
      expect(event, isNotNull);
      expect(event!.alt, true);
    });

    test('parses ctrl modifier', () {
      // 0 + 16 (ctrl) = 16
      final event = MouseEvent.tryParse('\x1b[<16;1;1M');
      expect(event, isNotNull);
      expect(event!.ctrl, true);
    });

    test('parses multiple modifiers', () {
      // 0 + 4 (shift) + 8 (alt) + 16 (ctrl) = 28
      final event = MouseEvent.tryParse('\x1b[<28;1;1M');
      expect(event, isNotNull);
      expect(event!.shift, true);
      expect(event.alt, true);
      expect(event.ctrl, true);
    });

    test('parses scroll up', () {
      // 64 = scroll up
      final event = MouseEvent.tryParse('\x1b[<64;10;5M');
      expect(event, isNotNull);
      expect(event!.isScroll, true);
      expect(event.scrollDirection, ScrollDirection.up);
      expect(event.button, MouseButton.none);
      expect(event.x, 10);
      expect(event.y, 5);
    });

    test('parses scroll down', () {
      // 65 = scroll down
      final event = MouseEvent.tryParse('\x1b[<65;10;5M');
      expect(event, isNotNull);
      expect(event!.isScroll, true);
      expect(event.scrollDirection, ScrollDirection.down);
    });

    test('parses motion event', () {
      // 32 = motion flag + 0 (left button held)
      final event = MouseEvent.tryParse('\x1b[<32;50;25M');
      expect(event, isNotNull);
      expect(event!.isMotion, true);
      expect(event.x, 50);
      expect(event.y, 25);
    });

    test('parses large coordinates', () {
      // SGR mode supports coordinates > 223
      final event = MouseEvent.tryParse('\x1b[<0;300;150M');
      expect(event, isNotNull);
      expect(event!.x, 300);
      expect(event.y, 150);
    });

    test('returns null for invalid input', () {
      expect(MouseEvent.tryParse(''), isNull);
      expect(MouseEvent.tryParse('hello'), isNull);
      expect(MouseEvent.tryParse('\x1b[A'), isNull); // arrow key
      expect(MouseEvent.tryParse('\x1b[<0;1M'), isNull); // missing param
      expect(MouseEvent.tryParse('\x1b[<0;1;2X'), isNull); // wrong terminator
    });

    test('returns null for non-SGR mouse formats', () {
      // X10 format (not supported)
      expect(MouseEvent.tryParse('\x1b[M !!'), isNull);
    });
  });

  group('MouseEvent properties', () {
    test('isRelease is correct', () {
      final press = MouseEvent.tryParse('\x1b[<0;1;1M');
      final release = MouseEvent.tryParse('\x1b[<0;1;1m');
      final scroll = MouseEvent.tryParse('\x1b[<64;1;1M');

      expect(press!.isRelease, false);
      expect(release!.isRelease, true);
      expect(scroll!.isRelease, false); // scroll is not a release
    });

    test('toString for button event', () {
      final event = MouseEvent.tryParse('\x1b[<0;10;20M');
      expect(event.toString(), contains('left'));
      expect(event.toString(), contains('press'));
      expect(event.toString(), contains('10'));
      expect(event.toString(), contains('20'));
    });

    test('toString for scroll event', () {
      final event = MouseEvent.tryParse('\x1b[<64;5;5M');
      expect(event.toString(), contains('scroll'));
      expect(event.toString(), contains('up'));
    });

    test('toString with modifiers', () {
      final event = MouseEvent.tryParse('\x1b[<12;1;1M'); // shift + alt
      expect(event.toString(), contains('shift'));
      expect(event.toString(), contains('alt'));
    });
  });
}
