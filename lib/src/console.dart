import 'dart:io';

// https://vt100.net/docs/vt100-ug/contents.html
// https://learn.microsoft.com/en-us/windows/console/console-virtual-terminal-sequences
// https://ilkerf.tripod.com/cdoc/vt100ref.html
class Console {
  final buffer = StringBuffer();

  void rawMode(bool rawMode) {
    if (rawMode) {
      stdin.echoMode = false;
      stdin.lineMode = false;
    } else {
      stdin.echoMode = true;
      stdin.lineMode = true;
    }
  }

  int get width {
    return stdout.terminalColumns;
  }

  int get height {
    return stdout.terminalLines;
  }

  Stream<List<int>> get input {
    return stdin.asBroadcastStream();
  }

  Stream<ProcessSignal> get resize {
    return ProcessSignal.sigwinch.watch();
  }

  // appends the given string to the buffer.
  void append(String str) {
    buffer.write(str);
  }

  // applies the buffer to the console and clears it.
  void apply() {
    stdout.write(buffer);
    buffer.clear();
  }

  // moves the cursor to the given position.
  void cursorPosition({required int x, required int y}) {
    append('\x1b[$y;${x}H');
  }

  // hides or shows the cursor.
  void cursorVisible(bool visible) {
    if (visible) {
      append('\x1b[?25h');
    } else {
      append('\x1b[?25l');
    }
  }

  // erases the screen and moves the cursor to the top left.
  void clear() {
    append('\x1b[H\x1b[J');
  }

  // erases the line with the background colour and moves the cursor to the start of the line.
  void foreground(int color) {
    append('\x1b[38;5;${color}m');
  }

  // set background color
  void background(int color) {
    append('\x1b[48;5;${color}m');
  }

  // reset the style.
  void resetStyles() {
    append('\x1b[0m');
  }
}
