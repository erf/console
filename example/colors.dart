import 'dart:io';

import 'package:console/console.dart';

final c = Console();

int rows = c.rows;
int cols = c.cols;

void draw() {
  c.color_bg = 0;
  c.clear();

  var colors = 0;
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      c.move(y: row + 1, x: col + 1);
      c.color_bg = colors;
      c.append(' ');
      ++colors;
      if (colors >= 256) {
        break;
      }
    }
  }
  c.apply();
}

void input(codes) {
  final str = String.fromCharCodes(codes);
  switch (str) {
    case 'q':
      {
        c.cursor(visible: true);
        c.move(y: 1, x: 1);
        c.color_reset();
        c.clear();
        c.apply();
        exit(0);
        break;
      }
  }
}

void resize(event) {
  rows = c.rows;
  cols = c.cols;
  draw();
}

void main() {
  c.cursor(visible: false);
  c.rawMode = true;
  draw();
  c.input.listen(input);
  c.resize.listen(resize);
}
