import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:console/console.dart';

final c = Console();

final rows = c.rows;
final cols = c.cols;

final ROWS = c.rows - 4;
final COLS = c.cols;

enum State { playing, paused, game_over, quit }

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
    final x = rand.nextInt(COLS - 2) + 1;
    final y = rand.nextInt(ROWS - 2) + 1;
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
  if (head.x == 0 || head.y == 0 || head.y == ROWS - 1 || head.x == COLS - 1) {
    state = State.game_over;
  }

  // check if snake hit itself
  for (var i = 0; i < snake.length - 1; i++) {
    final p = snake[i];
    for (var j = i + 1; j < snake.length; j++) {
      final p1 = snake[j];
      if (p.x == p1.x && p.y == p1.y) {
        state = State.game_over;
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
  c.color_bg = 0;
  c.clear();

  // draw wall
  c.color_fg = 7;
  c.color_bg = 238;
  for (var row = 0; row < ROWS; row++) {
    for (var col = 0; col < COLS; col++) {
      if (row == 0 || col == 0 || row == ROWS - 1 || col == COLS - 1) {
        c.append('#');
      } else {
        c.append(' ');
      }
    }
    c.append('\r\n');
  }

  // draw food
  c.color_fg = 9;
  food.forEach((f) {
    c.move(row: f.y + 1, col: f.x + 1);
    c.append('o');
  });

  // draw snake
  c.color_fg = 11;
  snake.forEach((p) {
    c.move(row: p.y + 1, col: p.x + 1);
    c.append('s');
  });

  // draw game over
  if (state == State.game_over) {
    c.color_fg = 226;
    final str = 'Game Over';
    c.move(row: (rows / 2).round(), col: (cols / 2 - str.length / 2).round());
    c.append(str);
  }

  // draw instructions
  c.color_fg = 226;

  final instructions = [
    'hjkl - move',
    'p    - pause',
    'r    - restart',
    'q    - quit',
  ];

  for (var i = 0; i < 4; i++) {
    c.move(row: ROWS + 1 + i, col: 1);
    c.append(instructions[i]);
  }

  c.apply();
}

void input(codes) {
  final str = String.fromCharCodes(codes);

  switch (str) {
    case 'q':
      state = State.quit;
      c.cursor = true;
      c.move(row: 1, col: 1);
      c.color_reset();
      c.clear();
      c.apply();
      exit(0);
      break;

    case 'p':
      if (state == State.game_over) {
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
  snake = [Point((COLS / 2).round(), (ROWS / 2).round())];
  dir = Point(1, 0);
  final numFood = max((sqrt(COLS * ROWS) / 2.0).round(), 1);
  food = List<Point<int>>.generate(numFood, genFood);
}

void main() {
  c.cursor = false;
  c.rawMode = true;
  init();
  Timer.periodic(Duration(milliseconds: 100), tick);
  c.input.listen(input);
}
