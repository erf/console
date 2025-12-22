# termio

A minimal library for building interactive terminal applications in Dart.

No dependencies. Just pure Dart.

## Installation

```sh
dart pub add termio
```

## Usage

```dart
import 'package:termio/termio.dart';

void main() {
  final terminal = Terminal();
  terminal.rawMode = true;
  terminal.write(VT100.cursorVisible(false));
  terminal.write(VT100.homeAndErase());
  terminal.write(VT100.foreground(6));
  terminal.write(VT100.bold());
  terminal.write('Hello, Terminal!');
  terminal.write(VT100.resetStyles());
  terminal.rawMode = false;
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
