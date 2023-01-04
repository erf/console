import 'dart:io';

import 'package:console/console.dart';

final c = Console();

var cols = c.width;
var rows = c.height;

void quit() {
  c.clear();
  c.reset();
  c.cursorVisible(true);
  c.apply();
  c.rawMode(false);
  exit(0);
}

void draw() {
  c.clear();
  c.foreground(6);
  final str0 = 'Hello';
  final str1 = 'Press \'q\' to quit';
  c.cursorPosition(
      y: (rows / 2).round() - 1,
      x: (cols / 2).round() - (str0.length / 2).round());
  c.append(str0);
  c.cursorPosition(
      y: (rows / 2).round() + 1,
      x: (cols / 2).round() - (str1.length / 2).round());
  c.append(str1);
  final str = 'rows $rows cols $cols';
  c.cursorPosition(y: rows + 1, x: cols - str.length);
  c.append(str);
  c.apply();
}

void input(codes) {
  final str = String.fromCharCodes(codes);
  if (str == 'q') {
    quit();
  }
}

void resize(signal) {
  cols = c.width;
  rows = c.height;
  draw();
}

void main() {
  c.rawMode(true);
  c.cursorVisible(false);
  c.apply();
  draw();
  c.input.listen(input);
  c.resize.listen(resize);
}
