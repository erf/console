/// Testing utilities for termio.
///
/// Import this library to use [TestTerminal] for unit testing
/// terminal applications.
///
/// ```dart
/// import 'package:termio/termio.dart';
/// import 'package:termio/testing.dart';
///
/// void main() {
///   final terminal = TestTerminal(width: 80, height: 24);
///   // ... test your app
/// }
/// ```
library;

export 'src/test_terminal.dart';
