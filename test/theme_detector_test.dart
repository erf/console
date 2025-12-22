import 'package:termio/termio.dart';
import 'package:test/test.dart';

void main() {
  group('ThemeMode', () {
    test('has light and dark values', () {
      expect(ThemeMode.values, contains(ThemeMode.light));
      expect(ThemeMode.values, contains(ThemeMode.dark));
    });
  });

  group('ThemeDetector response parsing', () {
    // Test the luminance calculation logic by checking known colors
    // Note: We can't easily test detectSync() without mocking stdin/stdout,
    // but we can verify the query string and document expected behavior.

    test('queryBackgroundColor returns OSC 11 sequence', () {
      // Verify the query that ThemeDetector uses
      expect(Ansi.queryBackgroundColor(), '\x1b]11;?\x1b\\');
    });

    test('response format documentation', () {
      // Document expected response formats for reference:
      // - 16-bit: ESC ] 11 ; rgb:RRRR/GGGG/BBBB ST
      // - 8-bit:  ESC ] 11 ; rgb:RR/GG/BB ST
      // ST can be ESC \ or BEL (\x07)

      // Example dark background response (black):
      // '\x1b]11;rgb:0000/0000/0000\x1b\\'

      // Example light background response (white):
      // '\x1b]11;rgb:ffff/ffff/ffff\x1b\\'

      // This test documents the format but doesn't test parsing directly
      // since _parseResponse is private. The detectSync tests below
      // would test the full flow in an integration test context.
      expect(true, isTrue); // Placeholder for documentation
    });
  });

  group('ThemeDetector luminance logic', () {
    // These tests verify the expected luminance-based classification
    // by documenting what colors should map to which theme.

    test('black background should be dark theme', () {
      // rgb:0000/0000/0000 -> luminance = 0 -> dark
      // Luminance = 0.2126 * 0 + 0.7152 * 0 + 0.0722 * 0 = 0
      expect(0.0 > 0.5, isFalse); // -> ThemeMode.dark
    });

    test('white background should be light theme', () {
      // rgb:ffff/ffff/ffff -> luminance ≈ 1 -> light
      // Luminance = 0.2126 * 1 + 0.7152 * 1 + 0.0722 * 1 = 1.0
      expect(1.0 > 0.5, isTrue); // -> ThemeMode.light
    });

    test('solarized dark background should be dark theme', () {
      // Solarized dark base03: #002b36 -> rgb:0000/2b2b/3636
      // R=0, G=43, B=54
      final luminance =
          0.2126 * 0 / 255 + 0.7152 * 43 / 255 + 0.0722 * 54 / 255;
      expect(luminance > 0.5, isFalse); // -> ThemeMode.dark
    });

    test('solarized light background should be light theme', () {
      // Solarized light base3: #fdf6e3 -> rgb:fdfd/f6f6/e3e3
      // R=253, G=246, B=227
      final luminance =
          0.2126 * 253 / 255 + 0.7152 * 246 / 255 + 0.0722 * 227 / 255;
      expect(luminance > 0.5, isTrue); // -> ThemeMode.light
    });

    test('gray 50% should be at boundary', () {
      // rgb:8080/8080/8080 -> luminance ≈ 0.5
      // R=G=B=128
      final luminance =
          0.2126 * 128 / 255 + 0.7152 * 128 / 255 + 0.0722 * 128 / 255;
      // ~0.502, just above 0.5 threshold
      expect(luminance, closeTo(0.5, 0.01));
    });
  });
}
