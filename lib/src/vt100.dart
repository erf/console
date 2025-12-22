/// VT100 escape codes for terminal control.
///
/// All methods return escape code strings that can be written to the terminal.
class VT100 {
  VT100._();

  /// Escape character.
  static const e = '\x1b';

  /// Move cursor to position (x, y).
  ///
  /// Coordinates are 1-based (top-left is 1,1).
  static String cursorPosition({required int x, required int y}) =>
      '$e[$y;${x}H';

  /// Show or hide the cursor.
  static String cursorVisible(bool visible) => visible ? '$e[?25h' : '$e[?25l';

  /// Move cursor home and erase screen.
  static String homeAndErase() => '$e[H$e[J';

  /// Set foreground color using 256-color palette.
  static String foreground(int color) => '$e[38;5;${color}m';

  /// Set background color using 256-color palette.
  static String background(int color) => '$e[48;5;${color}m';

  /// Enable bold text.
  static String bold() => '$e[1m';

  /// Enable underlined text.
  static String underline() => '$e[4m';

  /// Reset all text styles and colors.
  static String resetStyles() => '$e[0m';
}
