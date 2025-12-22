import 'dart:io';
import 'dart:math';

import 'package:termio/termio.dart';

enum State { playing, lost, won }

enum GridState { closed, open }

class Cell {
  GridState state;
  bool flagged = false;
  bool hasMine = false;
  int neighborMines = 0;

  Cell(this.state);
}

State state = State.playing;

final instructions = [
  'hjkl/arrows - move',
  'f - flag/unflag',
  'o/space - open cell',
  'r - restart',
  'i - instructions',
  'q - quit',
];

bool showInstructions = true;

final terminal = Terminal();
final buffer = StringBuffer();
final random = Random();

var height = terminal.height;
var width = terminal.width;

var rows = 9;
var cols = 9;
var numMines = 10;

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

void draw() {
  buffer.write(Ansi.bgIndex(0));
  buffer.write(Ansi.clearScreen());

  // draw grid
  buffer.write(Ansi.fgIndex(7));
  buffer.write(Ansi.bgIndex(238));

  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      final cell = grid[row][col];

      buffer.write(Ansi.cursor(y: row + 1, x: col + 1));

      switch (cell) {
        case Cell(flagged: true):
          buffer.write(Ansi.fgIndex(11));
          buffer.write('F');
          buffer.write(Ansi.fgIndex(7));
        case Cell(state: GridState.open):
          if (cell.hasMine) {
            buffer.write(Ansi.fgIndex(9));
            buffer.write('*');
            buffer.write(Ansi.fgIndex(7));
          } else if (cell.neighborMines > 0) {
            // Classic minesweeper colors for numbers
            final numColors = [0, 21, 28, 160, 57, 88, 30, 0, 240];
            buffer.write(Ansi.fgIndex(numColors[cell.neighborMines]));
            buffer.write('${cell.neighborMines}');
            buffer.write(Ansi.fgIndex(7));
          } else {
            buffer.write(' ');
          }

        case Cell(state: GridState.closed):
          buffer.write('#');
      }
    }
    buffer.write('\n');
  }

  // draw cursor
  if (state == State.playing) {
    buffer.write(Ansi.cursor(y: cursor.y + 1, x: cursor.x + 1));
    buffer.write('@');
  }

  // draw game lost
  if (state == State.lost) {
    // reveal all mines
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final cell = grid[row][col];
        if (cell.hasMine && !cell.flagged) {
          buffer.write(Ansi.cursor(y: row + 1, x: col + 1));
          buffer.write(Ansi.fgIndex(9));
          buffer.write('*');
        }
      }
    }
    buffer.write(Ansi.fgIndex(226));
    buffer.write(Ansi.bold());
    final str = 'Game Over';
    buffer.write(
      Ansi.cursor(
        y: (height / 2).round(),
        x: (width / 2 - str.length / 2).round(),
      ),
    );
    buffer.write(str);
    buffer.write(Ansi.reset());
  }

  // draw game won
  if (state == State.won) {
    buffer.write(Ansi.fgIndex(226));
    buffer.write(Ansi.bold());
    final str = 'You won!';
    buffer.write(
      Ansi.cursor(
        y: (height / 2).round(),
        x: (width / 2 - str.length / 2).round(),
      ),
    );
    buffer.write(str);
    buffer.write(Ansi.reset());
  }

  // draw instructions
  if (showInstructions) {
    buffer.write(Ansi.fgIndex(226));
    for (var i = 0; i < instructions.length; i++) {
      buffer.write(Ansi.cursor(y: 1 + i, x: cols + 2));
      buffer.write(instructions[i]);
    }
  }

  // draw mine counter
  final flagCount = grid.expand((row) => row).where((c) => c.flagged).length;
  final minesLeft = numMines - flagCount;
  buffer.write(Ansi.fgIndex(9));
  buffer.write(Ansi.cursor(y: rows + 2, x: 1));
  buffer.write('Mines: $minesLeft ');
  buffer.write(Ansi.reset());

  terminal.write(buffer);
  buffer.clear();
}

void move(Point<int> p) {
  if (state == State.lost || state == State.won) {
    return;
  }
  final newPos = cursor + p;
  if (!outsideGrid(newPos)) {
    cursor = newPos;
  }
}

void flag() {
  if (state == State.lost || state == State.won) {
    return;
  }
  final cell = grid[cursor.y][cursor.x];
  cell.flagged = !cell.flagged;
}

void open() {
  if (state == State.lost || state == State.won) {
    return;
  }
  final cell = grid[cursor.y][cursor.x];
  if (cell.state == GridState.open || cell.flagged) {
    return;
  }
  if (cell.hasMine) {
    cell.state = GridState.open;
    state = State.lost;
    return;
  }
  openAround(cursor);
  if (checkWinCondition()) {
    state = State.won;
  }
}

// check if all fields are open except the mine fields
bool checkWinCondition() {
  int numOpen = 0;
  int numMines = 0;
  for (var y = 0; y < rows; y++) {
    for (var x = 0; x < cols; x++) {
      final cell = grid[y][x];
      if (cell.state == GridState.open) {
        numOpen++;
      }
      if (cell.hasMine) {
        numMines++;
      }
    }
  }
  //info = 'num open $numOpen num mines $numMines';

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
  cell.state = GridState.open;
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
    if (neighbourCell.state == GridState.closed) {
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
    case Keys.arrowLeft:
      move(Point(-1, 0));
    case 'j':
    case Keys.arrowDown:
      move(Point(0, 1));
    case 'k':
    case Keys.arrowUp:
      move(Point(0, -1));
    case 'l':
    case Keys.arrowRight:
      move(Point(1, 0));
    case 'f':
      flag();
    case 'o':
    case ' ': // space
      open();
  }

  draw();
}

void resize(ProcessSignal signal) {
  width = terminal.width;
  height = terminal.height;
  draw();
}

void quit() {
  buffer.write(Ansi.cursorVisible(true));
  buffer.write(Ansi.reset());
  buffer.write(Ansi.clearScreen());
  terminal.write(buffer);
  terminal.rawMode = false;
  exit(0);
}

void init() {
  state = State.playing;
  cursor = Point<int>(0, 0);
  grid = List.generate(
    rows,
    (y) => List.generate(cols, (x) => Cell(GridState.closed)),
  );
  final mines = List<Point<int>>.generate(numMines, (_) => createMine());
  for (final mine in mines) {
    grid[mine.y][mine.x].hasMine = true;
  }
}

void main(List<String> args) {
  // Parse arguments: [width] [height] [mines]
  if (args.isNotEmpty) {
    cols = int.tryParse(args[0]) ?? cols;
  }
  if (args.length > 1) {
    rows = int.tryParse(args[1]) ?? rows;
  }
  if (args.length > 2) {
    numMines = int.tryParse(args[2]) ?? numMines;
  }

  // Ensure mines don't exceed available cells (leave at least 1 safe cell)
  final maxMines = (rows * cols) - 1;
  if (numMines > maxMines) {
    numMines = maxMines;
  }

  terminal.rawMode = true;
  buffer.write(Ansi.cursorVisible(false));
  init();
  draw();
  terminal.input.listen(input);
  terminal.resize.listen(resize);
}
