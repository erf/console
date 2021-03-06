import 'dart:io';

class Console {
  final buffer = StringBuffer();

  set rawMode(bool rawMode) {
    if (rawMode) {
      stdin.echoMode = false;
      stdin.lineMode = false;
    } else {
      stdin.echoMode = true;
      stdin.lineMode = true;
    }
  }

  int get cols {
    return stdout.terminalColumns;
  }

  int get rows {
    return stdout.terminalLines;
  }

  Stream<List<int>> get input {
    return stdin.asBroadcastStream();
  }

  Stream<ProcessSignal> get resize {
    return ProcessSignal.sigwinch.watch();
  }

  // should use append / apply  in most cases
  void write(Object object) {
    stdout.write(object);
  }

  void append(String str) {
    buffer.write(str);
  }

  void apply() {
    stdout.write(buffer);
    buffer.clear();
  }

  void move({int row, int col}) {
    append('\x1b[${row};${col}H');
  }

  set cursor(bool visible) {
    if (visible) {
      append('\x1b[?25h');
    } else {
      append('\x1b[?25l');
    }
  }

  void clear() {
    append('\x1b[H'); // Go home
    append('\x1b[J'); // erase down
  }

  set color_fg(int color) {
    append('\x1b[38;5;${color}m');
  }

  set color_bg(int color) {
    append('\x1b[48;5;${color}m');
  }

  void color_reset() {
    append('\x1b[0m');
  }
}
