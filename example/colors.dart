import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();
final buffer = StringBuffer();

int rows = terminal.height;
int cols = terminal.width;

void draw() {
  buffer.write(Ansi.bgIndex(0));
  buffer.write(Ansi.clearScreen());

  var color = 0;
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      buffer.write(Ansi.cursor(y: row + 1, x: col + 1));
      buffer.write(Ansi.bgIndex(color));
      buffer.write(' ');
      ++color;
      if (color >= 256) {
        break;
      }
    }
  }
  terminal.write(buffer);
  buffer.clear();
}

void input(List<int> codes) {
  final str = String.fromCharCodes(codes);
  switch (str) {
    case 'q':
      buffer.write(Ansi.cursorVisible(true));
      buffer.write(Ansi.reset());
      buffer.write(Ansi.clearScreen());
      terminal.write(buffer);
      terminal.rawMode = false;
      exit(0);
  }
}

void resize(ProcessSignal event) {
  rows = terminal.height;
  cols = terminal.width;
  draw();
}

void main() {
  terminal.rawMode = true;
  terminal.write(Ansi.cursorVisible(false));
  draw();
  terminal.input.listen(input);
  terminal.resize.listen(resize);
}
