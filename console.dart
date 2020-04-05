import 'dart:io';

class Console {
  Console() {}

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

  void setColor(int color) {
    stdout.write("\x1b[38;5;${color}m");
  }

  void write(Object object) {
    stdout.write(object);
  }

  Stream inputStream() {
    return stdin.asBroadcastStream();
  }
}

void main() {
  final console = Console();
  console.rawMode = true;

  console.inputStream().listen((codes) {
    String string = String.fromCharCodes(codes);
    stdout.write(string);
    stdout.write(codes);
  });

  console.setColor(6);
  console.write("[${console.cols}, ${console.rows}]");
}
