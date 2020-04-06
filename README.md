# A library for interactive console apps in Dart

Using vt-100 and Dart.io

Mostly for myself to learn and have fun with similar to [sta](https://github.com/erf/sta)

## Features

- raw mode
- get cols and rows
- window resize events
- buffered input
- async input stream
- move, hide cursor
- colors

## Examples

- simple
- game of life
- snake
- colors

## Usage

A simple usage example:

```dart
import 'package:console/console.dart';

final c = Console();

void main() {

  c.rawMode = true;
  c.cursor = false;

  c.input.listen((codes) {
    String string = String.fromCharCodes(codes);
    stdout.write(codes);
  });

  c.resize.listen((signal) {
    var cols = c.cols;
    var rows = c.rows;
  });

  Timer.periodic(Duration(milliseconds: 200), (t) {
    // TODO update
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
