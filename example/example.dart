import 'dart:io';

import 'package:termio/termio.dart';

final terminal = Terminal();
final buffer = StringBuffer();

int cols = terminal.width;
int rows = terminal.height;

String lastKey = '';

void quit() {
  buffer.write(Ansi.cursorVisible(true));
  buffer.write(Ansi.reset());
  buffer.write(Ansi.clearScreen());
  terminal.write(buffer);
  terminal.rawMode = false;
  exit(0);
}

void draw() {
  buffer.write(Ansi.clearScreen());

  final title = 'Hello, termio!';
  final subtitle = 'Use arrow keys to navigate';
  final instructions = "Press 'q' to quit";

  // Title (bold, centered)
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round() - 2,
      x: (cols / 2).round() - (title.length / 2).round(),
    ),
  );
  buffer.write(Ansi.bold());
  buffer.write(title);
  buffer.write(Ansi.reset());

  // Subtitle (centered)
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round(),
      x: (cols / 2).round() - (subtitle.length / 2).round(),
    ),
  );
  buffer.write(subtitle);

  // Instructions (centered)
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round() + 2,
      x: (cols / 2).round() - (instructions.length / 2).round(),
    ),
  );
  buffer.write(instructions);

  // Last key pressed (centered, dimmed)
  if (lastKey.isNotEmpty) {
    final keyInfo = 'Last key: $lastKey';
    buffer.write(
      Ansi.cursor(
        y: (rows / 2).round() + 4,
        x: (cols / 2).round() - (keyInfo.length / 2).round(),
      ),
    );
    buffer.write(Ansi.dim());
    buffer.write(keyInfo);
    buffer.write(Ansi.reset());
  }

  // Size info (bottom right)
  final sizeInfo = '${cols}x$rows';
  buffer.write(Ansi.cursor(y: rows, x: cols - sizeInfo.length));
  buffer.write(sizeInfo);

  terminal.write(buffer);
  buffer.clear();
}

void onInput(InputEvent event) {
  if (event case KeyInputEvent(key: 'q')) {
    quit();
  } else if (event case KeyInputEvent(key: 'up')) {
    lastKey = '↑ Up';
    draw();
  } else if (event case KeyInputEvent(key: 'down')) {
    lastKey = '↓ Down';
    draw();
  } else if (event case KeyInputEvent(key: 'left')) {
    lastKey = '← Left';
    draw();
  } else if (event case KeyInputEvent(key: 'right')) {
    lastKey = '→ Right';
    draw();
  } else if (event case KeyInputEvent(:final key)) {
    // Show other printable keys
    if (key.length == 1 && key.codeUnitAt(0) >= 32 && key.codeUnitAt(0) < 127) {
      lastKey = "'$key'";
      draw();
    }
  }
}

void onResize(ProcessSignal signal) {
  cols = terminal.width;
  rows = terminal.height;
  draw();
}

void main() {
  terminal.rawMode = true;
  terminal.write(Ansi.cursorVisible(false));
  draw();
  terminal.inputEvents.listen(onInput);
  terminal.resize.listen(onResize);
}
