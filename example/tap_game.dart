/// A fun tap game where colorful targets appear on screen
/// and you must click them before they disappear!
///
/// Run with: dart run example/tap_game.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:termio/termio.dart';

final terminal = Terminal();
final buffer = StringBuffer();
final random = Random();

int cols = 80;
int rows = 24;

// Game state
List<Target> targets = [];
int score = 0;
int totalClicks = 0;
int hits = 0;
int missedTargets = 0;
int gameTimeLeft = 60;
Timer? gameTimer;
Timer? spawnTimer;
Timer? drawTimer;

// Visual feedback
String? feedbackText;
int? feedbackX;
int? feedbackY;
Timer? feedbackTimer;

// Input subscription
StreamSubscription<InputEvent>? inputSub;

// Fun target types with emojis and colors
final targetTypes = [
  TargetType('★', (255, 215, 0), 10), // Gold star
  TargetType('♥', (255, 105, 180), 15), // Pink heart
  TargetType('●', (0, 255, 127), 10), // Green circle
  TargetType('◆', (138, 43, 226), 20), // Purple diamond
  TargetType('▲', (255, 127, 80), 15), // Coral triangle
  TargetType('✿', (255, 182, 193), 25), // Light pink flower (rare!)
];

class TargetType {
  final String glyph;
  final (int, int, int) color;
  final int points;

  TargetType(this.glyph, this.color, this.points);
}

class Target {
  final int x;
  final int y;
  final TargetType type;
  Timer? expireTimer;

  Target(this.x, this.y, this.type);

  void cancelTimer() {
    expireTimer?.cancel();
  }
}

void main() {
  // Setup terminal
  terminal.rawMode = true;
  cols = terminal.width;
  rows = terminal.height;

  buffer.write(Ansi.cursorVisible(false));
  buffer.write(Ansi.mouseMode(true));
  buffer.write(Ansi.clearScreen());
  terminal.write(buffer);
  buffer.clear();

  // Handle Ctrl+C
  ProcessSignal.sigint.watch().listen((_) => quit());

  // Handle terminal resize
  ProcessSignal.sigwinch.watch().listen((_) {
    cols = terminal.width;
    rows = terminal.height;
    // Remove targets that are now out of bounds
    for (final target in targets.toList()) {
      if (target.x < 3 ||
          target.x > cols - 3 ||
          target.y < 4 ||
          target.y > rows - 3) {
        target.cancelTimer();
        targets.remove(target);
      }
    }
    draw();
  });

  // Show intro screen
  showIntro();
}

void showIntro() {
  buffer.write(Ansi.clearScreen());

  final centerX = cols ~/ 2;
  final centerY = rows ~/ 2;

  // Title
  final title = '🎯 TAP GAME 🎯';
  buffer.write(Ansi.cursor(x: centerX - title.length ~/ 2, y: centerY - 5));
  buffer.write(Ansi.fgRgb(255, 215, 0));
  buffer.write(Ansi.bold());
  buffer.write(title);

  // Instructions
  buffer.write(Ansi.reset());
  buffer.write(Ansi.fgRgb(200, 200, 200));

  final lines = [
    'Click the colorful targets before they disappear!',
    '',
    '★ Star = 10 points    ♥ Heart = 15 points',
    '● Circle = 10 points  ◆ Diamond = 20 points',
    '▲ Triangle = 15 points  ✿ Flower = 25 points!',
    '',
    'You have 60 seconds. Good luck!',
    '',
  ];

  for (var i = 0; i < lines.length; i++) {
    buffer.write(
      Ansi.cursor(x: centerX - lines[i].length ~/ 2, y: centerY - 2 + i),
    );
    buffer.write(lines[i]);
  }

  // Start prompt
  buffer.write(Ansi.cursor(x: centerX - 15, y: centerY + 7));
  buffer.write(Ansi.fgRgb(100, 255, 100));
  buffer.write('>>> Click anywhere to start! <<<');

  buffer.write(Ansi.reset());
  terminal.write(buffer);
  buffer.clear();

  // Wait for click to start
  late StreamSubscription<InputEvent> sub;
  sub = terminal.inputEvents.listen((event) {
    switch (event) {
      case MouseInputEvent(:final event):
        if (event.isPress) {
          sub.cancel();
          startGame();
        }
      case KeyInputEvent(key: 'q'):
        sub.cancel();
        quit();
      default:
        break;
    }
  });
}

void startGame() {
  // Reset game state
  targets.clear();
  score = 0;
  totalClicks = 0;
  hits = 0;
  missedTargets = 0;
  gameTimeLeft = 60;

  // Start game timer (countdown)
  gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
    gameTimeLeft--;
    if (gameTimeLeft <= 0) {
      endGame();
    }
  });

  // Spawn targets periodically
  spawnTimer = Timer.periodic(const Duration(milliseconds: 1500), (_) {
    spawnTarget();
  });

  // Initial targets
  spawnTarget();
  spawnTarget();

  // Draw loop
  drawTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
    draw();
  });

  // Input handling
  inputSub = terminal.inputEvents.listen(handleInput);
}

void spawnTarget() {
  if (targets.length >= 8) return; // Max targets on screen

  // Find a valid position (not overlapping other targets, not in header)
  int attempts = 0;
  while (attempts < 20) {
    final x = random.nextInt(cols - 6) + 3;
    final y = random.nextInt(rows - 6) + 4; // Leave room for header

    // Check for overlap with existing targets (3x3 hitbox)
    final overlap = targets.any(
      (t) => (t.x - x).abs() < 4 && (t.y - y).abs() < 3,
    );

    if (!overlap) {
      final type = targetTypes[random.nextInt(targetTypes.length)];
      final target = Target(x, y, type);

      // Set expiration timer (2-4 seconds)
      final duration = Duration(milliseconds: 2000 + random.nextInt(2000));
      target.expireTimer = Timer(duration, () {
        if (targets.contains(target)) {
          targets.remove(target);
          missedTargets++;
        }
      });

      targets.add(target);
      break;
    }
    attempts++;
  }
}

void handleInput(InputEvent event) {
  switch (event) {
    case MouseInputEvent(:final event):
      if (event.isPress && event.button == MouseButton.left) {
        totalClicks++;
        checkHit(event.x, event.y);
      }
    case KeyInputEvent(key: 'q'):
      quit();
    default:
      break;
  }
}

void checkHit(int clickX, int clickY) {
  // Check if click hits any target (3x3 hitbox centered on target)
  for (final target in targets.toList()) {
    final dx = (target.x - clickX).abs();
    final dy = (target.y - clickY).abs();

    if (dx <= 2 && dy <= 1) {
      // Hit!
      hits++;
      score += target.type.points;
      target.cancelTimer();
      targets.remove(target);

      // Show feedback
      showFeedback('+${target.type.points}!', clickX, clickY);
      return;
    }
  }

  // Miss feedback
  showFeedback('Miss', clickX, clickY);
}

void showFeedback(String text, int x, int y) {
  feedbackTimer?.cancel();
  feedbackText = text;
  feedbackX = x;
  feedbackY = y;

  feedbackTimer = Timer(const Duration(milliseconds: 400), () {
    feedbackText = null;
    feedbackX = null;
    feedbackY = null;
  });
}

void draw() {
  buffer.write(Ansi.clearScreen());

  // Draw header
  drawHeader();

  // Draw targets
  for (final target in targets) {
    drawTarget(target);
  }

  // Draw feedback
  if (feedbackText != null && feedbackX != null && feedbackY != null) {
    buffer.write(Ansi.cursor(x: feedbackX!, y: feedbackY!));
    if (feedbackText!.startsWith('+')) {
      buffer.write(Ansi.fgRgb(100, 255, 100)); // Green for hits
    } else {
      buffer.write(Ansi.fgRgb(255, 100, 100)); // Red for misses
    }
    buffer.write(Ansi.bold());
    buffer.write(feedbackText);
  }

  buffer.write(Ansi.reset());
  terminal.write(buffer);
  buffer.clear();
}

void drawHeader() {
  // Score
  buffer.write(Ansi.cursor(x: 2, y: 1));
  buffer.write(Ansi.fgRgb(255, 215, 0));
  buffer.write(Ansi.bold());
  buffer.write('Score: $score');

  // Time left
  final timeText = 'Time: ${gameTimeLeft}s';
  buffer.write(Ansi.cursor(x: cols - timeText.length - 2, y: 1));
  if (gameTimeLeft <= 10) {
    buffer.write(Ansi.fgRgb(255, 80, 80)); // Red when low
  } else {
    buffer.write(Ansi.fgRgb(100, 200, 255));
  }
  buffer.write(timeText);

  // Hits counter
  buffer.write(Ansi.cursor(x: cols ~/ 2 - 5, y: 1));
  buffer.write(Ansi.fgRgb(150, 255, 150));
  buffer.write('Hits: $hits');

  // Divider line
  buffer.write(Ansi.cursor(x: 1, y: 2));
  buffer.write(Ansi.fgRgb(80, 80, 80));
  buffer.write('─' * cols);

  buffer.write(Ansi.reset());
}

void drawTarget(Target target) {
  final (r, g, b) = target.type.color;
  buffer.write(Ansi.fgRgb(r, g, b));

  // Draw 3x3 target for easier clicking
  // Top row
  buffer.write(Ansi.cursor(x: target.x - 1, y: target.y - 1));
  buffer.write('╭─╮');

  // Middle row with symbol
  buffer.write(Ansi.cursor(x: target.x - 1, y: target.y));
  buffer.write('│');
  buffer.write(Ansi.bold());
  buffer.write(target.type.glyph);
  buffer.write(Ansi.reset());
  buffer.write(Ansi.fgRgb(r, g, b));
  buffer.write('│');

  // Bottom row
  buffer.write(Ansi.cursor(x: target.x - 1, y: target.y + 1));
  buffer.write('╰─╯');
}

void endGame() {
  // Stop all timers and input
  gameTimer?.cancel();
  spawnTimer?.cancel();
  drawTimer?.cancel();
  inputSub?.cancel();
  for (final target in targets) {
    target.cancelTimer();
  }

  // Show end screen
  buffer.write(Ansi.clearScreen());

  final centerX = cols ~/ 2;
  final centerY = rows ~/ 2;

  // Title
  buffer.write(Ansi.cursor(x: centerX - 8, y: centerY - 6));
  buffer.write(Ansi.fgRgb(255, 215, 0));
  buffer.write(Ansi.bold());
  buffer.write('🎉 GAME OVER! 🎉');

  buffer.write(Ansi.reset());

  // Final score
  buffer.write(Ansi.cursor(x: centerX - 10, y: centerY - 3));
  buffer.write(Ansi.fgRgb(100, 255, 100));
  buffer.write('Final Score: $score');

  // Stats
  buffer.write(Ansi.fgRgb(200, 200, 200));

  buffer.write(Ansi.cursor(x: centerX - 10, y: centerY - 1));
  buffer.write('Targets hit: $hits');

  buffer.write(Ansi.cursor(x: centerX - 10, y: centerY));
  buffer.write('Targets missed: $missedTargets');

  final accuracy = totalClicks > 0 ? (hits * 100 / totalClicks).round() : 0;
  buffer.write(Ansi.cursor(x: centerX - 10, y: centerY + 1));
  buffer.write('Accuracy: $accuracy%');

  // Encouraging message based on score
  buffer.write(Ansi.cursor(x: centerX - 15, y: centerY + 4));
  buffer.write(Ansi.fgRgb(255, 182, 193));
  if (score >= 300) {
    buffer.write('🌟 AMAZING! You are a TAP MASTER! 🌟');
  } else if (score >= 200) {
    buffer.write('⭐ Great job! You are super fast! ⭐');
  } else if (score >= 100) {
    buffer.write('👍 Nice work! Keep practicing! 👍');
  } else {
    buffer.write('🎮 Good try! Play again to beat it! 🎮');
  }

  // Play again prompt
  buffer.write(Ansi.cursor(x: centerX - 18, y: centerY + 7));
  buffer.write(Ansi.fgRgb(100, 200, 255));
  buffer.write('Click to play again, or press Q to quit');

  buffer.write(Ansi.reset());
  terminal.write(buffer);
  buffer.clear();

  // Wait for input
  late StreamSubscription<InputEvent> sub;
  sub = terminal.inputEvents.listen((event) {
    switch (event) {
      case MouseInputEvent(:final event):
        if (event.isPress) {
          sub.cancel();
          startGame();
        }
      case KeyInputEvent(key: 'q'):
        sub.cancel();
        quit();
      default:
        break;
    }
  });
}

void quit() {
  // Cleanup timers
  gameTimer?.cancel();
  spawnTimer?.cancel();
  drawTimer?.cancel();
  feedbackTimer?.cancel();
  for (final target in targets) {
    target.cancelTimer();
  }

  // Restore terminal
  buffer.write(Ansi.mouseMode(false));
  buffer.write(Ansi.cursorVisible(true));
  buffer.write(Ansi.reset());
  buffer.write(Ansi.clearScreen());
  terminal.write(buffer);

  terminal.rawMode = false;
  exit(0);
}
