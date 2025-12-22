/// Common key constants for terminal input handling.
///
/// These constants represent common keyboard inputs as they appear in
/// raw terminal mode.
class Keys {
  Keys._();

  /// Newline character (`\n`).
  static const newline = '\n';

  /// Carriage return (`\r`).
  static const carriageReturn = '\r';

  /// Escape character (`\x1b`).
  static const escape = '\x1b';

  /// Backspace character (`\x7f`).
  static const backspace = '\x7f';

  /// Bell character (`\x07`).
  static const bell = '\x07';

  /// Tab character (`\t`).
  static const tab = '\t';

  /// Space character.
  static const space = ' ';

  // ─────────────────────────────────────────────────────────────────────────
  // Ctrl key combinations
  // ─────────────────────────────────────────────────────────────────────────

  /// Ctrl+A (start of heading).
  static const ctrlA = '\x01';

  /// Ctrl+B.
  static const ctrlB = '\x02';

  /// Ctrl+C (interrupt, but usually handled by terminal).
  static const ctrlC = '\x03';

  /// Ctrl+D (end of transmission).
  static const ctrlD = '\x04';

  /// Ctrl+E (enquiry).
  static const ctrlE = '\x05';

  /// Ctrl+F.
  static const ctrlF = '\x06';

  /// Ctrl+G (bell).
  static const ctrlG = '\x07';

  /// Ctrl+H (backspace on some terminals).
  static const ctrlH = '\x08';

  /// Ctrl+K (vertical tab).
  static const ctrlK = '\x0b';

  /// Ctrl+L (form feed, often used for clear screen).
  static const ctrlL = '\x0c';

  /// Ctrl+N.
  static const ctrlN = '\x0e';

  /// Ctrl+O.
  static const ctrlO = '\x0f';

  /// Ctrl+P.
  static const ctrlP = '\x10';

  /// Ctrl+Q (XON, resume transmission).
  static const ctrlQ = '\x11';

  /// Ctrl+R.
  static const ctrlR = '\x12';

  /// Ctrl+S (XOFF, pause transmission).
  static const ctrlS = '\x13';

  /// Ctrl+T.
  static const ctrlT = '\x14';

  /// Ctrl+U (clear line).
  static const ctrlU = '\x15';

  /// Ctrl+V.
  static const ctrlV = '\x16';

  /// Ctrl+W (delete word).
  static const ctrlW = '\x17';

  /// Ctrl+X.
  static const ctrlX = '\x18';

  /// Ctrl+Y.
  static const ctrlY = '\x19';

  /// Ctrl+Z (suspend, but usually handled by terminal).
  static const ctrlZ = '\x1a';

  // ─────────────────────────────────────────────────────────────────────────
  // Arrow keys (escape sequences)
  // ─────────────────────────────────────────────────────────────────────────

  /// Up arrow key.
  static const arrowUp = '\x1b[A';

  /// Down arrow key.
  static const arrowDown = '\x1b[B';

  /// Right arrow key.
  static const arrowRight = '\x1b[C';

  /// Left arrow key.
  static const arrowLeft = '\x1b[D';

  // ─────────────────────────────────────────────────────────────────────────
  // Navigation keys
  // ─────────────────────────────────────────────────────────────────────────

  /// Home key.
  static const home = '\x1b[H';

  /// End key.
  static const end = '\x1b[F';

  /// Insert key.
  static const insert = '\x1b[2~';

  /// Delete key.
  static const delete = '\x1b[3~';

  /// Page Up key.
  static const pageUp = '\x1b[5~';

  /// Page Down key.
  static const pageDown = '\x1b[6~';

  // ─────────────────────────────────────────────────────────────────────────
  // Function keys
  // ─────────────────────────────────────────────────────────────────────────

  /// F1 key.
  static const f1 = '\x1bOP';

  /// F2 key.
  static const f2 = '\x1bOQ';

  /// F3 key.
  static const f3 = '\x1bOR';

  /// F4 key.
  static const f4 = '\x1bOS';

  /// F5 key.
  static const f5 = '\x1b[15~';

  /// F6 key.
  static const f6 = '\x1b[17~';

  /// F7 key.
  static const f7 = '\x1b[18~';

  /// F8 key.
  static const f8 = '\x1b[19~';

  /// F9 key.
  static const f9 = '\x1b[20~';

  /// F10 key.
  static const f10 = '\x1b[21~';

  /// F11 key.
  static const f11 = '\x1b[23~';

  /// F12 key.
  static const f12 = '\x1b[24~';
}
