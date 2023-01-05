import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:console/console.dart';

final term = Terminal();
final buf = VT100Buffer();

final height = term.height;
final width = term.width;

final rows = term.height - 4;
final cols = term.width;

enum State { playing, paused, gameOver, quit }

List<Point<int>> snake = [];
List<Point<int>> food = [];
Point<int> dir = Point(1, 0);
State state = State.playing;
Random rand = Random();

bool isZero(Point p) {
  return p.x == 0 && p.y == 0;
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

Point<int> genFood(int index) {
  return createFood();
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

  // check if snake hit itself
  for (var i = 0; i < snake.length - 1; i++) {
    final p = snake[i];
    for (var j = i + 1; j < snake.length; j++) {
      final p1 = snake[j];
      if (p.x == p1.x && p.y == p1.y) {
        state = State.gameOver;
        return;
      }
    }
  }

  // check if food was eaten and create new food
  final foodIndex = food.indexOf(head);
  if (foodIndex != -1) {
    // more snake
    snake.add(snake.last);

    // add new food
    food[foodIndex] = createFood();
  }
}

void draw() {
  buf.background(0);
  buf.homeAndErase();

  // draw wall
  buf.foreground(7);
  buf.background(238);
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      if (row == 0 || col == 0 || row == rows - 1 || col == cols - 1) {
        buf.write('#');
      } else {
        buf.write(' ');
      }
    }
    buf.write('\n');
  }

  // draw food
  buf.foreground(9);
  for (var f in food) {
    buf.cursorPosition(y: f.y + 1, x: f.x + 1);
    buf.write('o');
  }

  // draw snake
  buf.foreground(11);
  for (var p in snake) {
    buf.cursorPosition(y: p.y + 1, x: p.x + 1);
    buf.write('s');
  }

  // draw game over
  if (state == State.gameOver) {
    buf.foreground(226);
    final str = 'Game Over';
    buf.cursorPosition(
        y: (height / 2).round(), x: (width / 2 - str.length / 2).round());
    buf.write(str);
  }

  // draw instructions
  buf.foreground(226);

  final instructions = [
    'hjkl - move',
    'p    - pause',
    'r    - restart',
    'q    - quit',
  ];

  for (var i = 0; i < 4; i++) {
    buf.cursorPosition(y: rows + 1 + i, x: 1);
    buf.write(instructions[i]);
  }

  term.write(buf);
  buf.clear();
}

void input(codes) {
  final str = String.fromCharCodes(codes);

  switch (str) {
    case 'q':
      state = State.quit;
      buf.cursorVisible(true);
      buf.resetStyles();
      buf.homeAndErase();
      term.write(buf);
      term.rawMode = false;
      exit(0);

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
      final d = Point(-1, 0);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;

    case 'j':
      final d = Point(0, 1);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;

    case 'k':
      final d = Point(0, -1);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;

    case 'l':
      final d = Point(1, 0);
      if (!isZero(dir + d)) {
        dir = d;
      }
      break;
  }
}

void tick(Timer timer) {
  if (state != State.playing) {
    return;
  }
  update();
  draw();
}

void init() {
  state = State.playing;
  snake = [Point((cols / 2).round(), (rows / 2).round())];
  dir = Point(1, 0);
  final numFood = max((sqrt(cols * rows) / 2.0).round(), 1);
  food = List<Point<int>>.generate(numFood, genFood);
}

void main() {
  term.rawMode = true;
  buf.cursorVisible(false);
  init();
  Timer.periodic(Duration(milliseconds: 100), tick);
  term.input.listen(input);
}
