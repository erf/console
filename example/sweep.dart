import 'dart:io';
import 'dart:math';

import 'package:console/console.dart';

enum State { playing, won, lost, quit }

enum GridState { closed, opened }

class Cell {
  GridState state;
  bool flagged = false;
  bool hasMine = false;
  int neighborMines = 0;

  Cell(this.state);
}

State state = .playing;

final instructions = [
  'i - instructions',
  'hjkl - move',
  'f - flag/unflag',
  'o - open cell',
  'r - restart',
  'q - quit',
];

bool showInstructions = true;

final terminal = Terminal();
final buffer = StringBuffer();
final random = Random();

final height = terminal.height;
final width = terminal.width;

final rows = 9;
final cols = 9;

var cursor = Point<int>(0, 0);

List<List<Cell>> grid = [];

final neighborOffsets = [
  Point(-1, -1),
  Point(0, -1),
  Point(1, -1),
  Point(-1, 0),
  Point(1, 0),
  Point(-1, 1),
  Point(0, 1),
  Point(1, 1),
];

Point<int> createMine() {
  while (true) {
    final x = random.nextInt(cols - 2) + 1;
    final y = random.nextInt(rows - 2) + 1;
    final r = Point(x, y);
    if (!grid[y][x].hasMine) {
      return r;
    }
  }
}

Point<int> genMine(int index) {
  return createMine();
}

void draw() {
  buffer.write(VT100.background(0));
  buffer.write(VT100.homeAndErase());

  // draw grid
  buffer.write(VT100.foreground(7));
  buffer.write(VT100.background(238));

  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      final cell = grid[row][col];

      buffer.write(VT100.cursorPosition(y: row + 1, x: col + 1));

      switch (cell) {
        case Cell(flagged: true):
          buffer.write(VT100.foreground(11));
          buffer.write('F');
          buffer.write(VT100.foreground(7));

        case Cell(state: .opened):
          if (cell.hasMine) {
            buffer.write(VT100.foreground(9));
            buffer.write('*');
            buffer.write(VT100.foreground(7));
          } else if (cell.neighborMines > 0) {
            buffer.write('${cell.neighborMines}');
          } else {
            buffer.write(' ');
          }

        case Cell(state: .closed):
          buffer.write('#');
      }
    }
    buffer.write('\n');
  }

  // draw cursor
  buffer.write(VT100.cursorPosition(y: cursor.y + 1, x: cursor.x + 1));
  buffer.write('@');

  // draw game over
  if (state == .lost) {
    buffer.write(VT100.foreground(226));
    final str = 'Game Over';
    buffer.write(
      VT100.cursorPosition(
        y: (height / 2).round(),
        x: (width / 2 - str.length / 2).round(),
      ),
    );
    buffer.write(str);
  }

  // draw instructions
  if (showInstructions) {
    buffer.write(VT100.foreground(226));
    for (var i = 0; i < instructions.length; i++) {
      buffer.write(VT100.cursorPosition(y: 1 + i, x: cols + 2));
      buffer.write(instructions[i]);
    }
  }

  terminal.write(buffer);
  buffer.clear();
}

void move(Point<int> p) {
  final newPos = cursor + p;
  if (!outsideGrid(newPos)) {
    cursor = newPos;
  }
}

void flag() {
  final cell = grid[cursor.y][cursor.x];
  cell.flagged = !cell.flagged;
}

void open() {
  final cell = grid[cursor.y][cursor.x];
  if (cell.state == GridState.opened) {
    return;
  }
  cell.state = GridState.opened;
  if (cell.hasMine) {
    state = State.lost;
  } else if (checkWinCondition()) {
    state = .won;
  } else {
    openAround(cursor);
  }
}

// check if all fields are open except the mine fields
bool checkWinCondition() {
  int numOpen = 0;
  int numMines = 0;
  for (var y = 0; y < rows; y++) {
    for (var x = 0; x < rows; x++) {
      final cell = grid[y][x];
      if (cell.state == .opened) {
        numOpen++;
      }
      if (cell.hasMine) {
        numMines++;
      }
    }
  }
  int numTotalCells = rows * cols;
  if ((numOpen + numMines) == numTotalCells) {
    return true;
  }
  return false;
}

bool outsideGrid(Point<int> p) {
  return p.x < 0 || p.x >= cols || p.y < 0 || p.y >= rows;
}

void openAround(Point<int> p) {
  if (outsideGrid(p)) {
    return;
  }
  final cell = grid[p.y][p.x];
  if (cell.hasMine) {
    return;
  }
  cell.state = .opened;
  cell.neighborMines = neighbourMines(p);

  if (cell.neighborMines != 0) {
    return;
  }

  for (final offset in neighborOffsets) {
    final neighbour = p + offset;
    if (outsideGrid(neighbour)) {
      continue;
    }
    final neighbourCell = grid[neighbour.y][neighbour.x];
    if (neighbourCell.state == .closed) {
      openAround(neighbour);
    }
  }
}

bool mineAt(Point<int> p) {
  if (outsideGrid(p)) {
    return false;
  }
  return grid[p.y][p.x].hasMine;
}

int neighbourMines(Point<int> p) {
  if (outsideGrid(p)) {
    return 0;
  }
  int mines = 0;
  for (final offset in neighborOffsets) {
    mines += mineAt(p + offset) ? 1 : 0;
  }
  return mines;
}

void input(List<int> codes) {
  final str = String.fromCharCodes(codes);

  switch (str) {
    case 'q':
      quit();
    case 'i':
      showInstructions = !showInstructions;
    case 'r':
      init();
    case 'h':
      move(Point(-1, 0));
    case 'j':
      move(Point(0, 1));
    case 'k':
      move(Point(0, -1));
    case 'l':
      move(Point(1, 0));
    case 'f':
      flag();
    case 'o':
      open();
  }

  draw();
}

void resize(ProcessSignal signal) {
  draw();
}

void quit() {
  state = .quit;
  buffer.write(VT100.cursorVisible(true));
  buffer.write(VT100.resetStyles());
  buffer.write(VT100.homeAndErase());
  terminal.write(buffer);
  terminal.rawMode = false;
  exit(0);
}

void init() {
  state = .playing;
  cursor = Point<int>(0, 0);
  grid = .generate(rows, (y) => .generate(cols, (x) => Cell(.closed)));
  //final numMines = max((sqrt(cols * rows) / 4.0).round(), 1);
  final numMines = 2;
  final mines = List<Point<int>>.generate(numMines, genMine);
  for (final mine in mines) {
    grid[mine.y][mine.x].hasMine = true;
  }
  draw();
}

void main() {
  terminal.rawMode = true;
  buffer.write(VT100.cursorVisible(false));
  init();
  draw();
  terminal.input.listen(input);
  terminal.resize.listen(resize);
}
