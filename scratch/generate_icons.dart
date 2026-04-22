import 'dart:io';

void main() {
  final dir = Directory('icons');
  final files = dir.listSync().whereType<File>().toList();
  final names = files.map((f) => f.path.split(Platform.pathSeparator).last).toList();
  names.sort();

  final buffer = StringBuffer();
  buffer.writeln('class IconConstants {');
  buffer.writeln('  static const List<String> allIcons = [');
  for (final name in names) {
    buffer.writeln('    "$name",');
  }
  buffer.writeln('  ];');
  buffer.writeln('}');

  File('lib/utils/icon_constants.dart').writeAsStringSync(buffer.toString());
}
