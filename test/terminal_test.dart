import 'package:termio/termio.dart';
import 'package:termio/testing.dart';
import 'package:test/test.dart';

void main() {
  group('TestTerminal tests', () {
    late TestTerminal terminal;

    setUp(() {
      terminal = TestTerminal(width: 80, height: 24);
    });

    tearDown(() async {
      await terminal.dispose();
    });

    test('has correct dimensions', () {
      expect(terminal.width, 80);
      expect(terminal.height, 24);
    });

    test('can set custom dimensions', () {
      final custom = TestTerminal(width: 120, height: 40);
      expect(custom.width, 120);
      expect(custom.height, 40);
    });

    test('rawMode starts as false', () {
      expect(terminal.rawMode, false);
    });

    test('can toggle rawMode', () {
      terminal.rawMode = true;
      expect(terminal.rawMode, true);
      terminal.rawMode = false;
      expect(terminal.rawMode, false);
    });

    test('write captures output', () {
      terminal.write('Hello');
      terminal.write(' World');
      expect(terminal.output.toString(), 'Hello World');
    });

    test('write handles null', () {
      terminal.write(null);
      expect(terminal.output.toString(), '');
    });

    test('clearOutput clears buffer', () {
      terminal.write('test');
      terminal.clearOutput();
      expect(terminal.output.toString(), '');
    });

    test('takeOutput returns and clears', () {
      terminal.write('test');
      final result = terminal.takeOutput();
      expect(result, 'test');
      expect(terminal.output.toString(), '');
    });

    test('sendInput triggers input stream', () async {
      final inputs = <String>[];
      terminal.input.listen((bytes) {
        inputs.add(String.fromCharCodes(bytes));
      });

      terminal.sendInput('q');
      await Future.delayed(Duration.zero);
      expect(inputs, ['q']);
    });

    test('sendBytes triggers input stream with raw bytes', () async {
      final received = <List<int>>[];
      terminal.input.listen((bytes) {
        received.add(bytes);
      });

      terminal.sendBytes([27, 91, 65]); // Up arrow
      await Future.delayed(Duration.zero);
      expect(received, [
        [27, 91, 65],
      ]);
    });

    test('sendResize triggers resize stream', () async {
      var resizeCount = 0;
      terminal.resize.listen((_) {
        resizeCount++;
      });

      terminal.sendResize();
      await Future.delayed(Duration.zero);
      expect(resizeCount, 1);
    });

    test('implements TerminalBase', () {
      expect(terminal, isA<TerminalBase>());
    });
  });
}
