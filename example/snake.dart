import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:termio/termio.dart';

// Colors
const wallColor = 238;
const wallFg = 7;
const foodColor = 9;
const snakeHeadColor = 10;
const snakeBodyColor = 2;
const textColor = 226;
const bgColor = 0;

// Timing
const baseTickMs = 120;
const minTickMs = 50;
const speedIncrement = 3;

final terminal = Terminal();
final buffer = StringBuffer();

final height = terminal.height;
final width = terminal.width;

final rows = terminal.height - 4;
final cols = terminal.width;

enum State { playing, paused, gameOver, quit }

List<Point<int>> snake = [];
List<Point<int>> food = [];
Point<int> dir = Point(1, 0);
State state = State.playing;
Random rand = Random();
int score = 0;
int highScore = 0;
Timer? gameTimer;

bool isZero(Point p) => p.x == 0 && p.y == 0;

String headChar() {
  if (dir.x == 1) return '>';
  if (dir.x == -1) return '<';
  if (dir.y == 1) return 'v';
  return '^';
}

Point<int> createFood() {
  while (true) {
    final x = rand.nextInt(cols - 2) + 1;
    final y = rand.nextInt(rows - 2) + 1;
    final r = Point(x, y);
    if (!snake.contains(r)) {
      return r;
    }
  }
}

void update() {
  // update snake tail
  for (var i = snake.length - 1; i > 0; i--) {
    snake[i] = snake[i - 1];
  }

  // update snake head
  snake.first += dir;

  // check if snake hit wall
  final head = snake.first;
  if (head.x == 0 || head.y == 0 || head.y == rows - 1 || head.x == cols - 1) {
    state = State.gameOver;
  }

  // check if snake hit itself (O(1) lookup)
  final body = snake.skip(1).toSet();
  if (body.contains(snake.first)) {
    state = State.gameOver;
    return;
  }

  // check if food was eaten and create new food
  final foodIndex = food.indexOf(head);
  if (foodIndex != -1) {
    snake.add(snake.last);
    food[foodIndex] = createFood();
    score++;
    if (score > highScore) highScore = score;
    restartTimer(); // speed up!
  }
}

int tickSpeed() => max(minTickMs, baseTickMs - (score * speedIncrement));

void restartTimer() {
  gameTimer?.cancel();
  gameTimer = Timer.periodic(Duration(milliseconds: tickSpeed()), tick);
}

void draw() {
  buffer.write(VT100.background(bgColor));
  buffer.write(VT100.homeAndErase());

  // draw wall and floor
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      if (row == 0 || col == 0 || row == rows - 1 || col == cols - 1) {
        buffer.write(VT100.foreground(wallFg));
        buffer.write(VT100.background(wallColor));
        buffer.write('#');
      } else {
        buffer.write(VT100.background(bgColor));
        buffer.write(' ');
      }
    }
    buffer.write('\n');
  }

  // reset background for game elements
  buffer.write(VT100.background(bgColor));

  // draw food
  buffer.write(VT100.foreground(foodColor));
  for (var f in food) {
    buffer.write(VT100.cursorPosition(y: f.y + 1, x: f.x + 1));
    buffer.write('●');
  }

  // draw snake body
  buffer.write(VT100.foreground(snakeBodyColor));
  for (var i = 1; i < snake.length; i++) {
    final p = snake[i];
    buffer.write(VT100.cursorPosition(y: p.y + 1, x: p.x + 1));
    buffer.write('○');
  }

  // draw snake head
  if (snake.isNotEmpty) {
    buffer.write(VT100.foreground(snakeHeadColor));
    buffer.write(
      VT100.cursorPosition(y: snake.first.y + 1, x: snake.first.x + 1),
    );
    buffer.write(headChar());
  }

  // draw game over
  if (state == State.gameOver) {
    buffer.write(VT100.foreground(textColor));
    buffer.write(VT100.bold());
    final str = ' GAME OVER ';
    buffer.write(
      VT100.cursorPosition(
        y: (height / 2).round(),
        x: (width / 2 - str.length / 2).round(),
      ),
    );
    buffer.write(str);
    buffer.write(VT100.resetStyles());
  }

  // draw paused
  if (state == State.paused) {
    buffer.write(VT100.foreground(textColor));
    buffer.write(VT100.bold());
    final str = ' PAUSED ';
    buffer.write(
      VT100.cursorPosition(
        y: (height / 2).round(),
        x: (width / 2 - str.length / 2).round(),
      ),
    );
    buffer.write(str);
    buffer.write(VT100.resetStyles());
  }

  // draw score
  buffer.write(VT100.foreground(textColor));

  buffer.write(VT100.cursorPosition(y: rows + 1, x: 1));
  buffer.write('Score: $score  High: $highScore  Speed: ${tickSpeed()}ms');

  final instructions = ['hjkl/arrows: move', 'p: pause  r: restart  q: quit'];

  for (var i = 0; i < instructions.length; i++) {
    buffer.write(VT100.cursorPosition(y: rows + 2 + i, x: 1));
    buffer.write(instructions[i]);
  }

  terminal.write(buffer);
  buffer.clear();
}

void quit() {
  state = State.quit;
  gameTimer?.cancel();
  buffer.write(VT100.cursorVisible(true));
  buffer.write(VT100.resetStyles());
  buffer.write(VT100.homeAndErase());
  terminal.write(buffer);
  buffer.clear();
  terminal.rawMode = false;
  exit(0);
}

void input(List<int> codes) {
  final str = String.fromCharCodes(codes);

  switch (str) {
    case 'q':
      quit();

    case 'p':
      if (state == State.gameOver) {
        return;
      }
      if (state == State.paused) {
        state = State.playing;
      } else if (state == State.playing) {
        state = State.paused;
      }
      break;

    case 'r':
      init();
      break;

    case 'h':
    case '${VT100.e}[D': // left arrow
      final d = Point(-1, 0);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;

    case 'j':
    case '${VT100.e}[B': // down arrow
      final d = Point(0, 1);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;

    case 'k':
    case '${VT100.e}[A': // up arrow
      final d = Point(0, -1);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;

    case 'l':
    case '${VT100.e}[C': // right arrow
      final d = Point(1, 0);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;
  }
}

void tick(Timer _) {
  if (state == State.gameOver) {
    gameTimer?.cancel();
    draw();
    return;
  }
  if (state != State.playing) {
    return;
  }
  update();
  draw();
}

void init() {
  state = State.playing;
  score = 0;
  snake = [Point((cols / 2).round(), (rows / 2).round())];
  dir = Point(1, 0);
  final numFood = max((sqrt(cols * rows) / 2.0).round(), 1);
  food = List<Point<int>>.generate(numFood, (_) => createFood());
  restartTimer();
}

void main() {
  terminal.rawMode = true;
  buffer.write(VT100.cursorVisible(false));

  // Handle Ctrl+C gracefully
  ProcessSignal.sigint.watch().listen((_) => quit());

  init();
  terminal.input.listen(input);
}
