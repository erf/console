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
  buffer.write(Ansi.fgIndex(6));

  final title = 'Hello, Terminal!';
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
  buffer.write(Ansi.fgIndex(6));

  // Subtitle (centered)
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round(),
      x: (cols / 2).round() - (subtitle.length / 2).round(),
    ),
  );
  buffer.write(subtitle);

  // Instructions (underlined, centered)
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round() + 2,
      x: (cols / 2).round() - (instructions.length / 2).round(),
    ),
  );
  buffer.write(Ansi.underline());
  buffer.write(instructions);
  buffer.write(Ansi.reset());

  // Last key pressed (centered, below instructions)
  if (lastKey.isNotEmpty) {
    buffer.write(Ansi.fgIndex(11));
    final keyInfo = 'Last key: $lastKey';
    buffer.write(
      Ansi.cursor(
        y: (rows / 2).round() + 4,
        x: (cols / 2).round() - (keyInfo.length / 2).round(),
      ),
    );
    buffer.write(keyInfo);
    buffer.write(Ansi.reset());
  }

  // Size info (bottom right)
  final sizeInfo = '${cols}x$rows';
  buffer.write(Ansi.cursor(y: rows, x: cols - sizeInfo.length));
  buffer.write(Ansi.fgIndex(8));
  buffer.write(sizeInfo);
  buffer.write(Ansi.reset());

  terminal.write(buffer);
  buffer.clear();
}

void onInput(List<int> codes) {
  final str = String.fromCharCodes(codes);
  if (str == 'q') {
    quit();
  } else if (str == Keys.arrowUp) {
    lastKey = '↑ Up';
    draw();
  } else if (str == Keys.arrowDown) {
    lastKey = '↓ Down';
    draw();
  } else if (str == Keys.arrowLeft) {
    lastKey = '← Left';
    draw();
  } else if (str == Keys.arrowRight) {
    lastKey = '→ Right';
    draw();
  } else if (str.isNotEmpty) {
    // Show other printable keys
    if (codes.length == 1 && codes[0] >= 32 && codes[0] < 127) {
      lastKey = "'$str'";
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
  terminal.input.listen(onInput);
  terminal.resize.listen(onResize);
}
