/// A minimal library for building interactive terminal applications.
///
/// This library provides:
/// - [Terminal] - Interface for raw mode, input streams, and terminal size
/// - [VT100] - VT100 escape codes for cursor, colors, and text styles
library;

export 'src/terminal.dart' show Terminal;
export 'src/vt100.dart';
