/// Input event demo - displays parsed keyboard and mouse events.
///
/// This example demonstrates:
/// - Parsing keyboard input including modifiers (Shift, Ctrl, Alt)
/// - Displaying raw escape sequences and parsed key names
/// - Mouse event tracking with button and position info
///
/// Run with: dart run example/input_demo.dart
import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();
final buffer = StringBuffer();

int cols = terminal.width;
int rows = terminal.height;

// Event history (most recent first)
final eventHistory = <String>[];
const maxHistory = 15;

void quit() {
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
  const title = 'Input Event Demo';
  buffer.write(Ansi.cursor(y: 1, x: (cols - title.length) ~/ 2));
  buffer.write(Ansi.bold());
  buffer.write(title);
  buffer.write(Ansi.reset());

  // Instructions
  const instructions = [
    'Press any key to see its parsed event',
    'Try modifiers: Shift, Ctrl, Alt combinations',
    'Mouse clicks and scroll are also tracked',
    'Press Ctrl+C or q to quit',
  ];
  for (var i = 0; i < instructions.length; i++) {
    buffer.write(Ansi.cursor(y: 3 + i, x: 2));
    buffer.write(Ansi.fg(Color.cyan));
    buffer.write('• ${instructions[i]}');
    buffer.write(Ansi.reset());
  }

  // Column headers
  buffer.write(Ansi.cursor(y: 9, x: 2));
  buffer.write(Ansi.bold());
  buffer.write(Ansi.fg(Color.yellow));
  buffer.write('Recent Events:');
  buffer.write(Ansi.reset());

  // Event history
  for (var i = 0; i < eventHistory.length && i < maxHistory; i++) {
    final y = 10 + i;
    if (y >= rows - 1) break;

    buffer.write(Ansi.cursor(y: y, x: 2));
    if (i == 0) {
      // Highlight most recent
      buffer.write(Ansi.fg(Color.green));
      buffer.write('→ ');
    } else {
      buffer.write(Ansi.fg(Color.white));
      buffer.write('  ');
    }
    buffer.write(eventHistory[i]);
    buffer.write(Ansi.reset());
  }

  // Footer
  buffer.write(Ansi.cursor(y: rows, x: 2));
  buffer.write(Ansi.fg(Color.brightBlack));
  buffer.write('Terminal: ${cols}x$rows');
  buffer.write(Ansi.reset());

  terminal.write(buffer);
  buffer.clear();
}

String formatKeyEvent(KeyInputEvent event) {
  final parts = <String>[];

  // Modifiers
  if (event.ctrl) parts.add('Ctrl');
  if (event.alt) parts.add('Alt');
  if (event.shift) parts.add('Shift');

  // Key name
  parts.add(_formatKeyName(event.key));

  final keyCombo = parts.join('+');
  final raw = _escapeRaw(event.raw);

  return 'Key: $keyCombo  │  raw: $raw';
}

String _formatKeyName(String key) {
  // Capitalize known key names
  return switch (key) {
    'up' => 'Up',
    'down' => 'Down',
    'left' => 'Left',
    'right' => 'Right',
    'home' => 'Home',
    'end' => 'End',
    'pageup' => 'PageUp',
    'pagedown' => 'PageDown',
    'insert' => 'Insert',
    'delete' => 'Delete',
    'backspace' => 'Backspace',
    'tab' => 'Tab',
    'enter' => 'Enter',
    'escape' => 'Escape',
    'space' => 'Space',
    ' ' => 'Space',
    _ when key.startsWith('f') && key.length <= 3 => key.toUpperCase(),
    _ => "'$key'",
  };
}

String _escapeRaw(String raw) {
  final buffer = StringBuffer();
  for (final char in raw.codeUnits) {
    if (char == 0x1b) {
      buffer.write('\\x1b');
    } else if (char < 32) {
      buffer.write('\\x${char.toRadixString(16).padLeft(2, '0')}');
    } else if (char == 127) {
      buffer.write('\\x7f');
    } else {
      buffer.writeCharCode(char);
    }
  }
  return buffer.toString();
}

String formatMouseEvent(MouseInputEvent event) {
  final mouse = event.event;
  final parts = <String>[];

  // Event type
  if (mouse.isScroll) {
    parts.add('Scroll ${mouse.scrollDirection?.name ?? 'unknown'}');
  } else if (mouse.isRelease) {
    parts.add('Release');
  } else {
    parts.add('${mouse.button.name} ${mouse.isPress ? 'press' : 'drag'}');
  }

  // Modifiers
  if (mouse.ctrl) parts.add('+Ctrl');
  if (mouse.alt) parts.add('+Alt');
  if (mouse.shift) parts.add('+Shift');

  // Position
  final pos = '(${mouse.x}, ${mouse.y})';

  return 'Mouse: ${parts.join('')} at $pos';
}

void addEvent(String description) {
  eventHistory.insert(0, description);
  if (eventHistory.length > maxHistory) {
    eventHistory.removeLast();
  }
}

void handleInput(InputEvent event) {
  switch (event) {
    case KeyInputEvent(key: 'q' || 'Q', ctrl: false):
      quit();
    case KeyInputEvent(key: 'c', ctrl: true):
      quit();
    case KeyInputEvent():
      addEvent(formatKeyEvent(event));
      draw();
    case MouseInputEvent():
      addEvent(formatMouseEvent(event));
      draw();
  }
}

void main() {
  terminal.rawMode = true;
  buffer.write(Ansi.cursorVisible(false));
  buffer.write(Ansi.mouseMode(true));
  terminal.write(buffer);
  buffer.clear();

  draw();
  terminal.inputEvents.listen(handleInput);

  ProcessSignal.sigint.watch().listen((_) => quit());
  ProcessSignal.sigwinch.watch().listen((_) {
    cols = terminal.width;
    rows = terminal.height;
    draw();
  });
}
