import 'dart:io';

import 'package:console/console.dart';

final terminal = Terminal();
final buffer = StringBuffer();

int rows = terminal.height;
int cols = terminal.width;

void draw() {
  buffer.write(VT100.background(0));
  buffer.write(VT100.homeAndErase());

  var color = 0;
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      buffer.write(VT100.cursorPosition(y: row + 1, x: col + 1));
      buffer.write(VT100.background(color));
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
      {
        buffer.write(VT100.cursorVisible(true));
        buffer.write(VT100.cursorPosition(y: 1, x: 1));
        buffer.write(VT100.resetStyles());
        buffer.write(VT100.homeAndErase());
        terminal.write(buffer);
        buffer.clear();
        exit(0);
      }
  }
}

void resize(ProcessSignal event) {
  rows = terminal.height;
  cols = terminal.width;
  draw();
}

void main() {
  terminal.rawMode = true;
  terminal.write(VT100.cursorVisible(false));
  draw();
  terminal.input.listen(input);
  terminal.resize.listen(resize);
}
