import 'dart:io';

import 'package:console/console.dart';

void quit(Console c) {
  c.clear();
  c.color_reset();
  c.rawMode = false;
  c.cursor = true;
  c.apply();
  exit(0);
}

void main() {
  final c = Console();
  c.rawMode = true;
  c.cursor = false;
  c.apply();

  c.input.listen((codes) {
    final str = String.fromCharCodes(codes);
    if (str == 'q') {
      quit(c);
    }
  });

  final cols = c.cols;
  final rows = c.rows;

  c.clear();
  c.color_fg = 1;
  c.color_fg = 6;
  c.move((rows / 2).round() - 1, (cols / 2).round() - 1);
  c.append('Console');
  c.move((rows / 2).round() + 1, (cols / 2).round() - 8);
  c.append("Press 'q' to quit");
  final str = 'rows $rows cols $cols';
  c.move(rows + 1, cols - str.length);
  c.append(str);
  c.apply();
}
