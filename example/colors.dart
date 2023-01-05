import 'dart:io';

import 'package:console/console.dart';
import 'package:console/src/vt100_buffer.dart';

final term = Terminal();
final vt = VT100Buffer();

int rows = term.height;
int cols = term.width;

void draw() {
  vt.background(0);
  vt.homeAndErase();

  var color = 0;
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      vt.cursorPosition(y: row + 1, x: col + 1);
      vt.background(color);
      vt.write(' ');
      ++color;
      if (color >= 256) {
        break;
      }
    }
  }
  term.write(vt);
  vt.clear();
}

void input(codes) {
  final str = String.fromCharCodes(codes);
  switch (str) {
    case 'q':
      {
        vt.cursorVisible(true);
        vt.cursorPosition(y: 1, x: 1);
        vt.resetStyles();
        vt.homeAndErase();
        term.write(vt);
        vt.clear();
        exit(0);
      }
  }
}

void resize(event) {
  rows = term.height;
  cols = term.width;
  draw();
}

void main() {
  term.rawMode = true;
  term.write(VT100.cursorVisible(false));
  draw();
  term.input.listen(input);
  term.resize.listen(resize);
}
