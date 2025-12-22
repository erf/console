import 'dart:io';

/// A terminal interface for reading input and writing output.
///
/// Provides access to raw mode, terminal dimensions, input streams,
/// and resize events.
class Terminal {
  bool _rawMode = false;

  /// Get the current raw mode state.
  bool get rawMode => _rawMode;

  /// Set raw mode for terminal input.
  ///
  /// When enabled, input is unbuffered and echo is disabled.
  set rawMode(bool value) {
    _rawMode = value;
    stdin.echoMode = !value;
    stdin.lineMode = !value;
  }

  /// Get width of terminal in columns.
  int get width => stdout.terminalColumns;

  /// Get height of terminal in rows.
  int get height => stdout.terminalLines;

  /// Broadcast stream of terminal input.
  late final Stream<List<int>> input = stdin.asBroadcastStream();

  /// Stream of terminal resize events.
  Stream<ProcessSignal> get resize => ProcessSignal.sigwinch.watch();

  /// Write to stdout.
  void write(Object? str) => stdout.write(str);
}
