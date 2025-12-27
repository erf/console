# termio

A minimal library for building interactive terminal applications in Dart.

No dependencies. Just pure Dart.

## Installation

```sh
dart pub add termio
```

## Usage

```dart
import 'dart:io';
import 'package:termio/termio.dart';

void main() {
  final terminal = Terminal();
  terminal.rawMode = true;
  terminal.write(Ansi.cursorVisible(false));
  terminal.write(Ansi.clearScreen());

  // Colors: enum, 256-palette index, or RGB
  terminal.write(Ansi.fg(Color.cyan));
  terminal.write(Ansi.fgIndex(208));
  terminal.write(Ansi.fgRgb(255, 128, 0));

  terminal.write(Ansi.bold());
  terminal.write('Hello, Terminal! Press q to quit.');
  terminal.write(Ansi.reset());

  terminal.input.listen((codes) {
    final str = String.fromCharCodes(codes);
    if (str == 'q') {
      terminal.write(Ansi.cursorVisible(true));
      terminal.write(Ansi.reset());
      terminal.write(Ansi.clearScreen());
      terminal.rawMode = false;
      exit(0);
    } else if (str == Keys.arrowUp) {
      terminal.write('\nUp arrow pressed!');
    }
  });

  terminal.resize.listen((_) {
    terminal.write('Resized: ${terminal.width}x${terminal.height}');
  });
}
```

## Features

- **Ansi** - Escape codes for cursor, colors, text styles, and terminal modes
- **Terminal** - Raw mode, terminal size, input stream, resize events
- **Keys** - Constants for keyboard input (arrows, function keys, ctrl combinations)
- **Color** - 16 standard colors, 256-color palette, and 24-bit RGB
- **ThemeDetector** - Detect terminal background color for automatic light/dark theme selection

## Examples

See the `example/` folder for complete examples:

- **example** - Simple demo with title and key input
- **ansi_demo** - Comprehensive demo of all ANSI features (colors, styles, cursor, etc.)
- **sweep** - Minesweeper game
- **snake** - Classic snake game
- **life** - Conway's Game of Life
