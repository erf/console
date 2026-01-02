/// A minimal library for building interactive terminal applications.
///
/// This library provides:
/// - [Terminal] - Interface for raw mode, input streams, and terminal size
/// - [TerminalBase] - Abstract base class for terminal implementations
/// - [Ansi] - ANSI escape codes for cursor, colors, and text styles
/// - [Keys] - Common key constants for input handling
/// - [InputParser] - Parse raw input into structured [InputEvent] objects
/// - [KeyInputEvent], [MouseInputEvent] - Typed input events
/// - [MouseEvent] - Parsed mouse events for click handling
/// - [Color] - Standard 16 terminal colors
/// - [CursorStyle] - Cursor style options
///
/// For testing, import `package:termio/testing.dart` for [TestTerminal].
library;

export 'src/ansi.dart';
export 'src/input/input.dart';
export 'src/keys.dart';
export 'src/mouse.dart';
export 'src/terminal.dart' show Terminal, TerminalBase;
export 'src/theme_detector.dart';
