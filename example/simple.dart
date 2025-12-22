import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();
final buffer = StringBuffer();

var cols = terminal.width;
var rows = terminal.height;

void quit() {
  buffer.write(Ansi.cursorVisible(true));
  buffer.write(Ansi.reset());
  buffer.write(Ansi.clearScreen());
  terminal.write(buffer);
  terminal.rawMode = false;
  exit(0);
}

void draw() {
  buffer.write(Ansi.clearScreen());
  buffer.write(Ansi.fgIndex(6));
  final title = 'Hello';
  final subtitle = 'Welcome to the terminal';
  final instructions = 'Press \'q\' to quit';
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round() - 2,
      x: (cols / 2).round() - (title.length / 2).round(),
    ),
  );
  buffer.write(Ansi.bold());
  buffer.write(title);
  buffer.write(Ansi.reset());
  buffer.write(Ansi.fgIndex(6));
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round(),
      x: (cols / 2).round() - (subtitle.length / 2).round(),
    ),
  );
  buffer.write(subtitle);
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round() + 2,
      x: (cols / 2).round() - (instructions.length / 2).round(),
    ),
  );
  buffer.write(Ansi.underline());
  buffer.write(instructions);
  buffer.write(Ansi.reset());
  final sizeInfo = 'rows $rows cols $cols';
  buffer.write(Ansi.cursor(y: rows + 1, x: cols - sizeInfo.length));
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
  terminal.write(Ansi.cursorVisible(false));
  draw();
  terminal.input.listen(input);
  terminal.resize.listen(resize);
}
