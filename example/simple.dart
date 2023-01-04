import 'dart:io';

import 'package:console/console.dart';

final c = Console();

var cols = c.width;
var rows = c.height;

void quit() {
  c.erase();
  c.reset();
  c.rawMode(false);
  c.cursor(visible: true);
  c.apply();
  exit(0);
}

void draw() {
  c.erase();
  c.foreground(6);
  final str0 = 'Hello';
  final str1 = 'Press \'q\' to quit';
  c.move(
      y: (rows / 2).round() - 1,
      x: (cols / 2).round() - (str0.length / 2).round());
  c.append(str0);
  c.move(
      y: (rows / 2).round() + 1,
      x: (cols / 2).round() - (str1.length / 2).round());
  c.append(str1);
  final str = 'rows $rows cols $cols';
  c.move(y: rows + 1, x: cols - str.length);
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
  c.cursor(visible: false);
  c.apply();
  draw();
  c.input.listen(input);
  c.resize.listen(resize);
}
