import 'dart:io';

/// A terminal interface for reading input and writing output
class Terminal {
  /// Set raw mode for terminal input
  set rawMode(bool rawMode) {
    if (rawMode) {
      stdin.echoMode = false;
      stdin.lineMode = false;
    } else {
      stdin.echoMode = true;
      stdin.lineMode = true;
    }
  }

  /// Get width of terminal
  int get width => stdout.terminalColumns;

  /// Get height of terminal
  int get height => stdout.terminalLines;

  /// Watch for terminal input
  Stream<List<int>> get input => stdin.asBroadcastStream();

  /// Watch for terminal resize events
  Stream<ProcessSignal> get resize => ProcessSignal.sigwinch.watch();

  /// Write to stdout
  void write(Object? str) => stdout.write(str);
}
