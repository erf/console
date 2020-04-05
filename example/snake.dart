import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:console/console.dart';

final c = Console();

int MAX_ROWS = 9;
int MAX_COLS = 24;

class Pos {
  int x;
  int y;

  Pos(this.x, this.y);
}

int rows = c.rows;
int cols = c.cols;
List<Pos> snake = [];
Pos food;
Pos dir;
bool quit = false;
bool game_over = false;
bool paused = false;

Pos r_inside() {
  final r = Random();

  final x = r.nextInt(MAX_COLS - 2) + 2;
  final y = r.nextInt(MAX_ROWS - 2) + 2;
  return Pos(x, y);
}

Pos add(Pos p1, Pos p2) {
  return Pos(p1.x + p2.x, p1.y + p2.y);
}

bool is_zero(Pos p) {
  return p.x == 0 && p.y == 0;
}

bool is_same(Pos p1, Pos p2) {
  return (p1.x == p2.x && p1.y == p2.y);
}

Pos create_food() {
  Pos p;
  while (true) {
    var food_collide = false;
    p = r_inside();
    for (var i = 0; i < snake.length; i++) {
      if (is_same(snake[i], p)) {
        food_collide = true;
        break;
      }
    }
    if (food_collide) {
      break;
    }
  }
  return p;
}

void update() {
  // update snake tail
  for (var i = snake.length - 1; i > 0; i--) {
    snake[i] = snake[i - 1];
    //snake.add(snake.last);
  }

  // update snake head
  snake[0].x += dir.x;
  snake[0].y += dir.y;

  // check if snake hit wall
  final p = snake[0];
  if (p.x == 0 || p.y == 0 || p.y == MAX_ROWS - 1 || p.x == MAX_COLS - 1) {
    game_over = true;
  }

  // check if snake hit itself
  for (var i = 0; i < snake.length - 1; i++) {
    final p = snake[i];
    for (var j = i + 1; j < snake.length; j++) {
      final p1 = snake[j];
      if (p.x == p1.x && p.y == p1.y) {
        game_over = true;
        return;
      }
    }
  }

  // check if food was eaten and create new food
  if (is_same(p, food)) {
    // more snake
    //++snake_len;
    //snake[snake_len - 1] = snake[snake_len - 2];
    snake.add(snake.last);

    // create until food is not on snake
    food = create_food();
  }
}

void draw() {
  c.cursor = false;
  c.color_bg = 0;
  c.clear();

  // draw wall
  c.color_fg = 7;
  c.color_bg = 238;
  for (var row = 0; row < MAX_ROWS; row++) {
    for (var col = 0; col < MAX_COLS; col++) {
      if (row == 0 || col == 0 || row == MAX_ROWS - 1 || col == MAX_COLS - 1) {
        c.append('#');
      } else {
        c.append(' ');
      }
    }
    c.append('\r\n');
  }

  // draw food
  c.color_fg = 9;
  c.move(food.y + 1, food.x + 1);
  c.append('o');

  // draw snake
  c.color_fg = 11;
  for (var i = 0; i < snake.length; i++) {
    final p = snake[i];
    c.move(p.y + 1, p.x + 1);
    c.append('s');
  }

  if (game_over) {
    c.color_fg = 226;
    final str = 'Game Over';
    c.move((rows / 2).round(), (cols / 2 - str.length / 2).round());
    c.append(str);
  }

  c.color_fg = 226;

  final instructions = ['hjkl - move', 'p    - pause', 'r    - restart', 'q    - quit'];

  for (var i = 0; i < 4; i++) {
    c.move(MAX_ROWS + 2 + i, 1);
    c.append(instructions[i]);
  }

  c.apply();
}

void handleInput(codes) {
  final str = String.fromCharCodes(codes);

  switch (str) {
    case 'q':
      quit = true;
      c.cursor = true;
      c.move(1, 1);
      c.color_reset();
      c.clear();
      c.apply();
      exit(0);
      break;

    case 'p':
      if (game_over) {
        return;
      }
      paused = !paused;
      //alert(1);
      break;

    case 'r':
      init_game();
      game_over = false;
      //alert(1);
      break;

    case 'h':
      final d = Pos(-1, 0);
      if (!is_zero(add(dir, d))) {
        dir = d;
      }
      break;

    case 'j':
      final d = Pos(0, 1);
      if (!is_zero(add(dir, d))) {
        dir = d;
      }
      break;

    case 'k':
      final d = Pos(0, -1);
      if (!is_zero(add(dir, d))) {
        dir = d;
      }
      break;

    case 'l':
      final d = Pos(1, 0);
      if (!is_zero(add(dir, d))) {
        dir = d;
      }
      break;
  }
}

void handleUpdate(Timer timer) {
  if (quit || game_over || paused) {
    return;
  }
  update();
  draw();
}

void init_game() {
  snake.clear();
  snake.add(Pos((MAX_COLS / 2).round(), (MAX_ROWS / 2).round()));
  dir = Pos(1, 0);
  food = create_food();
}

void main() {
  c.rawMode = true;
  init_game();
  Timer.periodic(Duration(milliseconds: 150), handleUpdate);
  c.input.listen(handleInput);
}
