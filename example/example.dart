import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();

void main() {
  terminal.rawMode = true;
  terminal.write(VT100.cursorVisible(false));

  draw();

  terminal.input.listen(onInput);
  terminal.resize.listen((_) => draw());
}

void draw() {
  final buffer = StringBuffer();
  buffer.write(VT100.homeAndErase());
  buffer.write(VT100.foreground(6));
  buffer.write(VT100.bold());
  buffer.write('Hello, Terminal!\n\n');
  buffer.write(VT100.resetStyles());
  buffer.write('Use arrow keys to navigate, press ');
  buffer.write(VT100.underline());
  buffer.write('q');
  buffer.write(VT100.resetStyles());
  buffer.write(' to quit.\n\n');
  buffer.write('Terminal size: ${terminal.width}x${terminal.height}');
  terminal.write(buffer);
}

void onInput(List<int> codes) {
  final str = String.fromCharCodes(codes);
  if (str == 'q') {
    quit();
  } else if (str == '${VT100.e}[A') {
    terminal.write('\nArrow Up pressed');
  } else if (str == '${VT100.e}[B') {
    terminal.write('\nArrow Down pressed');
  } else if (str == '${VT100.e}[D') {
    terminal.write('\nArrow Left pressed');
  } else if (str == '${VT100.e}[C') {
    terminal.write('\nArrow Right pressed');
  }
}

void quit() {
  terminal.write(VT100.homeAndErase());
  terminal.write(VT100.resetStyles());
  terminal.write(VT100.cursorVisible(true));
  terminal.rawMode = false;
  exit(0);
}
