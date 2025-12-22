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
  terminal.write(Ansi.fg(Color.cyan));
  terminal.write(Ansi.bold());
  terminal.write('Hello, Terminal! Press q to quit.');
  terminal.write(Ansi.reset());

  // Listen for keyboard input
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

  // Listen for terminal resize
  terminal.resize.listen((_) {
    terminal.write('Resized: ${terminal.width}x${terminal.height}');
  });
}
```

## Features

- **Terminal** - Raw mode, terminal size, input stream, resize events
- **TestTerminal** - Mock terminal for unit testing
- **Ansi** - Escape codes for cursor, colors, text styles, and terminal modes
- **Keys** - Constants for keyboard input (arrows, function keys, ctrl combinations)
- **Color** - Enum for the 16 standard ANSI colors
- **ThemeDetector** - Detect terminal background color for automatic light/dark theme selection

## Colors

```dart
// Standard 16 colors via enum
Ansi.fg(Color.red)
Ansi.bg(Color.brightCyan)

// 256-color palette by index
Ansi.fgIndex(208)  // orange
Ansi.bgIndex(240)  // gray

// 24-bit truecolor RGB
Ansi.fgRgb(255, 128, 0)
Ansi.bgRgb(30, 30, 30)
```

## Theme Detection

Automatically detect if the terminal has a light or dark background:

```dart
terminal.rawMode = true;
final theme = ThemeDetector.detectSync() ?? ThemeMode.dark;

if (theme == ThemeMode.light) {
  // Use dark colors for text
  terminal.write(Ansi.fgRgb(30, 30, 30));
} else {
  // Use light colors for text
  terminal.write(Ansi.fgRgb(220, 220, 220));
}
```

This sends an OSC 11 query to the terminal and parses the background color
response. Returns `null` if detection fails or times out.

## Testing

Use `TestTerminal` for unit testing without a real terminal:

```dart
final terminal = TestTerminal(width: 80, height: 24);

// Simulate input
terminal.sendInput('q');
terminal.sendBytes([27, 91, 65]); // Up arrow

// Capture output
terminal.write(Ansi.bold());
expect(terminal.takeOutput(), '\x1b[1m');
```

## Examples

See the `example/` folder for complete examples:

- **sweep** - Minesweeper game
- **snake** - Classic snake game
- **life** - Conway's Game of Life
- **simple** - Minimal centered text example
- **colors** - 256-color palette display
