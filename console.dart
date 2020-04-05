import 'dart:io';

void main() {
  stdin.echoMode = false;
  stdin.lineMode = false;

  stdin.listen((text) {
    stdout.write(text);
  });

  stdout.write("hello world");
}
