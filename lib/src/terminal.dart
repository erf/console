import 'dart:io';

import 'input/input.dart';

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

  /// Broadcast stream of raw terminal input bytes.
  Stream<List<int>> get input;

  /// Stream of parsed input events.
  ///
  /// This is a convenience stream that parses raw input bytes into
  /// structured [InputEvent] objects (keyboard and mouse events).
  Stream<InputEvent> get inputEvents;

  /// Stream of terminal resize events.
  Stream<ProcessSignal> get resize;

  /// Stream of interrupt (Ctrl+C) events.
  Stream<ProcessSignal> get interrupt;

  /// Write to the terminal output.
  void write(Object? object);
}

/// A terminal interface for reading input and writing output.
///
/// Provides access to raw mode, terminal dimensions, input streams,
/// and resize events.
class Terminal extends TerminalBase {
  bool _rawMode = false;
  final _parser = InputParser();

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
  late final Stream<InputEvent> inputEvents = input.expand(_parser.parse);

  @override
  Stream<ProcessSignal> get resize => ProcessSignal.sigwinch.watch();

  @override
  Stream<ProcessSignal> get interrupt => ProcessSignal.sigint.watch();

  @override
  void write(Object? str) => stdout.write(str);
}
