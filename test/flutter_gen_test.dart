@TestOn('vm')
import 'dart:io';

import 'package:dart_style/dart_style.dart';
import 'package:flutter_gen/flutter_generator.dart';
import 'package:flutter_gen/src/generators/assets_generator.dart';
import 'package:flutter_gen/src/generators/colors_generator.dart';
import 'package:flutter_gen/src/generators/fonts_generator.dart';
import 'package:flutter_gen/src/settings/config.dart';
import 'package:test/test.dart';

void main() {
  setUp(() {
    final dir = Directory('test_resources/lib/');

    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  });

  group('Test FlutterGenerator incorrect case', () {
    test('Not founded pubspec.yaml', () async {
      expect(() async {
        return await Config(File('test_resources/pubspec_not_founded.yaml'))
            .load();
      }, throwsA(isA<FileSystemException>()));
    });

    test('Empty pubspec.yaml', () async {
      expect(() async {
        return await Config(File('test_resources/pubspec_empty.yaml')).load();
      }, throwsFormatException);
    });

    test('No settings pubspec.yaml', () async {
      expect(() async {
        return await Config(File('test_resources/pubspec_no_settings.yaml'))
            .load();
      }, throwsFormatException);
    });
  });

  group('Test FlutterGenerator correct case', () {
    test('pubspec.yaml', () async {
      await FlutterGenerator(File('test_resources/pubspec.yaml')).build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });

    test('Only flutter value', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_only_flutter_value.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').existsSync(),
        isFalse,
      );
    });

    test('Only flutter_gen value', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_only_flutter_gen_value.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').existsSync(),
        isFalse,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });

    test('Wrong output path', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_wrong_output_path.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });

    test('Wrong lineLength', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_wrong_line_length.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/fonts.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
      expect(
        File('test_resources/lib/gen/colors.gen.dart').readAsStringSync(),
        isNotEmpty,
      );
    });

    test('Assets on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected = File('test_resources/actual_data/assets.gen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Assets snake-case style on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_snake_case.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected =
          File('test_resources/actual_data/assets_snake_case.gen.dart')
              .readAsStringSync()
              .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Assets camel-case style on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_assets_camel_case.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected =
          File('test_resources/actual_data/assets_camel_case.gen.dart')
              .readAsStringSync()
              .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Assets with No inegrations on pubspec.yaml', () async {
      await FlutterGenerator(
              File('test_resources/pubspec_assets_no_integrations.yaml'))
          .build();
      expect(
        File('test_resources/lib/gen/assets.gen.dart').readAsStringSync(),
        isNotEmpty,
      );

      final pubspec =
          File('test_resources/pubspec_assets_no_integrations.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateAssets(
          pubspec, formatter, config.flutterGen, config.flutter.assets);
      final expected =
          File('test_resources/actual_data/assets_no_integrations.gen.dart')
              .readAsStringSync()
              .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Fonts on pubspec.yaml', () async {
      final config =
          await Config(File('test_resources/pubspec_fonts.yaml')).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual = generateFonts(formatter, config.flutter.fonts);
      final expected = File('test_resources/actual_data/fonts.gen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });

    test('Colors on pubspec.yaml', () async {
      final pubspec = File('test_resources/pubspec_colors.yaml');
      final config = await Config(pubspec).load();
      final formatter = DartFormatter(
          pageWidth: config.flutterGen.lineLength, lineEnding: '\n');

      final actual =
          generateColors(pubspec, formatter, config.flutterGen.colors);
      final expected = File('test_resources/actual_data/colors.gen.dart')
          .readAsStringSync()
          .replaceAll('\r\n', '\n');

      expect(actual, expected);
    });
  });
}
