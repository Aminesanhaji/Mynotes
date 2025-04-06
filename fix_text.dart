import 'dart:io';

void main() {
  final replacements = {
    'headline1': 'displayLarge',
    'headline2': 'displayMedium',
    'headline3': 'displaySmall',
    'headline4': 'headlineLarge',
    'headline5': 'headlineMedium',
    'headline6': 'headlineSmall',
    'subtitle1': 'titleLarge',
    'subtitle2': 'titleMedium',
    'bodyText1': 'bodyLarge',
    'bodyText2': 'bodyMedium',
  };

  final dir = Directory.current;
  final dartFiles = dir
      .listSync(recursive: true)
      .where((f) => f.path.endsWith('.dart'))
      .toList();

  for (final file in dartFiles) {
    final lines = File(file.path).readAsLinesSync();
    final updatedLines = lines.map((line) {
      var newLine = line;
      replacements.forEach((old, newVal) {
        newLine = newLine.replaceAll('.$old', '.$newVal');
      });
      return newLine;
    }).toList();
    File(file.path).writeAsStringSync(updatedLines.join('\n'));
  }

  print('✅ Remplacement terminé !');
}