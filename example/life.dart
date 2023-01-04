import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:console/console.dart';

final c = Console();
final r = Random();

final rows = c.rows;
final cols = c.cols;
final size = rows * cols;

final temp = List<bool>.filled(size, false);
final data = List<bool>.generate(size, (i) => r.nextBool(), growable: false);

bool done = false;

final neighbors = [
  [-1, -1],
  [0, -1],
  [1, -1],
  [-1, 0],
  [1, 0],
  [-1, 1],
  [0, 1],
  [1, 1],
];

void draw() {
  c.color_bg = 0;
  c.color_fg = 6;

  c.clear();

  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      var index = row * rows + col;
      c.append(data[index] ? '#' : ' ');
    }
    c.append('\n');
  }

  c.apply();
}

int numLiveNeighbors(int row, int col) {
  var sum = 0;
  for (var i = 0; i < 8; i++) {
    var x = col + neighbors[i][0];
    if (x < 0 || x >= cols) continue;
    var y = row + neighbors[i][1];
    if (y < 0 || y >= rows) continue;
    sum += data[y * rows + x] ? 1 : 0;
  }
  return sum;
}

/*
 * 1. Any live cell with fewer than two live neighbors dies, as if caused
 *    by underpopulation.
 * 2. Any live cell with two or three live neighbors lives on to the next
 *    generation.
 * 3. Any live cell with more than three live neighbors dies, as if by
 *    overpopulation.
 * 4. Any dead cell with exactly three live neighbors becomes a live cell, as
 *    if by reproduction.
 */
void update() {
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      var n = numLiveNeighbors(row, col);
      var index = row * rows + col;
      var v = data[index];
      temp[index] = (v == true && (n == 2 || n == 3)) || (v == false && n == 3);
    }
  }
  data.setAll(0, temp);
}

void quit() {
  c.clear();
  c.color_reset();
  c.cursor(visible: true);
  c.apply();
  c.rawMode = false;
  exit(0);
}

void input(codes) {
  done = true;
}

void tick(t) {
  draw();
  update();
  if (done) quit();
}

void main(List<String> arguments) {
  c.rawMode = true;
  c.cursor(visible: false);
  c.input.listen(input);
  Timer.periodic(Duration(milliseconds: 200), tick);
}
