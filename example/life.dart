import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:console/console.dart';

final console = Console();
final random = Random();

final int rows = console.rows;
final int cols = console.cols;
final int size = rows * cols;

final temp = List<bool>(size);
final data = List<bool>.generate(size, (i) => random.nextBool(), growable: false);

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
  console.color_bg = 0;
  console.color_fg = 6;

  console.clear();

  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      var index = row * rows + col;
      console.append(data[index] ? '#' : ' ');
    }
    console.append('\n');
  }

  console.apply();
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

void resetConsole() {
  console.clear();
  console.color_reset();
  console.rawMode = false;
  console.cursor = true;
  console.apply();
}

void crash(String message) {
  resetConsole();
  console.write(message);
  exit(1);
}

void quit() {
  resetConsole();
  exit(0);
}

void main(List<String> arguments) {
  try {
    console.rawMode = true;
    console.cursor = false;

    console.input.listen((codes) {
      done = true;
    });

    Timer.periodic(Duration(milliseconds: 200), (t) {
      draw();
      update();
      if (done) quit();
    });
  } catch (exception) {
    crash(exception.toString());
    rethrow;
  }
}
