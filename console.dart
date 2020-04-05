import 'dart:io';

class Console {
  final buffer = StringBuffer();

  void set rawMode(bool rawMode) {
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

  Stream get input {
    return stdin.asBroadcastStream();
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
  }

  void move(int row, int col) {
    append("\x1b[${row};${col}H");
  }

  void set cursor(bool visible) {
    if (visible)
      append("\x1b[?25h");
    else
      append("\x1b[?25l");
  }

  void clear() {
    append("\x1b[H"); // Go home
    append("\x1b[J"); // erase down
  }

  void set color_fg(int color) {
    append("\x1b[38;5;${color}m");
  }

  void set color_bg(int color) {
    append("\x1b[48;5;${color}m");
  }

  void color_reset() {
    append("\x1b[0m");
  }

// TODO resize callback using SIGWINCH and ffi
//void on_resize(resize_handler handler) {
//signal(SIGWINCH, handler);
//}
}

void main() {
  final c = Console();
  c.rawMode = true;

  c.input.listen((codes) {
    String string = String.fromCharCodes(codes);
    stdout.write(string);
    stdout.write(codes);
  });

  c.color_fg = 1;
  c.append("hello\n");
  c.color_fg = 6;
  c.append("[${c.cols}, ${c.rows}]");
  c.apply();
}
