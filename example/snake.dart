import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:termio/termio.dart';

// Colors
class Colors {
  static const wall = 238;
  static const wallFg = 7;
  static const food = 9;
  static const snakeHead = 10;
  static const snakeBody = 2;
  static const text = 226;
  static const bg = 0;
}

// Timing
class Timings {
  static const baseTickMs = 120;
  static const minTickMs = 50;
  static const speedIncrement = 3;
  static const bonusIntervalSec = 10;
}

// Food types: (glyph, color, value, expireSec)
class FoodType {
  final String glyph;
  final int color;
  final int value;
  final int? expireSec; // null = never expires
  const FoodType(this.glyph, this.color, this.value, {this.expireSec});
}

const regularFood = FoodType('●', 9, 1); // GameColor.food.code

const bonusTypes = [
  FoodType('✦', 13, 3, expireSec: 15), // magenta
  FoodType('◆', 14, 5, expireSec: 12), // cyan
  FoodType('★', 11, 7, expireSec: 10), // yellow
  FoodType('❖', 208, 10, expireSec: 8), // orange
  FoodType('✿', 196, 15, expireSec: 6), // red (rare, shorter!)
];

class FoodItem {
  Point<int> pos;
  final FoodType type;
  Timer? expireTimer;
  FoodItem(this.pos, this.type);
}

final terminal = Terminal();
final buffer = StringBuffer();

final height = terminal.height;
final width = terminal.width;

final rows = terminal.height - 4;
final cols = terminal.width;

enum State { playing, paused, gameOver, quit }

List<Point<int>> snake = [];
List<FoodItem> food = [];
Point<int> dir = Point(1, 0);
State state = State.playing;
Random rand = Random();
int score = 0;
int highScore = 0;
Timer? gameTimer;
Timer? bonusSpawnTimer;
String? message;
Timer? messageTimer;

bool isZero(Point p) => p.x == 0 && p.y == 0;

String headChar() {
  if (dir.x == 1) return '>';
  if (dir.x == -1) return '<';
  if (dir.y == 1) return 'v';
  return '^';
}

Point<int> createFoodPos() {
  while (true) {
    final x = rand.nextInt(cols - 2) + 1;
    final y = rand.nextInt(rows - 2) + 1;
    final r = Point(x, y);
    if (!snake.contains(r) && !food.any((f) => f.pos == r)) {
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

  // check if food was eaten
  final eatenIndex = food.indexWhere((f) => f.pos == head);
  if (eatenIndex != -1) {
    final eaten = food[eatenIndex];
    for (var i = 0; i < eaten.type.value; i++) {
      snake.add(snake.last);
    }
    score += eaten.type.value;
    if (score > highScore) highScore = score;

    // show message (longer for bonus)
    final isBonus = eaten.type.expireSec != null;
    final msg = isBonus
        ? '+${eaten.type.value} ${eaten.type.glyph}'
        : '+${eaten.type.value}';
    showMessage(msg, durationMs: isBonus ? 1500 : 500);

    // cancel expire timer if any
    eaten.expireTimer?.cancel();

    // replace with new regular food, or just remove if bonus
    if (eaten.type.expireSec == null) {
      food[eatenIndex] = FoodItem(createFoodPos(), regularFood);
    } else {
      food.removeAt(eatenIndex);
    }

    restartTimer(); // speed up!
  }
}

void spawnBonus() {
  final type = bonusTypes[rand.nextInt(bonusTypes.length)];
  final item = FoodItem(createFoodPos(), type);
  if (type.expireSec != null) {
    item.expireTimer = Timer(Duration(seconds: type.expireSec!), () {
      food.remove(item);
    });
  }
  food.add(item);
}

void showMessage(String msg, {int durationMs = 500}) {
  message = msg;
  messageTimer?.cancel();
  messageTimer = Timer(Duration(milliseconds: durationMs), () {
    message = null;
  });
}

int tickSpeed() => max(
  Timings.minTickMs,
  Timings.baseTickMs - (score * Timings.speedIncrement),
);

void restartTimer() {
  gameTimer?.cancel();
  gameTimer = Timer.periodic(Duration(milliseconds: tickSpeed()), tick);
}

void draw() {
  buffer.write(Ansi.bgIndex(Colors.bg));
  buffer.write(Ansi.clearScreen());

  // draw wall and floor
  for (var row = 0; row < rows; row++) {
    for (var col = 0; col < cols; col++) {
      if (row == 0 || col == 0 || row == rows - 1 || col == cols - 1) {
        buffer.write(Ansi.fgIndex(Colors.wallFg));
        buffer.write(Ansi.bgIndex(Colors.wall));
        buffer.write('#');
      } else {
        buffer.write(Ansi.bgIndex(Colors.bg));
        buffer.write(' ');
      }
    }
    buffer.write('\n');
  }

  // reset background for game elements
  buffer.write(Ansi.bgIndex(Colors.bg));

  // draw food
  for (var f in food) {
    if (f.type.expireSec != null) {
      buffer.write(Ansi.bold());
    }
    buffer.write(Ansi.fgIndex(f.type.color));
    buffer.write(Ansi.cursor(y: f.pos.y + 1, x: f.pos.x + 1));
    buffer.write(f.type.glyph);
    if (f.type.expireSec != null) {
      buffer.write(Ansi.reset());
      buffer.write(Ansi.bgIndex(Colors.bg));
    }
  }

  // draw snake body
  buffer.write(Ansi.fgIndex(Colors.snakeBody));
  for (var i = 1; i < snake.length; i++) {
    final p = snake[i];
    buffer.write(Ansi.cursor(y: p.y + 1, x: p.x + 1));
    buffer.write('○');
  }

  // draw snake head
  if (snake.isNotEmpty) {
    buffer.write(Ansi.fgIndex(Colors.snakeHead));
    buffer.write(Ansi.cursor(y: snake.first.y + 1, x: snake.first.x + 1));
    buffer.write(headChar());
  }

  // draw game over
  if (state == State.gameOver) {
    buffer.write(Ansi.fgIndex(Colors.text));
    buffer.write(Ansi.bold());
    final str = ' GAME OVER ';
    buffer.write(
      Ansi.cursor(
        y: (height / 2).round(),
        x: (width / 2 - str.length / 2).round(),
      ),
    );
    buffer.write(str);
    buffer.write(Ansi.reset());
  }

  // draw paused
  if (state == State.paused) {
    buffer.write(Ansi.fgIndex(Colors.text));
    buffer.write(Ansi.bold());
    final str = ' PAUSED ';
    buffer.write(
      Ansi.cursor(
        y: (height / 2).round(),
        x: (width / 2 - str.length / 2).round(),
      ),
    );
    buffer.write(str);
    buffer.write(Ansi.reset());
  }

  // draw message
  if (message != null) {
    buffer.write(Ansi.fgIndex(Colors.text));
    buffer.write(Ansi.bold());
    buffer.write(
      Ansi.cursor(
        y: (height / 2 - 2).round(),
        x: (width / 2 - message!.length / 2).round(),
      ),
    );
    buffer.write(message!);
    buffer.write(Ansi.reset());
    buffer.write(Ansi.bgIndex(Colors.bg));
  }

  // draw score
  buffer.write(Ansi.fgIndex(Colors.text));

  buffer.write(Ansi.cursor(y: rows + 1, x: 1));
  buffer.write('Score: $score  High: $highScore  Speed: ${tickSpeed()}ms');

  final instructions = ['hjkl/arrows: move', 'p: pause  r: restart  q: quit'];

  for (var i = 0; i < instructions.length; i++) {
    buffer.write(Ansi.cursor(y: rows + 2 + i, x: 1));
    buffer.write(instructions[i]);
  }

  terminal.write(buffer);
  buffer.clear();
}

void quit() {
  state = State.quit;
  gameTimer?.cancel();
  bonusSpawnTimer?.cancel();
  for (var f in food) {
    f.expireTimer?.cancel();
  }
  buffer.write(Ansi.cursorVisible(true));
  buffer.write(Ansi.reset());
  buffer.write(Ansi.clearScreen());
  terminal.write(buffer);
  buffer.clear();
  terminal.rawMode = false;
  exit(0);
}

void input(List<int> codes) {
  final events = InputParser().parse(codes);

  for (final event in events) {
    if (event is! KeyEvent) continue;

    switch (event.key) {
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

      case 'r':
        init();

      case 'h':
      case 'left':
        final d = Point(-1, 0);
        if (!isZero(dir + d)) {
          dir = d;
        }

      case 'j':
      case 'down':
        final d = Point(0, 1);
        if (!isZero(dir + d)) {
          dir = d;
        }

      case 'k':
      case 'up':
        final d = Point(0, -1);
        if (!isZero(dir + d)) {
          dir = d;
        }

      case 'l':
      case 'right':
        final d = Point(1, 0);
        if (!isZero(dir + d)) {
          dir = d;
        }
    }
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
  // cancel existing food timers
  for (var f in food) {
    f.expireTimer?.cancel();
  }
  final numFood = max((sqrt(cols * rows) / 2.0).round(), 1);
  food = List<FoodItem>.generate(
    numFood,
    (_) => FoodItem(createFoodPos(), regularFood),
  );
  bonusSpawnTimer?.cancel();
  bonusSpawnTimer = Timer.periodic(
    Duration(seconds: Timings.bonusIntervalSec),
    (_) {
      final hasBonus = food.any((f) => f.type.expireSec != null);
      if (state == State.playing && !hasBonus) spawnBonus();
    },
  );
  restartTimer();
}

void main() {
  terminal.rawMode = true;
  buffer.write(Ansi.cursorVisible(false));

  // Handle Ctrl+C gracefully
  ProcessSignal.sigint.watch().listen((_) => quit());

  init();
  terminal.input.listen(input);
}
