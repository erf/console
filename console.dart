import 'dart:io';

class Console {
  Console() {
  }
}

void main() {
  stdin.echoMode = false;
  stdin.lineMode = false;

  stdin.listen((codes) {
    String string = String.fromCharCodes(codes);
    stdout.write(string);
    stdout.write(codes);
  });

  stdout.write("\x1b[38;5;${1}m");
  stdout.write("hello world");
}
