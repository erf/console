# A library for interactive console apps in Dart

Using vt-100 and Dart.io

Mostly for myself to learn and have fun with similar to [sta](https://github.com/erf/sta)

## Features

- raw mode
- cols and rows
- buffer input
- async input stream
- move cursor
- hide / show cursor
- clear
- bg / fg / reset colors


## Examples

- simple
- game of life
- snake
- colors

## Usage

A simple usage example:

```dart
import 'package:console/console.dart';

void main() {
  final c = Console();
  c.rawMode = true;

  c.input.listen((codes) {
    String string = String.fromCharCodes(codes);
    stdout.write(codes);
  });

  c.color_fg = 1;
  c.append("hello\n");
  c.color_fg = 6;
  c.append("[${c.cols}, ${c.rows}]");
  c.apply();
}
```

## Tests

Run tests with:
```
pub run test
```
