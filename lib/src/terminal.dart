import 'dart:io';

/// Abstract base class for terminal implementations.
///
/// This allows for different terminal implementations, such as a real
/// terminal or a test terminal for unit testing.
abstract class TerminalBase {
  /// Get the current raw mode state.
  bool get rawMode;

  /// Set raw mode for terminal input.
  ///
  /// When enabled, input is unbuffered and echo is disabled.
  set rawMode(bool value);

  /// Get width of terminal in columns.
  int get width;

  /// Get height of terminal in rows.
  int get height;

  /// Broadcast stream of terminal input.
  Stream<List<int>> get input;

  /// Stream of terminal resize events.
  Stream<ProcessSignal> get resize;

  /// Write to the terminal output.
  void write(Object? object);
}

/// A terminal interface for reading input and writing output.
///
/// Provides access to raw mode, terminal dimensions, input streams,
/// and resize events.
class Terminal extends TerminalBase {
  bool _rawMode = false;

  @override
  bool get rawMode => _rawMode;

  @override
  set rawMode(bool value) {
    _rawMode = value;
    stdin.echoMode = !value;
    stdin.lineMode = !value;
  }

  @override
  int get width => stdout.terminalColumns;

  @override
  int get height => stdout.terminalLines;

  @override
  late final Stream<List<int>> input = stdin.asBroadcastStream();

  @override
  Stream<ProcessSignal> get resize => ProcessSignal.sigwinch.watch();

  @override
  void write(Object? str) => stdout.write(str);
}
