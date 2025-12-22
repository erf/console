import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();
final buffer = StringBuffer();

var cols = terminal.width;
var rows = terminal.height;

void quit() {
  buffer.write(VT100.cursorVisible(true));
  buffer.write(VT100.resetStyles());
  buffer.write(VT100.homeAndErase());
  terminal.write(buffer);
  terminal.rawMode = false;
  exit(0);
}

void draw() {
  buffer.write(VT100.homeAndErase());
  buffer.write(VT100.foreground(6));
  final title = 'Hello';
  final instructions = 'Press \'q\' to quit';
  buffer.write(
    VT100.cursorPosition(
      y: (rows / 2).round() - 1,
      x: (cols / 2).round() - (title.length / 2).round(),
    ),
  );
  buffer.write(title);
  buffer.write(
    VT100.cursorPosition(
      y: (rows / 2).round() + 1,
      x: (cols / 2).round() - (instructions.length / 2).round(),
    ),
  );
  buffer.write(instructions);
  final sizeInfo = 'rows $rows cols $cols';
  buffer.write(VT100.cursorPosition(y: rows + 1, x: cols - sizeInfo.length));
  buffer.write(sizeInfo);
  terminal.write(buffer);
  buffer.clear();
}

void input(List<int> codes) {
  final str = String.fromCharCodes(codes);
  if (str == 'q') {
    quit();
  }
}

void resize(ProcessSignal signal) {
  cols = terminal.width;
  rows = terminal.height;
  draw();
}

void main() {
  terminal.rawMode = true;
  terminal.write(VT100.cursorVisible(false));
  draw();
  terminal.input.listen(input);
  terminal.resize.listen(resize);
}
