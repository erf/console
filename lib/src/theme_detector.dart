import 'dart:io';

import 'ansi.dart';

/// Terminal color theme (light or dark background).
enum ThemeMode {
  /// Light background (high luminance).
  light,

  /// Dark background (low luminance).
  dark,
}

/// Detects terminal background color using OSC 11 query.
///
/// This can be used to automatically select an appropriate color scheme
/// based on whether the terminal has a light or dark background.
///
/// Example:
/// ```dart
/// terminal.rawMode = true;
/// final theme = ThemeDetector.detectSync() ?? ThemeMode.dark;
/// if (theme == ThemeMode.light) {
///   // Use dark text colors
/// } else {
///   // Use light text colors
/// }
/// ```
///
/// **Note:** Requires raw mode to be enabled. Not all terminals support
/// OSC 11 queries; returns `null` if detection fails.
class ThemeDetector {
  ThemeDetector._();

  /// Query terminal background and return appropriate theme.
  ///
  /// Requires the terminal to be in raw mode. Sends an OSC 11 query and
  /// parses the response to determine if the background is light or dark.
  ///
  /// Returns `null` if:
  /// - The terminal doesn't respond within [timeout]
  /// - The response cannot be parsed
  /// - An error occurs during detection
  ///
  /// The [timeout] should be kept short (default 50ms) since terminals that
  /// support OSC 11 respond almost instantly.
  static ThemeMode? detectSync({
    Duration timeout = const Duration(milliseconds: 50),
  }) {
    try {
      // Send OSC 11 query
      stdout.write(Ansi.queryBackgroundColor());

      // Read response with timeout
      final buffer = <int>[];
      final deadline = DateTime.now().add(timeout);

      while (DateTime.now().isBefore(deadline)) {
        try {
          final byte = stdin.readByteSync();
          if (byte == -1) break;
          buffer.add(byte);

          // Check if response is complete (ends with ST or BEL)
          final response = String.fromCharCodes(buffer);
          if (response.contains('\x1b\\') || response.contains('\x07')) {
            return _parseResponse(response);
          }
        } catch (_) {
          break;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Parse OSC 11 response and determine theme based on luminance.
  ///
  /// Response format: `ESC ] 11 ; rgb:RRRR/GGGG/BBBB ST`
  /// where each color component is 2 or 4 hex digits.
  static ThemeMode? _parseResponse(String response) {
    // Match rgb:XXXX/XXXX/XXXX pattern (may be 2 or 4 hex digits per channel)
    final rgbMatch = RegExp(
      r'rgb:([0-9a-fA-F]+)/([0-9a-fA-F]+)/([0-9a-fA-F]+)',
    ).firstMatch(response);

    if (rgbMatch == null) return null;

    // Parse hex values
    final rHex = rgbMatch.group(1)!;
    final gHex = rgbMatch.group(2)!;
    final bHex = rgbMatch.group(3)!;

    // Normalize to 0-255 range
    final r = _normalizeColor(rHex);
    final g = _normalizeColor(gHex);
    final b = _normalizeColor(bHex);

    // Calculate relative luminance (sRGB)
    // https://www.w3.org/TR/WCAG20/#relativeluminancedef
    final luminance = 0.2126 * r / 255 + 0.7152 * g / 255 + 0.0722 * b / 255;

    // Light background if luminance > 0.5
    return luminance > 0.5 ? ThemeMode.light : ThemeMode.dark;
  }

  /// Normalize hex color value to 0-255 range.
  static int _normalizeColor(String hex) {
    final value = int.parse(hex, radix: 16);
    // If 4 hex digits (16-bit), scale down to 8-bit
    if (hex.length == 4) {
      return value >> 8;
    }
    // If 2 hex digits, use as-is
    return value;
  }
}
