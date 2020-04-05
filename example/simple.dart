import 'package:console/console.dart';

void main() {
  final c = Console();
  c.rawMode = true;

  c.input.listen((codes) {
    String string = String.fromCharCodes(codes);
    stdout.write(string);
    stdout.write(codes);
  });

  c.color_fg = 1;
  c.append("hello\n");
  c.color_fg = 6;
  c.append("[${c.cols}, ${c.rows}]");
  c.apply();
}
