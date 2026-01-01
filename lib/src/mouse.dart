/// Mouse event handling for terminal applications.
///
/// Use [Ansi.mouseMode] to enable mouse tracking, then parse incoming
/// escape sequences with [MouseEvent.tryParse].
library;

/// Mouse button identifiers.
enum MouseButton {
  /// Left mouse button.
  left,

  /// Middle mouse button (scroll wheel click).
  middle,

  /// Right mouse button.
  right,

  /// No button (used for motion events).
  none,
}

/// Scroll direction for mouse wheel events.
enum ScrollDirection {
  /// Scroll wheel moved up.
  up,

  /// Scroll wheel moved down.
  down,

  /// Scroll wheel moved left (horizontal scroll).
  left,

  /// Scroll wheel moved right (horizontal scroll).
  right,
}

/// A parsed mouse event from SGR extended mode (mode 1006).
///
/// Mouse events are reported when [Ansi.mouseMode] or [Ansi.mouseTracking]
/// is enabled. Use [tryParse] to convert raw input into structured events.
///
/// Example:
/// ```dart
/// terminal.input.listen((bytes) {
///   final input = String.fromCharCodes(bytes);
///   final mouse = MouseEvent.tryParse(input);
///   if (mouse != null && mouse.isPress && mouse.button == MouseButton.left) {
///     terminal.write(Ansi.cursor(x: mouse.x, y: mouse.y));
///   }
/// });
/// ```
class MouseEvent {
  /// Column position (1-based, leftmost column is 1).
  final int x;

  /// Row position (1-based, top row is 1).
  final int y;

  /// Which mouse button triggered the event.
  ///
  /// For scroll events, this will be [MouseButton.none].
  final MouseButton button;

  /// Whether this is a button press event.
  ///
  /// False for release events. Always true for scroll events.
  final bool isPress;

  /// Whether the shift key was held during the event.
  final bool shift;

  /// Whether the alt/option key was held during the event.
  final bool alt;

  /// Whether the ctrl key was held during the event.
  final bool ctrl;

  /// Whether this is a scroll wheel event.
  ///
  /// If true, use [scrollDirection] to determine scroll direction.
  final bool isScroll;

  /// The scroll direction, if [isScroll] is true.
  ///
  /// Null for non-scroll events.
  final ScrollDirection? scrollDirection;

  /// Whether this is a mouse motion event (movement without click).
  ///
  /// Motion events are only reported when [Ansi.mouseAnyEvent] or
  /// [Ansi.mouseButtonEvent] is enabled.
  final bool isMotion;

  /// Creates a mouse event.
  const MouseEvent({
    required this.x,
    required this.y,
    required this.button,
    required this.isPress,
    this.shift = false,
    this.alt = false,
    this.ctrl = false,
    this.isScroll = false,
    this.scrollDirection,
    this.isMotion = false,
  });

  /// Whether this is a button release event.
  bool get isRelease => !isPress && !isScroll;

  /// Try to parse a mouse event from terminal input.
  ///
  /// Returns `null` if the input is not a valid SGR mouse event.
  ///
  /// SGR format: `\x1b[<Cb;Cx;CyM` (press) or `\x1b[<Cb;Cx;Cym` (release)
  ///
  /// Where:
  /// - Cb = button code with modifier flags
  /// - Cx = column (1-based)
  /// - Cy = row (1-based)
  /// - M = press, m = release
  static MouseEvent? tryParse(String input) {
    // SGR extended format: ESC [ < Cb ; Cx ; Cy M/m
    if (!input.startsWith('\x1b[<')) return null;

    final lastChar = input.isEmpty ? '' : input[input.length - 1];
    final isPress = lastChar == 'M';
    final isRelease = lastChar == 'm';
    if (!isPress && !isRelease) return null;

    // Extract parameters between '<' and 'M'/'m'
    final params = input.substring(3, input.length - 1).split(';');
    if (params.length != 3) return null;

    final cb = int.tryParse(params[0]);
    final cx = int.tryParse(params[1]);
    final cy = int.tryParse(params[2]);
    if (cb == null || cx == null || cy == null) return null;

    // Decode button code
    // Bits 0-1: button (0=left, 1=middle, 2=right, 3=release/none)
    // Bit 2: shift
    // Bit 3: alt
    // Bit 4: ctrl
    // Bit 5: motion
    // Bits 6-7: 64=scroll up, 65=scroll down

    final buttonBits = cb & 3;
    final shift = (cb & 4) != 0;
    final alt = (cb & 8) != 0;
    final ctrl = (cb & 16) != 0;
    final motion = (cb & 32) != 0;
    final scrollBit = (cb & 64) != 0;

    MouseButton button;
    bool isScroll = false;
    ScrollDirection? scrollDirection;

    if (scrollBit) {
      // Scroll wheel event
      // buttonBits: 0=up, 1=down, 2=left, 3=right
      isScroll = true;
      button = MouseButton.none;
      scrollDirection = switch (buttonBits) {
        0 => ScrollDirection.up,
        1 => ScrollDirection.down,
        2 => ScrollDirection.left,
        3 => ScrollDirection.right,
        _ => null,
      };
      if (scrollDirection == null) return null;
    } else if (buttonBits == 3) {
      // Button release in X10 mode, or motion without button
      button = MouseButton.none;
    } else {
      button = MouseButton.values[buttonBits];
    }

    return MouseEvent(
      x: cx,
      y: cy,
      button: button,
      isPress: isPress,
      shift: shift,
      alt: alt,
      ctrl: ctrl,
      isScroll: isScroll,
      scrollDirection: scrollDirection,
      isMotion: motion && !isScroll,
    );
  }

  @override
  String toString() {
    if (isScroll) {
      return 'MouseEvent(scroll ${scrollDirection?.name}, x: $x, y: $y)';
    }
    final action = isPress ? 'press' : 'release';
    final mods = [if (shift) 'shift', if (alt) 'alt', if (ctrl) 'ctrl'];
    final modStr = mods.isEmpty ? '' : ', mods: ${mods.join('+')}';
    return 'MouseEvent(${button.name} $action, x: $x, y: $y$modStr)';
  }
}
