import 'dart:io';

import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart';

import 'src/generators/assets_generator.dart';
import 'src/generators/colors_generator.dart';
import 'src/generators/fonts_generator.dart';
import 'src/settings/config.dart';
import 'src/utils/file.dart';

Builder build(BuilderOptions options) {
  Future(() async {
    await FlutterGenerator(File('pubspec.yaml')).build();
  });
  return EmptyBuilder();
}

class EmptyBuilder extends Builder {
  @override
  Future<void> build(BuildStep buildStep) async {}

  @override
  Map<String, List<String>> get buildExtensions => {};
}

class FlutterGenerator {
  const FlutterGenerator(this.pubspecFile);

  final File pubspecFile;

  Future<void> build() async {
    final config = Config(pubspecFile);
    try {
      await config.load();
    } on FormatException catch (e) {
      stderr.writeln(e.message);
      exit(-1);
    } on FileSystemException catch (e) {
      stderr.writeln(e.message);
      exit(-1);
    }

    var output = Config.defaultOutput;
    var lineLength = Config.defaultLineLength;

    if (config.hasFlutterGen) {
      output = config.flutterGen.output;
      lineLength = config.flutterGen.lineLength;
      final formatter = DartFormatter(pageWidth: lineLength, lineEnding: '\n');

      if (config.flutterGen.hasColors) {
        final generated =
            generateColors(pubspecFile, formatter, config.flutterGen.colors);
        final colors = File(normalize(
            join(pubspecFile.parent.path, output, 'colors.gen.dart')));
        writeAsString(generated, file: colors);
        print('Generated: ${colors.absolute.path}');
      }
    }

    if (config.hasFlutter) {
      final formatter = DartFormatter(pageWidth: lineLength, lineEnding: '\n');

      if (config.flutter.hasAssets) {
        final generated = generateAssets(
            pubspecFile, formatter, config.flutterGen, config.flutter.assets);
        final assets = File(normalize(
            join(pubspecFile.parent.path, output, 'assets.gen.dart')));
        writeAsString(generated, file: assets);
        print('Generated: ${assets.absolute.path}');
      }

      if (config.flutter.hasFonts) {
        final generated = generateFonts(formatter, config.flutter.fonts);
        final fonts = File(
            normalize(join(pubspecFile.parent.path, output, 'fonts.gen.dart')));
        writeAsString(generated, file: fonts);
        print('Generated: ${fonts.absolute.path}');
      }
    }

    print('FlutterGen finished.');
  }
}
