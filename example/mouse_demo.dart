/// Mouse tracking demo - click anywhere to move the cursor.
///
/// This example demonstrates:
/// - Enabling mouse tracking with SGR mode
/// - Parsing mouse events
/// - Moving cursor to click position
/// - Handling scroll wheel events
///
/// Run with: dart run example/mouse_demo.dart
import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();
final buffer = StringBuffer();

int cols = terminal.width;
int rows = terminal.height;

int cursorX = 1;
int cursorY = 1;
String lastEvent = '';

void quit() {
  // Disable mouse tracking before exiting
  buffer.write(Ansi.mouseMode(false));
  buffer.write(Ansi.cursorVisible(true));
  buffer.write(Ansi.reset());
  buffer.write(Ansi.clearScreen());
  terminal.write(buffer);
  terminal.rawMode = false;
  exit(0);
}

void draw() {
  buffer.write(Ansi.clearScreen());

  // Title
  const title = 'Mouse Tracking Demo';
  buffer.write(Ansi.cursor(y: 1, x: (cols - title.length) ~/ 2));
  buffer.write(Ansi.bold());
  buffer.write(title);
  buffer.write(Ansi.reset());

  // Instructions
  const instructions = [
    'Click anywhere to move the cursor',
    'Scroll wheel to see scroll events',
    'Press q to quit',
  ];
  for (var i = 0; i < instructions.length; i++) {
    buffer.write(Ansi.cursor(y: 3 + i, x: 2));
    buffer.write(Ansi.fg(Color.cyan));
    buffer.write('• ${instructions[i]}');
    buffer.write(Ansi.reset());
  }

  // Current cursor position
  buffer.write(Ansi.cursor(y: 8, x: 2));
  buffer.write('Cursor position: ($cursorX, $cursorY)');

  // Last mouse event
  if (lastEvent.isNotEmpty) {
    buffer.write(Ansi.cursor(y: 10, x: 2));
    buffer.write(Ansi.fg(Color.yellow));
    buffer.write('Last event: $lastEvent');
    buffer.write(Ansi.reset());
  }

  // Draw a marker at cursor position
  buffer.write(Ansi.cursor(y: cursorY, x: cursorX));
  buffer.write(Ansi.bgRgb(80, 80, 200));
  buffer.write(' ');
  buffer.write(Ansi.reset());

  // Position actual cursor at marker
  buffer.write(Ansi.cursor(y: cursorY, x: cursorX));

  terminal.write(buffer);
  buffer.clear();
}

void handleInput(List<int> codes) {
  final input = String.fromCharCodes(codes);

  // Check for quit
  if (input == 'q' || input == 'Q') {
    quit();
  }

  // Try to parse as mouse event
  final mouse = MouseEvent.tryParse(input);
  if (mouse != null) {
    lastEvent = mouse.toString();

    if (mouse.isScroll) {
      // Handle scroll - move cursor up/down
      if (mouse.scrollDirection == ScrollDirection.up) {
        cursorY = (cursorY - 1).clamp(1, rows);
      } else {
        cursorY = (cursorY + 1).clamp(1, rows);
      }
    } else if (mouse.isPress && mouse.button == MouseButton.left) {
      // Left click - move cursor to click position
      cursorX = mouse.x.clamp(1, cols);
      cursorY = mouse.y.clamp(1, rows);
    }

    draw();
  }
}

void main() {
  // Handle terminal resize
  ProcessSignal.sigwinch.watch().listen((_) {
    cols = terminal.width;
    rows = terminal.height;
    draw();
  });

  // Enable raw mode for escape sequence detection
  terminal.rawMode = true;

  // Enable mouse tracking with SGR extended mode
  buffer.write(Ansi.mouseMode(true));
  buffer.write(Ansi.cursorVisible(false));
  terminal.write(buffer);
  buffer.clear();

  // Initial draw
  cursorX = cols ~/ 2;
  cursorY = rows ~/ 2;
  draw();

  // Listen for input
  terminal.input.listen(handleInput);

  // Handle Ctrl+C
  ProcessSignal.sigint.watch().listen((_) => quit());
}
