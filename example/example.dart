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

  final title = 'Hello, termio!';
  final subtitlePre = 'Use ';
  final subtitleKey = 'arrow keys';
  final subtitlePost = ' to navigate';
  final instructionsPre = "Press '";
  final instructionsKey = 'q';
  final instructionsPost = "' to quit";

  final rainbowColors = [
    (255, 100, 100), // Red
    (255, 180, 100), // Orange
    (255, 255, 100), // Yellow
    (100, 255, 100), // Green
    (100, 180, 255), // Blue
    (180, 100, 255), // Violet
  ];

  // Title (bold, rainbow on dark background, centered)
  final titlePadding = 2;
  final titleBgWidth = title.length + titlePadding * 2;
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round() - 2,
      x: (cols / 2).round() - (titleBgWidth / 2).round(),
    ),
  );
  buffer.write(Ansi.bgRgb(60, 60, 70));
  buffer.write(' ' * titlePadding);
  buffer.write(Ansi.bold());
  for (var i = 0; i < title.length; i++) {
    final (r, g, b) = rainbowColors[i % rainbowColors.length];
    buffer.write(Ansi.fgRgb(r, g, b));
    buffer.write(title[i]);
  }
  buffer.write(Ansi.reset());
  buffer.write(Ansi.bgRgb(60, 60, 70));
  buffer.write(' ' * titlePadding);
  buffer.write(Ansi.reset());
  buffer.write(Ansi.fgIndex(6));

  // Subtitle (with 'arrow keys' in bold)
  final subtitleLength =
      subtitlePre.length + subtitleKey.length + subtitlePost.length;
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round(),
      x: (cols / 2).round() - (subtitleLength / 2).round(),
    ),
  );
  buffer.write(subtitlePre);
  buffer.write(Ansi.bold());
  buffer.write(subtitleKey);
  buffer.write(Ansi.reset());
  buffer.write(Ansi.fgIndex(6));
  buffer.write(subtitlePost);

  // Instructions (with 'q' in bold)
  final instructionsLength =
      instructionsPre.length + instructionsKey.length + instructionsPost.length;
  buffer.write(
    Ansi.cursor(
      y: (rows / 2).round() + 2,
      x: (cols / 2).round() - (instructionsLength / 2).round(),
    ),
  );
  buffer.write(instructionsPre);
  buffer.write(Ansi.bold());
  buffer.write(instructionsKey);
  buffer.write(Ansi.reset());
  buffer.write(Ansi.fgIndex(6));
  buffer.write(instructionsPost);
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
