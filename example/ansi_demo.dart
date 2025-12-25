import 'dart:io';

import 'package:termio/termio.dart';

/// Comprehensive demo of all ANSI features from ansi.dart
///
/// This example demonstrates:
/// - Cursor movement and positioning
/// - Cursor visibility and styles
/// - Standard 16 colors (foreground and background)
/// - 256-color palette
/// - 24-bit truecolor (RGB)
/// - Text styles (bold, dim, italic, underline, blink, inverse, strikethrough)
/// - Terminal modes (alt buffer, alternate scroll, grapheme cluster)
/// - Window title manipulation
/// - Clipboard operations (OSC 52)
/// - Background color query

final terminal = Terminal();
final buffer = StringBuffer();

int rows = terminal.height;
int cols = terminal.width;
int currentDemo = 0;

final demos = <String>[
  'Standard Colors',
  '256-Color Palette',
  'Truecolor (RGB)',
  'Text Styles',
  'Cursor Styles',
  'Cursor Movement',
  'Window Title',
  'Clipboard & Query',
];

void quit() {
  buffer.write(Ansi.cursorVisible(true));
  buffer.write(Ansi.cursorReset());
  buffer.write(Ansi.reset());
  buffer.write(Ansi.altBuffer(false));
  terminal.write(buffer);
  terminal.rawMode = false;
  exit(0);
}

void drawHeader() {
  buffer.write(Ansi.cursor(x: 1, y: 1));
  buffer.write(Ansi.bgIndex(236));
  buffer.write(Ansi.fgIndex(15));
  buffer.write(Ansi.bold());
  final title = ' ANSI Demo: ${demos[currentDemo]} ';
  buffer.write(title.padRight(cols));
  buffer.write(Ansi.reset());
}

void drawFooter() {
  buffer.write(Ansi.cursor(x: 1, y: rows));
  buffer.write(Ansi.bgIndex(236));
  buffer.write(Ansi.fgIndex(7));
  final nav = currentDemo == 5
      ? ' [←/→] Navigate  [hjkl] Move *  [N+hjkl] Move N  [q] Quit  Demo ${currentDemo + 1}/${demos.length} '
      : ' [←/→] Navigate  [q] Quit  Demo ${currentDemo + 1}/${demos.length} ';
  buffer.write(nav.padRight(cols));
  buffer.write(Ansi.reset());
}

void demoStandardColors() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fg(Color.white));
  buffer.write('Standard 16 Colors (Color enum):');
  y += 2;

  // Foreground colors
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.reset());
  buffer.write('Foreground: ');
  for (final color in Color.values) {
    buffer.write(Ansi.fg(color));
    buffer.write('■ ');
  }
  buffer.write(Ansi.reset());
  y += 2;

  // Background colors
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Background: ');
  for (final color in Color.values) {
    buffer.write(Ansi.bg(color));
    buffer.write('  ');
    buffer.write(Ansi.reset());
  }
  y += 2;

  // Color names
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fg(Color.brightWhite));
  buffer.write('Color names:');
  y += 1;
  for (var i = 0; i < Color.values.length; i++) {
    final color = Color.values[i];
    if (i % 4 == 0) {
      y += 1;
      buffer.write(Ansi.cursor(x: 3, y: y));
    }
    buffer.write(Ansi.fg(color));
    buffer.write('${color.name.padRight(14)} ');
  }
  buffer.write(Ansi.reset());
}

void demo256Colors() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(15));
  buffer.write('256-Color Palette (fgIndex/bgIndex):');
  y += 2;

  // Standard colors (0-15)
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.reset());
  buffer.write('Standard (0-15):    ');
  for (var i = 0; i < 16; i++) {
    buffer.write(Ansi.bgIndex(i));
    buffer.write('  ');
  }
  buffer.write(Ansi.reset());
  y += 2;

  // 6x6x6 color cube (16-231)
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Color cube (16-231):');
  y += 1;
  for (var row = 0; row < 6; row++) {
    buffer.write(Ansi.cursor(x: 3, y: y + row));
    for (var col = 0; col < 36; col++) {
      final index = 16 + row * 36 + col;
      buffer.write(Ansi.bgIndex(index));
      buffer.write(' ');
    }
    buffer.write(Ansi.reset());
  }
  y += 7;

  // Grayscale (232-255)
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Grayscale (232-255): ');
  for (var i = 232; i < 256; i++) {
    buffer.write(Ansi.bgIndex(i));
    buffer.write(' ');
  }
  buffer.write(Ansi.reset());
}

void demoTruecolor() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgRgb(255, 255, 255));
  buffer.write('24-bit Truecolor (fgRgb/bgRgb):');
  buffer.write(Ansi.reset());
  y += 2;

  // RGB gradient
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Red gradient:   ');
  for (var i = 0; i < 32; i++) {
    final r = (i * 8).clamp(0, 255);
    buffer.write(Ansi.bgRgb(r, 0, 0));
    buffer.write(' ');
  }
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Green gradient: ');
  for (var i = 0; i < 32; i++) {
    final g = (i * 8).clamp(0, 255);
    buffer.write(Ansi.bgRgb(0, g, 0));
    buffer.write(' ');
  }
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Blue gradient:  ');
  for (var i = 0; i < 32; i++) {
    final b = (i * 8).clamp(0, 255);
    buffer.write(Ansi.bgRgb(0, 0, b));
    buffer.write(' ');
  }
  buffer.write(Ansi.reset());
  y += 2;

  // Rainbow
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Rainbow:        ');
  for (var i = 0; i < 32; i++) {
    final hue = (i / 32 * 360).round();
    final (r, g, b) = hsvToRgb(hue, 1.0, 1.0);
    buffer.write(Ansi.bgRgb(r, g, b));
    buffer.write(' ');
  }
  buffer.write(Ansi.reset());
  y += 2;

  // Foreground text colors
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Foreground text: ');
  buffer.write(Ansi.fgRgb(255, 100, 100));
  buffer.write('Red ');
  buffer.write(Ansi.fgRgb(100, 255, 100));
  buffer.write('Green ');
  buffer.write(Ansi.fgRgb(100, 100, 255));
  buffer.write('Blue ');
  buffer.write(Ansi.fgRgb(255, 200, 50));
  buffer.write('Orange ');
  buffer.write(Ansi.fgRgb(200, 100, 255));
  buffer.write('Purple');
  buffer.write(Ansi.reset());
}

(int, int, int) hsvToRgb(int h, double s, double v) {
  final c = v * s;
  final x = c * (1 - ((h / 60) % 2 - 1).abs());
  final m = v - c;
  double r, g, b;
  if (h < 60) {
    (r, g, b) = (c, x, 0.0);
  } else if (h < 120) {
    (r, g, b) = (x, c, 0.0);
  } else if (h < 180) {
    (r, g, b) = (0.0, c, x);
  } else if (h < 240) {
    (r, g, b) = (0.0, x, c);
  } else if (h < 300) {
    (r, g, b) = (x, 0.0, c);
  } else {
    (r, g, b) = (c, 0.0, x);
  }
  return (
    ((r + m) * 255).round(),
    ((g + m) * 255).round(),
    ((b + m) * 255).round(),
  );
}

void demoTextStyles() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(15));
  buffer.write('Text Styles:');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.bold());
  buffer.write('Bold text (bold())');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.dim());
  buffer.write('Dim/faint text (dim())');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.italic());
  buffer.write('Italic text (italic())');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.underline());
  buffer.write('Underlined text (underline())');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.blink());
  buffer.write('Blinking text (blink()) - if supported');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.inverse(true));
  buffer.write('Inverse text (inverse(true))');
  buffer.write(Ansi.inverse(false));
  buffer.write(' <- disabled');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.strikethrough());
  buffer.write('Strikethrough text (strikethrough())');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Combined: ');
  buffer.write(Ansi.bold());
  buffer.write(Ansi.italic());
  buffer.write(Ansi.underline());
  buffer.write(Ansi.fgRgb(255, 200, 100));
  buffer.write('Bold + Italic + Underline + Color');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(8));
  buffer.write('reset() clears all styles and colors');
  buffer.write(Ansi.reset());
}

void demoCursorStyles() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(15));
  buffer.write('Cursor Styles (CursorStyle enum):');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Press 1-6 to change cursor style, 0 to reset:');
  y += 2;

  for (final style in CursorStyle.values) {
    buffer.write(Ansi.cursor(x: 3, y: y));
    buffer.write('  ${style.code}. ${style.name}');
    y += 1;
  }
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  0. Reset to terminal default (cursorReset())');
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.cursorVisible(true));
  buffer.write('Cursor visibility: cursorVisible(true/false)');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Press v to toggle cursor visibility');
}

bool cursorIsVisible = true;

// Cursor movement demo state
int starX = 7;
int starY = 2;
const int boxWidth = 14;
const int boxHeight = 3;
int moveCount = 0; // For vim-style count prefix (e.g., "5j")

void demoCursorMovement() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(15));
  buffer.write('Cursor Movement - Use hjkl (vim-style) to move the *');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('cursor(x, y)    - Absolute position');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('cursorUp(N)     - Move up N lines');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('cursorDown(N)   - Move down N lines');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('cursorLeft(N)   - Move left N columns');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('cursorRight(N)  - Move right N columns');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('cursorSave()    - Save position');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('cursorRestore() - Restore position');
  y += 2;

  // Interactive demo box
  final boxX = 5;
  final boxY = y;
  buffer.write(Ansi.cursor(x: boxX, y: boxY));
  buffer.write(Ansi.fgIndex(14));
  buffer.write('┌──────────────┐');
  for (var i = 1; i <= boxHeight; i++) {
    buffer.write(Ansi.cursor(x: boxX, y: boxY + i));
    buffer.write('│              │');
  }
  buffer.write(Ansi.cursor(x: boxX, y: boxY + boxHeight + 1));
  buffer.write('└──────────────┘');
  buffer.write(Ansi.reset());

  // Draw the movable asterisk
  buffer.write(Ansi.cursor(x: boxX + starX, y: boxY + starY));
  buffer.write(Ansi.fgIndex(11));
  buffer.write(Ansi.bold());
  buffer.write('*');
  buffer.write(Ansi.reset());

  y = boxY + boxHeight + 3;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(8));
  buffer.write('Position: ($starX, $starY)');
  if (moveCount > 0) {
    buffer.write('  Count: $moveCount');
  }
  buffer.write('          '); // Clear any leftover text
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('h/j/k/l = left/down/up/right, prefix with number (e.g. 5j)');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('s = save position, r = restore position');
  buffer.write(Ansi.reset());
}

int savedStarX = 1;
int savedStarY = 1;

void demoWindowTitle() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(15));
  buffer.write('Window Title Operations:');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('setTitle(String)  - Set window title');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('pushTitle()       - Push current title onto stack');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('popTitle()        - Pop and restore title from stack');
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(11));
  buffer.write('Press t to cycle through title demos:');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  1. Push current title');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  2. Set title to "ANSI Demo - Title Changed!"');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  3. Pop (restore) original title');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(8));
  buffer.write('Current title step: $titleStep/3');
}

int titleStep = 0;

void demoClipboardAndQuery() {
  var y = 4;
  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(15));
  buffer.write('Clipboard & Query Operations:');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(11));
  buffer.write('Clipboard (OSC 52):');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  copyToClipboard(String) - Copy text to clipboard');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  queryClipboard()        - Query clipboard contents');
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(9));
  buffer.write('⚠ Security: OSC 52 may be disabled in some terminals');
  buffer.write(Ansi.reset());
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(11));
  buffer.write('Query:');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  queryBackgroundColor()  - Query terminal background');
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('Press c to copy "Hello from ANSI Demo!" to clipboard');
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(11));
  buffer.write('Other Terminal Modes:');
  buffer.write(Ansi.reset());
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  altBuffer(bool)        - Alternate screen buffer');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  alternateScroll(bool)  - Scroll mode (mode 1007)');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  graphemeCluster(bool)  - Unicode handling (mode 2027)');
  y += 1;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write('  clearScreen()          - Clear screen and move home');
  y += 2;

  buffer.write(Ansi.cursor(x: 3, y: y));
  buffer.write(Ansi.fgIndex(8));
  buffer.write('Constants: Ansi.e (escape char), Ansi.bell (bell char)');
}

void draw() {
  buffer.write(Ansi.reset());
  buffer.write(Ansi.clearScreen());

  drawHeader();
  drawFooter();

  switch (currentDemo) {
    case 0:
      demoStandardColors();
    case 1:
      demo256Colors();
    case 2:
      demoTruecolor();
    case 3:
      demoTextStyles();
    case 4:
      demoCursorStyles();
    case 5:
      demoCursorMovement();
    case 6:
      demoWindowTitle();
    case 7:
      demoClipboardAndQuery();
  }

  terminal.write(buffer);
  buffer.clear();
}

void input(List<int> codes) {
  final str = String.fromCharCodes(codes);

  // Quit
  if (str == 'q') {
    quit();
  }

  // Navigation with arrow keys
  if (str == '\x1b[C') {
    // Right arrow
    currentDemo = (currentDemo + 1) % demos.length;
    moveCount = 0;
    draw();
    return;
  }
  if (str == '\x1b[D') {
    // Left arrow
    currentDemo = (currentDemo - 1 + demos.length) % demos.length;
    moveCount = 0;
    draw();
    return;
  }

  // Cursor style demo
  if (currentDemo == 4) {
    if (str == '1') {
      terminal.write(Ansi.cursorStyle(CursorStyle.blinkingBlock));
    } else if (str == '2') {
      terminal.write(Ansi.cursorStyle(CursorStyle.steadyBlock));
    } else if (str == '3') {
      terminal.write(Ansi.cursorStyle(CursorStyle.blinkingUnderline));
    } else if (str == '4') {
      terminal.write(Ansi.cursorStyle(CursorStyle.steadyUnderline));
    } else if (str == '5') {
      terminal.write(Ansi.cursorStyle(CursorStyle.blinkingBar));
    } else if (str == '6') {
      terminal.write(Ansi.cursorStyle(CursorStyle.steadyBar));
    } else if (str == '0') {
      terminal.write(Ansi.cursorReset());
    } else if (str == 'v') {
      cursorIsVisible = !cursorIsVisible;
      terminal.write(Ansi.cursorVisible(cursorIsVisible));
    }
  }

  // Cursor movement demo - interactive asterisk with vim-style hjkl
  if (currentDemo == 5) {
    // Check for digit input to build count prefix
    if (str.length == 1 && str.codeUnitAt(0) >= 48 && str.codeUnitAt(0) <= 57) {
      final digit = str.codeUnitAt(0) - 48;
      moveCount = moveCount * 10 + digit;
      if (moveCount > 99) moveCount = 99; // Cap at 99
      draw();
      return;
    }

    final count = moveCount > 0 ? moveCount : 1;
    var moved = false;

    if (str == 'k') {
      // Up (vim k)
      final newY = (starY - count).clamp(1, boxHeight);
      if (newY != starY) {
        starY = newY;
        moved = true;
      }
    } else if (str == 'j') {
      // Down (vim j)
      final newY = (starY + count).clamp(1, boxHeight);
      if (newY != starY) {
        starY = newY;
        moved = true;
      }
    } else if (str == 'h') {
      // Left (vim h)
      final newX = (starX - count).clamp(1, boxWidth);
      if (newX != starX) {
        starX = newX;
        moved = true;
      }
    } else if (str == 'l') {
      // Right (vim l)
      final newX = (starX + count).clamp(1, boxWidth);
      if (newX != starX) {
        starX = newX;
        moved = true;
      }
    } else if (str == 's') {
      // Save position
      savedStarX = starX;
      savedStarY = starY;
      moveCount = 0;
      draw();
      return;
    } else if (str == 'r') {
      // Restore position
      starX = savedStarX;
      starY = savedStarY;
      moved = true;
    }

    if (moved) {
      moveCount = 0;
      draw();
      return;
    }
  }

  // Window title demo
  if (currentDemo == 6 && str == 't') {
    titleStep = (titleStep % 3) + 1;
    switch (titleStep) {
      case 1:
        terminal.write(Ansi.pushTitle());
      case 2:
        terminal.write(Ansi.setTitle('ANSI Demo - Title Changed!'));
      case 3:
        terminal.write(Ansi.popTitle());
        titleStep = 0;
    }
    draw();
  }

  // Clipboard demo
  if (currentDemo == 7 && str == 'c') {
    terminal.write(Ansi.copyToClipboard('Hello from ANSI Demo!'));
  }
}

void resize(ProcessSignal signal) {
  rows = terminal.height;
  cols = terminal.width;
  draw();
}

void main() {
  // Enter alternate buffer and raw mode
  terminal.write(Ansi.altBuffer(true));
  terminal.rawMode = true;
  terminal.write(Ansi.cursorVisible(false));

  // Set initial title
  terminal.write(Ansi.setTitle('ANSI Demo'));

  draw();

  terminal.input.listen(input);
  terminal.resize.listen(resize);
}
