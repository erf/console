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
  terminal.write(VT100.cursorVisible(false));
  terminal.write(VT100.homeAndErase());
  terminal.write(VT100.foreground(6));
  terminal.write(VT100.bold());
  terminal.write('Hello, Terminal! Press q to quit.');
  terminal.write(VT100.resetStyles());

  // Listen for keyboard input
  terminal.input.listen((codes) {
    final str = String.fromCharCodes(codes);
    if (str == 'q') {
      terminal.write(VT100.cursorVisible(true));
      terminal.write(VT100.resetStyles());
      terminal.write(VT100.homeAndErase());
      terminal.rawMode = false;
      exit(0);
    }
  });

  // Listen for terminal resize
  terminal.resize.listen((_) {
    terminal.write('Resized: ${terminal.width}x${terminal.height}');
  });
}
```

## Features

- Raw mode for unbuffered input
- Terminal size (columns and rows)
- Window resize events
- Input stream
- VT100 escape codes (cursor, colors, text styles, clear screen)
- Arrow key constants

## Examples

See the `example/` folder for complete examples:

- **sweep** - Minesweeper-like game
- **snake** - Classic snake game
- **life** - Conway's Game of Life
- **simple** - Minimal example
- **colors** - Color palette display
