import 'dart:io';

import 'package:console/console.dart';

final term = Terminal();
final vt = VT100Buffer();

var cols = term.width;
var rows = term.height;

void quit() {
  vt.homeAndErase();
  vt.resetStyles();
  vt.cursorVisible(true);
  term.write(vt);
  term.rawMode = false;
  exit(0);
}

void draw() {
  vt.homeAndErase();
  vt.foreground(6);
  final str0 = 'Hello';
  final str1 = 'Press \'q\' to quit';
  vt.cursorPosition(
    y: (rows / 2).round() - 1,
    x: (cols / 2).round() - (str0.length / 2).round(),
  );
  vt.write(str0);
  vt.cursorPosition(
    y: (rows / 2).round() + 1,
    x: (cols / 2).round() - (str1.length / 2).round(),
  );
  vt.write(str1);
  final str = 'rows $rows cols $cols';
  vt.cursorPosition(y: rows + 1, x: cols - str.length);
  vt.write(str);
  term.write(vt);
  vt.clear();
}

void input(List<int> codes) {
  final str = String.fromCharCodes(codes);
  if (str == 'q') {
    quit();
  }
}

void resize(ProcessSignal signal) {
  cols = term.width;
  rows = term.height;
  draw();
}

void main() {
  term.rawMode = true;
  term.write(VT100.cursorVisible(false));
  draw();
  term.input.listen(input);
  term.resize.listen(resize);
}
