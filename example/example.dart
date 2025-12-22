import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();

void main() {
  terminal.rawMode = true;
  terminal.write(Ansi.cursorVisible(false));

  draw();

  terminal.input.listen(onInput);
  terminal.resize.listen((_) => draw());
}

void draw() {
  final buffer = StringBuffer();
  buffer.write(Ansi.clearScreen());
  buffer.write(Ansi.fgIndex(6));
  buffer.write(Ansi.bold());
  buffer.write('Hello, Terminal!\n\n');
  buffer.write(Ansi.reset());
  buffer.write('Use arrow keys to navigate, press ');
  buffer.write(Ansi.underline());
  buffer.write('q');
  buffer.write(Ansi.reset());
  buffer.write(' to quit.\n\n');
  buffer.write('Terminal size: ${terminal.width}x${terminal.height}');
  terminal.write(buffer);
}

void onInput(List<int> codes) {
  final str = String.fromCharCodes(codes);
  if (str == 'q') {
    quit();
  } else if (str == Keys.arrowUp) {
    terminal.write('\nArrow Up pressed');
  } else if (str == Keys.arrowDown) {
    terminal.write('\nArrow Down pressed');
  } else if (str == Keys.arrowLeft) {
    terminal.write('\nArrow Left pressed');
  } else if (str == Keys.arrowRight) {
    terminal.write('\nArrow Right pressed');
  }
}

void quit() {
  terminal.write(Ansi.cursorVisible(true));
  terminal.write(Ansi.reset());
  terminal.write(Ansi.clearScreen());
  terminal.rawMode = false;
  exit(0);
}
